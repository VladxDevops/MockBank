import os
from flask import Flask, redirect, url_for, session, jsonify
from authlib.integrations.flask_client import OAuth
from authlib.jose import jwt
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SESSION_SECRET', 'dev-secret-keep-it-safe')

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
    return oauth.keycloak.authorize_redirect(redirect_uri)

@app.route('/auth/callback')
def auth_callback():
    """Handle OIDC Callback, exchange code, and capture JWT."""
    token = oauth.keycloak.authorize_access_token()
    user_info = token.get('userinfo')
    access_token = token.get('access_token')

    # Decode Access Token to extract realm roles (RBAC)
    # Verification was performed by authorize_access_token() via server metadata
    claims = jwt.decode(access_token, oauth.keycloak.load_server_metadata().get('jwks_uri'))
    claims.validate()

    # Secure Session Management
    session['user'] = {
        'sub': user_info.get('sub'),
        'username': user_info.get('preferred_username'),
        'roles': claims.get('realm_access', {}).get('roles', []),
        'auth_time': user_info.get('iat')
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
