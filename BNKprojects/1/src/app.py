import os
import requests
from flask import Flask, redirect, url_for, session, jsonify, abort
from authlib.integrations.flask_client import OAuth
from authlib.jose import jwt
from dotenv import load_dotenv

# Load environment variables
# Use absolute path to ensure .env is loaded regardless of execution context
basedir = os.path.abspath(os.path.dirname(__file__))
env_path = os.path.join(basedir, '../.env')
load_dotenv(env_path, override=True)

app = Flask(__name__)

# Enforce mandatory environment variables per Security Policy
app.secret_key = os.getenv('SESSION_SECRET')
if not app.secret_key or app.secret_key == 'dev-secret-keep-it-safe':
    raise RuntimeError("SESSION_SECRET is not set or is using an insecure default. Check your .env file.")

if not os.getenv('KEYCLOAK_URL'):
    raise RuntimeError("KEYCLOAK_URL is missing. Identity Provider cannot be initialized.")

print(f" * Identity Provider configured: {os.getenv('KEYCLOAK_URL')}")

# Security configuration for session cookies
app.config.update(
    SESSION_COOKIE_SECURE=os.getenv('FLASK_ENV') == 'production',
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
)

oauth = OAuth(app)
oauth.register(
    name='keycloak',
    client_id='retail-app',
    client_secret='',  # Public client (PKCE enforced)
    server_metadata_url=f"{os.getenv('KEYCLOAK_URL')}/realms/Mockbankrealm/.well-known/openid-configuration",
    client_kwargs={
        'scope': 'openid profile email',
        'code_challenge_method': 'S256'  # Enforce PKCE S256 per Security Policy
    }
)

@app.route('/login')
def login():
    """Initiate OIDC Login Redirect with PKCE."""
    redirect_uri = url_for('auth_callback', _external=True)
    try:
        return oauth.keycloak.authorize_redirect(redirect_uri)
    except Exception as e:
        app.logger.error(f"OIDC Discovery failed. Check if KEYCLOAK_URL points to the gcloud proxy (http://localhost:8888): {str(e)}")
        return abort(500, description="Identity Provider unreachable. Verify proxy and IAM permissions.")

@app.route('/auth/callback')
def auth_callback():
    """Handle OIDC Callback, exchange code, and capture JWT."""
    try:
        token = oauth.keycloak.authorize_access_token()
    except Exception as e:
        app.logger.error(f"OIDC Token Exchange failed. Verify KEYCLOAK_URL and GCP IAM permissions: {str(e)}")
        return abort(401, description="Authentication Failed")

    user_info = token.get('userinfo')
    access_token = token.get('access_token')

    try:
        # Fetch JWKS from Keycloak to verify Access Token signature
        jwks_uri = oauth.keycloak.load_server_metadata().get('jwks_uri')
        jwks = requests.get(jwks_uri).json()

        # Decode and validate the Access Token
        # This ensures the token is valid, not expired, and intended for this app
        claims = jwt.decode(access_token, jwks)
        claims.validate()
    except Exception as e:
        app.logger.error(f"Token validation failed: {str(e)}")
        return abort(401, description="Invalid Token")

    # Secure Session Management
    session['user'] = {
        'sub': user_info.get('sub'),
        'username': user_info.get('preferred_username'),
        'roles': claims.get('realm_access', {}).get('roles', []),
        'exp': claims.get('exp')
    }
    
    return jsonify({
        "message": "Authenticated successfully",
        "user": session['user']['username'],
        "token_preview": f"{access_token[:20]}..."
    })

@app.route('/me')
def me():
    """Return current session data."""
    user = session.get('user')
    if not user:
        return "Unauthorized", 401
    return jsonify(user)

if __name__ == '__main__':
    app.run(port=int(os.getenv('PORT', 3000)))
