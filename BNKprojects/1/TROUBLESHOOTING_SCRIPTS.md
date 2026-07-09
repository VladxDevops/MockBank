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

## 9. Admin Username Mismatches ("user_not_found" or "LOGIN_ERROR")
*   **Symptom:** Keycloak container logs report `type="LOGIN_ERROR", error="user_not_found"` when running the verification script (Option 1).
*   **Cause:** The admin username variable `ADMIN_USERNAME` in `test-env.sh` (usually defaulting to `"admin"`) does not match the actual administrative username configured during deployment (`KEYCLOAK_ADMIN` environment variable on Cloud Run).
*   **Fix:** Do not hardcode credentials. Instead, retrieve the active admin username from the deployed service via the following command, and update `ADMIN_USERNAME` in `test-env.sh` to match it:
    ```bash
    gcloud run services describe keycloak-service --region us-south1 --format="value(spec.template.spec.containers[0].env.KEYCLOAK_ADMIN)"
    ```

## 10. Missing Realm ("Mockbankrealm not found")
*   **Symptom:** Verification script output reports `ERROR: Realm 'Mockbankrealm' not found. Status: ERROR_NOT_FOUND`.
*   **Cause:** Following database maintenance, upgrades, or state cleanups (such as running `fix_sql_state.sh`), the database instance is recreated and starts completely empty. Keycloak initializes a fresh schema but does not import the custom realm because the CI/CD pipeline (`.github/workflows/cd.yaml`) replaces `realm-export.json` with a placeholder realm (`AltmtrkBank`) to prevent baking configuration or credentials into the container image.
*   **Fix:** Renamed reaml from AltmtrkBank to Mockbankrealm in cd.yaml. 
    Alternatively: Manually re-import the realm configuration using the Admin API via proxy:
    1. Update default user passwords in `realm-export.json` to be policy-compliant (see Scenario 11).
    2. Start the proxy and retrieve an administrative token (using the active admin username and password from Secret Manager).
    3. Import the realm using `curl`:
       ```bash
       # Extract the JSON object from the single-element array in realm-export.json
       jq '.[0]' realm-export.json > realm_import.json
       
       # POST the configuration to the Keycloak Admin API
       curl -X POST \
         -H "Authorization: Bearer $TKN" \
         -H "Content-Type: application/json" \
         -d @realm_import.json \
         "http://localhost:8888/admin/realms"
       ```

## 11. Realm Import Rejected ("Password policy not met")
*   **Symptom:** Importing the realm returns `HTTP/1.1 400 Bad Request` with `{"errorMessage":"Password policy not met. See logs for details"}`.
*   **Cause:** The `Mockbankrealm` definition contains a strict password policy: `length(8) and notUsername(true) and notEmail(true) and specialChars(1) and digits(1) and upperCase(1) and lowerCase(1)`. However, default test users (`adminadminadmin`, `teller`, `customer`) listed in `realm-export.json` are configured with simple passwords like `"password"`, causing the schema import validation to fail.
*   **Fix:** Update the passwords of the mock users in `realm-export.json` to a secure, compliant password string (e.g., `"P@ssword123"` which satisfies the minimum length, casing, digit, and special character checks) before performing the import. Do not use plain text default passwords that violate policies.

## 12. Proxy Connection Timeout (Cold Starts)
*   **Symptom:** Verification script fails with `ERROR: Proxy or Keycloak health check failed via proxy`.
*   **Cause:** Cloud Run is configured with a minimum instance count of `0`. When idle, the service scales down. Waking the container (cold start) and setting up database pools can take longer than the default 30-second wait loop in `test-keycloak.sh`.
*   **Fix:** Increase the connection timeout wait loop range in `test-keycloak.sh` (e.g., to `{1..90}` seconds) to allow the container sufficient time to perform a cold start and report health `UP`.

## 13. Terraform Provider 403 Forbidden Error (Keycloak Service Unreachable)

*   **Symptom:** Running `terraform plan -target=module.project3` (or `terraform apply` targeting Keycloak provider resources) fails with:
    ```
    Error: error initializing keycloak provider
    failed to perform initial login to Keycloak: error sending POST request to
    https://keycloak-service-[PROJECT_ID].us-south1.run.app/realms/master/protocol/openid-connect/token: 403 Forbidden
    ```

