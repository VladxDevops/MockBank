# Security Policy - Project 1

**CLASSIFICATION: INTERNAL**

## 1. Identity Management
*   **Root Access:** The `master` realm is for infrastructure administration only. No business applications should be registered in `master`.
*   **Admin Console:** Must be protected by MFA immediately after initial setup.

## 2. Database Security
*   **Encryption:** Cloud SQL is encrypted at rest.
*   **Connection:** Keycloak connects to Cloud SQL via Private IP only. No public IP is assigned to the database instance.

## 3. Token Security
*   **OIDC:** Access Tokens must have a lifespan of < 15 minutes.
*   **Refresh Tokens:** Must be rotated on use.
*   **SAML:** Assertions must be signed and encrypted.

## 4. Secrets
*   Database credentials are injected at runtime via GCP Secret Manager.
*   No credentials exist in the `Dockerfile` or source code.

*Refer to `../../Documentation/internal/SECURITY.md` for the global security directive.*
