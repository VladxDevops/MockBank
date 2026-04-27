import os
from authlib.integrations.flask_client import OAuth

oauth = OAuth()

def init_oidc(app):
    issuer_url = os.getenv('KEYCLOAK_ISSUER_URL')

    if not issuer_url:
        raise ValueError("Environment variable KEYCLOAK_ISSUER_URL is not set.")

    oauth.init_app(app)
    oauth.register(
        name='keycloak',
        client_id='retail-app',
        server_metadata_url=f"{issuer_url}/.well-known/openid-configuration",
        client_kwargs={
            'scope': 'openid profile email',
            'code_challenge_method': 'S256' # Enforces PKCE
        }
    )
    return oauth.keycloak
