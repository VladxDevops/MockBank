import os
import google.auth.transport.requests
import google.oauth2.id_token

def get_gcp_identity_token(audience=None):
    """
    Retrieves a GCP Identity Token for authenticating against private Cloud Run services.
    
    Args:
        audience (str): The base URL of the target service. 
                        Defaults to the KEYCLOAK_URL environment variable.
    
    Returns:
        str: The Identity Token string, or None if acquisition fails.
    """
    target_audience = audience or os.getenv("KEYCLOAK_URL")
    
    if not target_audience:
        return None

    try:
        # auth_req is used to handle the token refresh logic
        auth_req = google.auth.transport.requests.Request()
        
        # fetch_id_token automatically detects credentials via the Metadata Server
        # on GCP or local Application Default Credentials (ADC).
        return google.oauth2.id_token.fetch_id_token(auth_req, target_audience)
    except Exception as e:
        # Log warning but allow the application to attempt unauthenticated 
        # requests (useful if running via the gcloud proxy locally).
        return None
