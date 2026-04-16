# OIDC Implementation Guide (Python/Authlib)

**CLASSIFICATION: INTERNAL**

This document details the implementation of the OIDC Authorization Code Flow with PKCE for the `retail-app`.

## 1. Architecture Overview
The implementation uses the **Authlib** library to manage the OIDC handshake. PKCE (Proof Key for Code Exchange) is enforced to secure the public client flow.

## 2. Component Breakdown

### Configuration (`src/config/oidc.py`)
*   **Discovery:** Uses `server_metadata_url` to fetch Keycloak's `.well-known/openid-configuration`.
*   **Registration:** Registers the `retail-app` with `code_challenge_method: 'S256'` to ensure PKCE compliance.

### Application Logic (`src/app.py`)
*   **Login Initiation (`/login`):** Generates the code verifier/challenge and redirects the user to the Keycloak authorization endpoint.
*   **Callback Handling (`/auth/callback`):** 
    *   Exchanges the authorization code for tokens.
    *   Captures the raw `access_token` (JWT).
    *   Decodes the JWT claims (using `PyJWT`) to establish the user session.

## 3. Security Considerations
*   **PKCE:** Mandatory for this public client. The `code_verifier` is stored in the encrypted Flask session.
*   **JWT Validation:** Current implementation decodes claims for visibility. In production, signature verification against Keycloak's JWKS is required.
*   **Secret Management:** `SESSION_SECRET` must be sourced from GCP Secret Manager in deployed environments.

## 4. Verification
To test the implementation locally:
```bash
export KEYCLOAK_ISSUER_URL="https://<KEYCLOAK_URL>/realms/Mockbankrealm"
export SESSION_SECRET="dev-only-secret"
python src/app.py
```
Visit `http://localhost:3000/login` to trigger the flow.
