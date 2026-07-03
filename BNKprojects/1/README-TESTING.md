# Keycloak Deployment Verification Guide

This document provides instructions for using the `test-keycloak.sh` script to validate the Identity Service (Project 1) deployment on Google Cloud Run.

## Prerequisites

Before running the script, ensure your local environment is configured:
1.  **GCP Authenticated:** Run `gcloud auth login` and `gcloud auth application-default login`.
2.  **Required Tools:** Ensure `curl`, `jq`, and `gcloud` (v450.0.0+) are installed.
3.  **Permissions:** You must have the `roles/run.invoker` and `roles/secretmanager.secretAccessor` roles on the target project.
    *   The Keycloak Cloud Run service is deployed as a private service, so it should not be bound to `allUsers` or unauthenticated access.
    *   In Terraform, the secure invoker binding is defined using the deployer/CI-CD service account, for example: `serviceAccount:${var.terraform_deployer_service_account}`.

## Getting Started

1.  **Navigate to the Project Directory:**
    ```bash
    cd "BNKprojects/1"
    ```
2.  **Configure Environment:**
    Copy the example environment file and fill in your specific resource IDs:
    ```bash
    cp test-env.sh.example test-env.sh
    ```
3.  **Make the script executable:**
    ```bash
    chmod +x test-keycloak.sh
    ```
4.  **Run the script:**
    ```bash
    ./test-keycloak.sh
    ```

## Testing Methods

The script offers two distinct validation paths:

### Method 1: Full Validation via GCloud Proxy (Internal)
*   **What it does:** Creates an authenticated tunnel to the private Cloud Run service.
*   **Validates:** 
    *   Quarkus `/health/live` status.
    *   Admin API accessibility.
    *   `Mockbankrealm` existence.
    *   `retail-app` client configuration (PKCE S256 enforcement).
*   **Use Case:** Deep health checks and configuration verification after a deployment or realm import.

### Method 2: External Health Check via IAM Token (Edge)
*   **What it does:** Simulates an external request using your GCP Identity Token.
*   **Validates:** 
    *   Cloud Run Ingress permissions.
    *   IAM Policy bindings for the service.
*   **Use Case:** Quick check to ensure the service is reachable and not returning 403 Forbidden to authorized users.

### Method 3: Comprehensive Validation (All)
*   **What it does:** Sequentially runs Method 2 then Method 1.
*   **Command:** 
    ```bash
    ./test-keycloak.sh all
    ```
*   **Use Case:** Full verification of a new deployment or after major configuration changes (e.g., Realm imports).

## Troubleshooting

If a check fails:
*   The script automatically fetches the last 100 lines of logs from Cloud Run, filtering for `ERROR`, `Exception`, or `Connection refused`.
*   **Common Issues:**
    *   **Proxy Timeout:** Ensure no other process is using port `8888`.
    *   **Token Failure:** Re-run `gcloud auth login`.
    *   **403 Forbidden:** Verify you have been granted the `roles/run.invoker` role for the `keycloak-service`.

---
### Method 4: Application OIDC Verification
*   **What it does:** Validates the end-to-end authentication cycle between the `retail-app` and Keycloak.
*   **Steps:**
    1.  Ensure environment variables (`KEYCLOAK_ISSUER_URL`, `SESSION_SECRET`) are set.
    2.  Start the application: `python src/app.py`.
    3.  Navigate to `http://localhost:3000/login`.
    4.  Verify OIDC handshake and token capture via application terminal logs.
*   **Validates:** 
    *   PKCE (S256) handshake.
    *   JWT Access Token capture.
    *   Claim extraction (username/roles).

---
**Classification: PUBLIC (Developer Reference)**