*   **Root Cause:** The Keycloak Cloud Run service is intentionally **private** (secure-by-default):
    - No public ingress allowed (no `--allow-unauthenticated` flag).
    - Requires caller to have `roles/run.invoker` IAM permission.
    - The Terraform keycloak provider (mrparkers/keycloak) immediately tries to authenticate when initializing.
    - If the provider is configured with the public Cloud Run URL and the caller lacks `roles/run.invoker`, Cloud Run returns `403 Forbidden`.

*   **Why This Is Not a Bug:** This is **architectural and cannot be eliminated**. The Keycloak service must remain private for security; exposing it publicly would compromise the Zero Trust platform design. The 403 error is the **correct, intended behavior**.

*   **Workaround (Required Every Time):**
    1. **Step 1:** In one terminal, create a local authenticated proxy tunnel:
       ```bash
       gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
       ```
       Wait for the message: `Proxy is successfully tunnelled to keycloak-service on http://127.0.0.1:8080`

    2. **Step 2:** In another terminal, run Terraform with the local proxy URL override:
       ```bash
       terraform plan \
         -var-file="dev.tfvars" \
         -var="keycloak_url=http://127.0.0.1:8080" \
         -var="bootstrap=false" \
         -target=module.project3
       
       terraform apply -auto-approve \
         -var-file="dev.tfvars" \
         -var="keycloak_url=http://127.0.0.1:8080" \
         -var="bootstrap=false" \
         -target=module.project3
       ```

*   **Key Parameters:**
    - `-var="keycloak_url=http://127.0.0.1:8080"` - Overrides the public HTTPS URL from `dev.tfvars` to use the local proxy.
    - `-var="bootstrap=false"` - Disables bootstrap mode (use real credentials instead of bootstrap placeholders).

*   **Why GitHub Actions Doesn't Need the Workaround:**
    - The CI/CD workflow (`.github/workflows/cd.yaml`) automatically starts the proxy in the `configure-identity` job.
    - The job passes `-var="keycloak_url=http://127.0.0.1:8080"` to Terraform.
    - Local developers must provide the same setup manually.

*   **Debugging:**
    - Verify IAM binding exists: `gcloud run services get-iam-policy keycloak-service --region us-south1 --format=json`
    - Check proxy is running: `curl http://127.0.0.1:8080/health/live` (should return `200 UP`)
    - See [ERROR_403_EXPLANATION.md](../../../ERROR_403_EXPLANATION.md) for comprehensive documentation.

## 14. Prevention Protocols (Operational Standards)
To prevent these authentication and configuration issues in future database migrations:
1. **Dynamic Environment Files:** Never commit or hardcode credentials. Generate the local testing `test-env.sh` dynamically using metadata from GCP (such as querying Cloud Run configuration and retrieving secrets from Secret Manager).
2. **Post-Recreation Checklist:** Whenever `terraform apply` or `fix_sql_state.sh` is executed to recreate the SQL instance, immediately execute the Keycloak realm import flow. Treat database recreation as a destructive task requiring active configuration seeding.
3. **Keep Passwords Policy-Compliant:** Always ensure default user records in the version-controlled `realm-export.json` contain credentials that meet the password complexity rules defined in the same realm.

## 15. Keycloak Identity Configuration via Cloud Build

If local Terraform configuration encounters `403 Forbidden` issues or network restrictions, you can utilize the secure [cloudbuild-keycloak.yaml](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/1/container/cloudbuild-keycloak.yaml) configuration to perform the bootstrapping process directly inside the GCP boundary.

*   **Command:**
    ```bash
    gcloud builds submit --config=BNKprojects/1/container/cloudbuild-keycloak.yaml \
      --substitutions=_SERVICE_NAME="keycloak-service",_REGION="us-south1",_STATE_BUCKET="terraform_state_bckup_bnk-project",_TERRAFORM_VERSION="1.5.7" \
      .
    ```
*   **Workflow Behavior:**
    1. Installs tools (`unzip`, `curl`, `jq`, `terraform` CLI) dynamically in the builder step container.
    2. Installs the `cloud-run-proxy` gcloud component.
    3. Spawns an authenticated proxy to route through the secure VPC/IAM perimeter.
    4. Health checks the Keycloak instance on localhost:8080 until it yields `200` with `"UP"`.
    5. Initializes and applies the `project3` Terraform module targeting the proxy endpoint.

