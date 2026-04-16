import os
import jwt
from flask import Flask, url_for, session, redirect, jsonify
from src.config.oidc import init_oidc

app = Flask(__name__)
app.secret_key = os.getenv('SESSION_SECRET', 'dev-secret-only')

keycloak = init_oidc(app)

@app.route('/login')
def login():
    redirect_uri = url_for('auth_callback', _external=True)
    # Authlib handles PKCE code_verifier/challenge generation automatically
    return keycloak.authorize_redirect(redirect_uri)

@app.route('/auth/callback')
def auth_callback():
    try:
        # STEP 3: Exchange code and validate PKCE verifier (handled by Authlib via session)
        token = keycloak.authorize_access_token()
        
        # STEP 4: Capture and Decode the JWT Access Token
        access_token = token.get('access_token') # This is the raw JWT string
        
        # Decode Access Token to get user context
        # In production, verify the signature using Keycloak's JWKS
        user_info = jwt.decode(access_token, options={"verify_signature": False})
        
        session['user'] = user_info
        session['jwt'] = access_token

        return jsonify({
            "status": "Logged In",
            "user": user_info.get('preferred_username'),
            "roles": user_info.get('realm_access', {}).get('roles', [])
        })
    except Exception as e:
        return f"Authentication failed: {str(e)}", 400

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

if __name__ == '__main__':
    app.run(port=3000, debug=True)
