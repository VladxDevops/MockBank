# Keycloak Automated Testing (Project 1)

This directory contains the automated verification suite for the Identity Service (Project 1) running on Google Cloud Run.

## Files
- **`test-keycloak.sh`**: The primary testing orchestrator.
- **`test-env.sh`**: Configuration file for the testing script.
- **`test-env.sh.example`**: Template for creating `test-env.sh`.

## Usage

### 1. Preparation
Ensure you are authenticated with GCloud:
```bash
gcloud auth login
gcloud auth application-default login
```

### 2. Configuration
Copy the template and update the variables (especially `DB_INSTANCE_NAME` and `SERVICE_NAME`):
```bash
cp test-env.sh.example test-env.sh
chmod +x test-keycloak.sh
```

### 3. Execution
Run the script to see the menu, or use arguments for direct execution:

```bash
# Show interactive menu
./test-keycloak.sh

# Run comprehensive validation (IAM + Proxy)
./test-keycloak.sh all
```

## Testing Methods

### Method A: Proxy-based (Application Layer)
- **Script Command:** `./test-keycloak.sh method-a` (followed by `validate`)
- **Utility:** Uses `gcloud run services proxy` to create a tunnel to the private Cloud Run service. 
- **Validates:** Quarkus health endpoints, Admin API connectivity, Realm existence, and Client PKCE policies.

### Method B: IAM-based (Infrastructure Layer)
- **Script Command:** `./test-keycloak.sh method-b`
- **Utility:** Uses `gcloud auth print-identity-token` to simulate a direct authenticated request to the service URL.
- **Validates:** Cloud Run ingress permissions and IAM policy bindings.

## Troubleshooting
If tests fail, the script will automatically output the last 100 lines of container logs filtered for errors. Refer to [TROUBLESHOOTING_SCRIPTS.md](../TROUBLESHOOTING_SCRIPTS.md) for detailed workarounds:
- **403 Forbidden**: Check if the caller has `roles/run.invoker` permission.
- **JDBC Timeout**: Often occurs on `db-f1-micro` instances during startup.
- **Proxy Port**: Ensure no other process is using port `8888`.
- **LOGIN_ERROR / user_not_found**: Mismatch in administrative credentials. Refer to Section 9 of the troubleshooting guide.
- **Mockbankrealm not found (ERROR_NOT_FOUND)**: Upgraded database is empty. Refer to Section 10 of the troubleshooting guide to re-import the realm.
- **Password policy not met (400 Bad Request)**: Seed users have passwords violating realm policies. Refer to Section 11 of the troubleshooting guide.
- **Proxy connection timeouts**: Keycloak container is cold starting. Refer to Section 12 of the troubleshooting guide.
