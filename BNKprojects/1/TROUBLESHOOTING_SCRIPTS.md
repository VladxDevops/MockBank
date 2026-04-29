# Troubleshooting: test-keycloak.sh

**CLASSIFICATION: INTERNAL**

This document provides solutions for issues encountered when running the automated verification script `test-keycloak.sh`.

## 1. Script Fails to Start
*   **Error:** `Permission denied`
    *   **Fix:** Ensure the script has execution permissions: `chmod +x test-keycloak.sh`.
*   **Error:** `Environment file test-env.sh not found`
    *   **Fix:** Ensure `test-env.sh` exists in the same directory. This file is ignored by git; it must be created manually or retrieved from Secret Manager.

## 2. Dependency Issues
*   **Error:** `jq: command not found` or `curl: command not found`
    *   **Fix:** Install the missing binary. In Cloud Shell, these are pre-installed. In local Linux environments, use `sudo apt install jq curl`.

## 3. Proxy Failures (Method A)
*   **Symptom:** Script hangs at `Waiting for proxy to initialize...` and then fails.
    *   **Cause:** The `gcloud` proxy might be blocked by a local firewall or a port conflict on `8888`.
    *   **Fix:** Check if the port is in use: `lsof -i :8888`. If it is, change the `PROXY_PORT` in `test-env.sh`.
*   **Symptom:** `GCloud Proxy (PID: XXXX) cleanup failed`.
    *   **Fix:** Manually kill any orphaned proxy processes: `pkill -f "gcloud run services proxy"`.

## 4. Authentication Failures
*   **Symptom:** `Keycloak Admin Token fetch failed`.
    *   **Cause:** Incorrect credentials in `test-env.sh` or the `keycloak-admin-password` secret in GCP has been rotated but not updated locally.
    *   **Fix:** Verify credentials against GCP Secret Manager: `gcloud secrets versions access latest --secret="keycloak-admin-password"`.

## 5. Debug Mode
If the script is behaving unexpectedly, run it in debug mode to see every command being executed:
```bash
bash -x ./test-keycloak.sh validate
```

---
*Standard Operating Procedure: Document every script failure mode here to prevent engineering toil.*
# Troubleshooting: test-keycloak.sh

**CLASSIFICATION: INTERNAL**

This document provides solutions for issues encountered when running the automated verification script `test-keycloak.sh`.

## 1. Script Fails to Start
*   **Error:** `Permission denied`
    *   **Fix:** Ensure the script has execution permissions: `chmod +x test-keycloak.sh`.
*   **Error:** `Environment file test-env.sh not found`
    *   **Fix:** Ensure `test-env.sh` exists in the same directory. This file is ignored by git; it must be created manually or retrieved from Secret Manager.

## 2. Dependency Issues
*   **Error:** `jq: command not found` or `curl: command not found`
    *   **Fix:** Install the missing binary. In Cloud Shell, these are pre-installed. In local Linux environments, use `sudo apt install jq curl`.

## 3. Proxy Failures (Method A)
*   **Symptom:** Script hangs at `Waiting for proxy to initialize...` and then fails.
    *   **Cause:** The `gcloud` proxy might be blocked by a local firewall or a port conflict on `8888`.
    *   **Fix:** Check if the port is in use: `lsof -i :8888`. If it is, change the `PROXY_PORT` in `test-env.sh`.
*   **Symptom:** `GCloud Proxy (PID: XXXX) cleanup failed`.
    *   **Fix:** Manually kill any orphaned proxy processes: `pkill -f "gcloud run services proxy"`.

## 4. Authentication Failures
*   **Symptom:** `Keycloak Admin Token fetch failed`.
    *   **Cause:** Incorrect secret name or DB timeout.
    *   **Fix:** 
        1. Verify secret name is `keycloak-administrator-password` (NOT `keycloak-admin-password`).
        2. Check for `Acquisition timeout` in logs; if present, the database is overwhelmed.

## 6. JDBC Acquisition Timeouts
*   **Symptom:** Script warns about `db-f1-micro` and token fetch retries multiple times.
    *   **Cause:** The micro instance cannot handle the default JDBC pool size (100).
    *   **Fix:** Ensure the Cloud Run environment variable `KC_DB_POOL_MAX_SIZE` is set to `20`.

## 7. Variable Enforcement Errors
*   **Error:** `Required variable 'X' is not set in test-env.sh`.
    *   **Cause:** As of v1.8.9, the script prohibits hardcoded defaults. All variables in the `REQUIRED_VARS` array must be present in `test-env.sh`.
    *   **Fix:** Open `test-env.sh` and define the missing variable (e.g., `ADMIN_USERNAME="admin"`).

## 5. Debug Mode
If the script is behaving unexpectedly, run it in debug mode to see every command being executed:
```bash
bash -x ./test-keycloak.sh validate
```

---
*Standard Operating Procedure: Document every script failure mode here to prevent engineering toil.*

## 8. Python Auth Client (src/app.py)
*   **Symptom:** `[ERROR] Failed to obtain ID token via library or gcloud: ERROR: (gcloud.auth.print-identity-token) Invalid account type for --audiences.`
    *   **Status:** [IN PROGRESS]
    *   **Cause:** The `--audiences` flag requires an active Service Account identity. Standard user credentials cannot sign OIDC tokens for specific Cloud Run audiences locally.
    *   **Workaround:** 
        1. Start the proxy in a separate terminal: 
           `gcloud run services proxy keycloak-service --region us-south1 --port 8888`
        2. Update your `.env` to use the local proxy:
           `KEYCLOAK_URL=http://localhost:8888`
        3. The proxy will automatically inject the OIDC token from your `gcloud` session.
