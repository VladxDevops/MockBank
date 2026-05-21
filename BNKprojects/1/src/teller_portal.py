import os
from flask import Flask, request, render_template, redirect, session, make_response
from onelogin.saml2.auth import OneLogin_Saml2_Auth
from onelogin.saml2.utils import OneLogin_Saml2_Utils
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

app = Flask(__name__)

# Hardening: Fail fast if secrets are missing. No fallbacks allowed in secure tier.
app.config['SECRET_KEY'] = os.getenv('SESSION_SECRET')
if not app.config['SECRET_KEY']:
    raise RuntimeError("SESSION_SECRET must be provided via environment variables.")

app.config['SAML_PATH'] = os.path.join(os.path.dirname(__file__), 'certs')

def init_saml_auth(req):
    """Initializes the SAML settings based on current environment."""
    keycloak_url = os.getenv('KEYCLOAK_URL', 'http://localhost:8080')
    app_base_url = os.getenv('APP_BASE_URL', 'http://localhost:5000')

    # Settings dictionary for python3-saml
    settings = {
        "strict": True,
        "debug": True,
        "sp": {
            "entityId": "teller-portal",
            "assertionConsumerService": {
                "url": f"{app_base_url}/saml/acs",
                "binding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            },
            "singleLogoutService": {
                "url": f"{app_base_url}/saml/sls",
                "binding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            },
            "x509cert": open(os.path.join(app.config['SAML_PATH'], 'sp.crt')).read(),
            "privateKey": open(os.path.join(app.config['SAML_PATH'], 'sp.key')).read()
        },
        "idp": {
            "entityId": f"{keycloak_url}/realms/Mockbankrealm",
            "singleSignOnService": {
                "url": f"{keycloak_url}/realms/Mockbankrealm/protocol/saml",
                "binding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            },
            "x509cert": os.getenv('IDP_X509_CERT', '') 
        }
    }
    return OneLogin_Saml2_Auth(req, settings)

def prepare_flask_request(request):
    """Formats the Flask request for the SAML library."""
    return {
        'https': 'on' if request.scheme == 'https' else 'off',
        'http_host': request.host,
        'script_name': request.path,
        'get_data': request.args.copy(),
        'post_data': request.form.copy()
    }

@app.route('/')
def index():
    if 'samlUserdata' not in session:
        return '<h1>Teller Portal</h1><a href="/login">Login with Keycloak (SAML)</a>'
    
    return f"""
        <h1>Welcome, User</h1>
        <pre>{session['samlUserdata']}</pre>
        <a href="/logout">Logout</a>
    """

@app.route('/login')
def login():
    req = prepare_flask_request(request)
    auth = init_saml_auth(req)
    # Redirect to Keycloak
    return redirect(auth.login())

@app.route('/saml/acs', methods=['POST'])
def acs():
    req = prepare_flask_request(request)
    auth = init_saml_auth(req)
    
    auth.process_response()
    errors = auth.get_errors()
    
    if not errors:
        if auth.is_authenticated():
            session['samlUserdata'] = auth.get_attributes()
            session['samlNameId'] = auth.get_nameid()
            session['samlSessionIndex'] = auth.get_session_index()
            # Security: Masking NameID in logs to prevent PII leakage
            print(f"[SUCCESS] SAML User Authenticated (ID: {session['samlNameId'][:4]}***)")
            return redirect('/')
        else:
            return "SAML Authentication Failed", 401
    else:
        print(f"[ERROR] SAML Errors: {errors}")
        if auth.get_last_error_reason():
            print(f"[DEBUG] Reason: {auth.get_last_error_reason()}")
        return f"Errors: {', '.join(errors)}", 500

@app.route('/metadata')
def metadata():
    req = prepare_flask_request(request)
    auth = init_saml_auth(req)
    settings = auth.get_settings()
    metadata = settings.get_sp_metadata()
    errors = settings.validate_metadata(metadata)
    
    if len(errors) == 0:
        resp = make_response(metadata, 200)
        resp.headers['Content-Type'] = 'text/xml'
        return resp
    else:
        return f"Metadata Error: {', '.join(errors)}", 500

@app.route('/logout')
def logout():
    req = prepare_flask_request(request)
    auth = init_saml_auth(req)
    return redirect(auth.logout(
        name_id=session.get('samlNameId'),
        session_index=session.get('samlSessionIndex')
    ))

if __name__ == '__main__':
    # SAML implementation usually runs on port 5000 as per ACS mapping
    is_debug = os.getenv('FLASK_DEBUG', 'false').lower() == 'true'
    flask_host = os.getenv('FLASK_RUN_HOST', '0.0.0.0')
    print(f"[INFO] Starting Teller Portal SP on {flask_host}:5000 (Debug: {is_debug})...")
    app.run(host=flask_host, port=5000, debug=is_debug)
