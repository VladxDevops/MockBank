import os
from pathlib import Path
import requests
import sys
import subprocess
from dotenv import load_dotenv
from google.auth.transport.requests import Request
from google.oauth2 import id_token
import google.auth

# Load environment variables from .env file using an absolute path
env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

def get_google_id_token(audience: str) -> str:
    """
    Generates an OIDC ID token for the specified audience.
    This is required to authenticate with Cloud Run services that have
    IAM-based ingress control enabled (no-allow-unauthenticated).
    """
    try:
        # Try the standard library first (works on Cloud Run/Service Accounts)
        auth_req = Request()
        return id_token.fetch_id_token(auth_req, audience)
    except Exception as e:
        # Fallback: Mirror the bash script logic for local development
        # This uses the gcloud CLI to get an identity token for the user account
        try:
            print(f"[DEBUG] Library fetch failed ({e}). Attempting gcloud fallback...")
            result = subprocess.run(
                ["gcloud", "auth", "print-identity-token", f"--audiences={audience}"],
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            print("[ERROR] Failed to obtain ID token via library or gcloud.")
            print("[INFO] Note: Standard User Accounts cannot generate tokens for specific audiences.")
            print("[TIP] Workaround: Run 'gcloud run services proxy' and point KEYCLOAK_URL to localhost.")
            print("[TIP] Ensure you are logged in: gcloud auth login")
            sys.exit(1)

def main():
    # Target URL should be the Cloud Run Service URL
    target_url = os.getenv("KEYCLOAK_URL")
    
    if not target_url:
        print("[ERROR] KEYCLOAK_URL environment variable is not set.")
        sys.exit(1)

    print(f"[INFO] Attempting authenticated request to: {target_url}")

    headers = {
        "Content-Type": "application/json"
    }

    # Skip token acquisition if using the local proxy or if a token is manually provided
    if target_url.startswith("http://localhost") or target_url.startswith("http://127.0.0.1"):
        print("[INFO] Localhost detected. Skipping Google ID token acquisition (Proxy mode).")
    else:
        token = os.getenv("GOOGLE_ID_TOKEN")
        if not token:
            # Replicating the 'test-keycloak.sh' logic
            # We use the base URL as the audience for IAM verification
            token = get_google_id_token(target_url)
        
        headers["Authorization"] = f"Bearer {token}"

    try:
        # Perform a simple health check against the Keycloak endpoint
        # Note: Unauthenticated attempts will fail with 403 at the GCP layer
        response = requests.get(f"{target_url}/health", headers=headers, timeout=10)
        response.raise_for_status()
        
        print(f"[SUCCESS] Status Code: {response.status_code}")
        print(f"[DATA] {response.text}")

    except requests.exceptions.HTTPError as err:
        print(f"[ERROR] HTTP Error: {err}")

if __name__ == "__main__":
    main()