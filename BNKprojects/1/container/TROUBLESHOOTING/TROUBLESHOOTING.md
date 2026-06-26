# Keycloak on Cloud Run - Troubleshooting Guide

We are deploying using Linux. 

**CLASSIFICATION: INTERNAL**

This document details common deployment failures encountered when running Keycloak (Java/Quarkus) on Google Cloud Run and how to resolve them.

## 1. Error: "Container failed to start" (`Ready:False`)

**Log Message:** `The user-provided container failed to start and listen on the port defined provided by the PORT=8080...`

This is a generic error from Cloud Run. You must open the **Logs** tab to find the root cause. Below are the specific scenarios we have encountered.

### Scenario A: Java Out of Memory (OOM)
*   **Symptom:** Logs stop abruptly. Search for `memory` or `kill` in logs often reveals nothing specific, but the container dies during initialization.
*   **Cause:** Keycloak is a Java application. The default Cloud Run memory limit (`512Mi`) is insufficient for the JVM.
*   **Fix:** Increase resources in Terraform (`main.tf`).
    ```hcl
    resources {
      limits = {
        memory = "2Gi"   # Minimum recommended
        cpu    = "2000m" # 2 vCPUs recommended for faster startup
      }
    }
    ```

### Scenario B: IAM Permission Denied
*   **Symptom:** Logs show `Failed to fetch secret` or `Cloud SQL Auth Proxy: access denied`.
*   **Cause:** The Service Account assigned to the Cloud Run revision does not have the required permissions.
*   **Fix:** Ensure the Service Account has:
    *   `roles/secretmanager.secretAccessor` (To access `keycloak-db-password`).
    *   `roles/cloudsql.client` (To connect via the Cloud SQL Auth Proxy sidecar).

### Scenario C: Strict Hostname Verification
*   **Symptom:** Container crashes with `java.net.UnknownHostException` or Keycloak errors regarding invalid redirect URIs during startup.
*   **Cause:** `KC_HOSTNAME_STRICT=true` is set in the Dockerfile, but Cloud Run assigns a dynamic URL (`*.run.app`) that is unknown at build time.
*   **Fix:** Disable strict checking until a custom domain is configured.
    *   **Terraform:** Set env var `KC_HOSTNAME_STRICT` = `"false"`.

### Scenario D: Startup Probe Timeout
*   **Symptom:** `Default STARTUP TCP probe failed 1 time consecutively`.
*   **Cause:** Either the JVM is slow to warm up, or the `/health/live` endpoint is returning a `404` because health checks are disabled.
*   **Fix:** 
    1. Ensure `KC_HEALTH_ENABLED=true` is set **during the build phase** in the Dockerfile. In optimized mode, runtime env vars for health are often ignored if not baked in.
    2. Verify the config inside the container: `kc.sh show-config | grep health`.
    3. Tune the probe in Terraform to be patient:
    ```hcl
    startup_probe {
      initial_delay_seconds = 60
      period_seconds        = 10
      failure_threshold     = 20 # Allow up to 260s total
    }
    ```

### Scenario E: Container Exits with Help Menu (Exit 0)
*   **Symptom:** Logs show `Container called exit(0)` followed by the Keycloak usage instructions (`Examples: start, start-dev, build...`).
*   **Cause:** The container entrypoint (`kc.sh`) is being called without arguments, or arguments are duplicated between the Dockerfile and Terraform.
*   **Fix:** Ensure the startup command (`start --optimized`) is defined in **either** the Dockerfile `ENTRYPOINT` or the Terraform `args`, but not both. Duplication causes the CLI parser to fail.

### Scenario F: Database Vendor Mismatch (H2 vs Postgres)
*   **Symptom:** Logs show `ERROR: URL format error; must be "jdbc:h2:..." but is "jdbc:postgresql://..."`.
*   **Cause:** Keycloak is using the H2 driver to parse a Postgres URL. This happens if the image was not built with `KC_DB=postgres` or if the `--optimized` flag is ignoring runtime environment variables because the build-time vendor was H2.
*   **Fix:** 
    1. Ensure `ENV KC_DB=postgres` is set in the `builder` stage of the `Dockerfile`.
    2. **Crucial:** Use a unique tag (e.g., `v1`) for your custom image. If you use the same tag as the base image (`24.0.1`), Cloud Run may pull the unoptimized base image from the registry instead of your custom one.
    3. Update `main.tf` to point to the new tag.
    4. **Command:**
       `gcloud builds submit --tag us-south1-docker.pkg.dev/PROJECT_ID/REPO/keycloak:v1 .`


## 2. Local Development Errors

### Scenario: Docker Entrypoint Conflict
*   **Symptom:** `docker-compose up` fails immediately. Logs show confusing argument errors.
*   **Cause:**
    *   `Dockerfile` has `ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]`.
    *   `docker-compose.yaml` has `command: ["start-dev"]`.
    *   **Result:** Docker runs `/opt/keycloak/bin/kc.sh start --optimized start-dev`, which is invalid.
*   **Fix:**
    *   Remove `command` in `docker-compose.yaml` to use the image's default.
    *   OR, override `entrypoint` in `docker-compose.yaml` to `/bin/sh` or just the script path if you need custom args.

## 3. Critical Troubleshooting Steps

If the deployment still fails after applying the dependencies:

*   **Check for "Exec Format Error":** If you built your custom Keycloak image on an Apple Silicon (M1/M2) Mac, you must ensure you used the `--platform linux/amd64` flag. If not, the container will crash instantly on Cloud Run with an "exec format error," which results in the exact `Ready:False` behavior you see.
*   **Inspect Application Logs:** The audit log you provided shows the infrastructure event. To see why the Java application crashed, you need to view the stdout/stderr logs of the container. Run this command:
    ```bash
    # View logs and filter for critical errors
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=keycloak-service" --limit 100 --format="value(textPayload)" | grep -Ei "FATAL|Exception|Connection refused|exec format error|Permission denied"
    ```
    *Note: If this returns nothing, run the command without the grep to see raw container output.*
*   **VPC Connector Verification:** Ensure the VPC connector `avechector` is in the same VPC as the Cloud SQL instance and that the VPC has Private Services Access configured. Since your DB has `ipv4_enabled = false`, it is 100% dependent on the VPC connector functioning correctly to reach the private IP of the database.
    Look specifically for `FATAL`, `Exception`, or `Connection refused` messages.
    *Note: Using `-E` enables extended regex for multiple patterns, and `-i` ensures the search is case-insensitive.*
*   **VPC Connector Verification:** Ensure the VPC connector `avechector` is in the same VPC as the Cloud SQL instance and that the VPC has Private Services Access configured. Since your DB has `ipv4_enabled = false`, it is 100% dependent on the VPC connector functioning correctly to reach the private IP of the database.
### Scenario G: 403 Forbidden (Working as Intended)
*   **Symptom:** Browser shows `Error: Forbidden. Your client does not have permission to get URL / from this server.`
*   **Cause:** The Cloud Run service was deployed without the `--allow-unauthenticated` flag. This is the correct secure baseline for the Bank platform.
*   **Fix/Workaround:** 
    1. **To access for administration (Developer Access):** Grant yourself the invoker role: Status: DONE. 
       ```bash
       gcloud run services add-iam-policy-binding keycloak-service \
         --member="user:YOUR_EMAIL@example.com" \
         --role="roles/run.invoker" \
         --region us-south1
       ```
    *   **If `localhost:8080` refuses connection:**
        *   Check if another process is using the port: `lsof -i :8080` (Linux/Mac) or `netstat -ano | findstr :8080` (Windows). (NOT NEEDED)
        *   Look at the `gcloud proxy` terminal output; it may have automatically selected a different port (e.g., 8081).
        *   Try using the explicit IP: `http://127.0.0.1:8080`.

    *   **Special Case: GCP Cloud Shell Port 8080 Conflict:**
        *   Cloud Shell uses 8080 for its own web preview proxy, causing `ERR_CONNECTION_REFUSED`.
        *   **Fix:** Run the proxy on a different port:
          ```bash
          gcloud run services proxy keycloak-service --region us-south1 --port 8888
          ```
        *   Then use the **Web Preview** button in Cloud Shell and select "Change port" to 8888. (This is the FIX)
        *   Then use the **Web Preview** button in Cloud Shell and select "Change port" to 8888.
        *   **Hang/Loading Issue:** If the UI hangs on "Loading the Admin UI", verify health via terminal: `curl http://localhost:8888/health/live`. If health is 200, perform a hard refresh (`Ctrl+F5`) to bypass Cloud Shell proxy caching.
        *   **Collecting Browser Logs (F12):** 
            1. Open **Console** tab -> Right-click -> **Save as...** to export all logs.
            2. Open **Network** tab -> Look for red entries -> Right-click -> **Copy as cURL**. 
            *Note: "Copy as cURL" is essential for identifying if the proxy is misconfiguring the `Host` or `X-Forwarded-Proto` headers.*

### Scenario I: Startup Probe Failure after Update
*   **Symptom:** `gcloud run services update` returns `The user-provided container failed the configured startup probe checks`.
*   **Cause:** Often a syntax error in the `--set-env-vars` string or an OIDC/DB configuration conflict triggered by the new revision.
*   **Diagnostic:** Run the following to see the crash reason:
    ```bash
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=keycloak-service" --limit 50 --format="value(textPayload)"
    ```
*   **Fix 1:** Ensure you do **not** mix `--set-env-vars` and `--update-env-vars`. Use only `--update-env-vars` to modify specific settings while preserving others.
*   **Fix 2:** If logs show `KC_HTTP_CONTENT_SECURITY_POLICY` parsing errors, ensure the entire string is wrapped in single quotes within your shell command to protect the internal semicolons.
*   **Symptom 2:** Logs show `ERROR: Strict hostname resolution configured but no hostname setting provided`.
*   **Cause:** The `KC_HOSTNAME_STRICT=false` variable was missing from the update command or the environment.
*   **Fix:** Always include `KC_HOSTNAME_STRICT=false` when updating environment variables manually via CLI to prevent Keycloak from reverting to strict production defaults.
*   **Symptom 3:** `java.sql.SQLException: Acquisition timeout while waiting for new connection`.
*   **Cause:** Common during "Cold Starts" or resource-heavy re-deployments.
*   **Fix:** If this persists, increase the `KC_DB_POOL_MAX_SIZE` (default is 100) or check the VPC Connector status.
*   **Symptom 4:** `ERROR: Connection to localhost:5432 refused`.
*   **Cause:** The database connection variables (`KC_DB_URL`, etc.) were wiped during a manual `gcloud run services update` using the `--set-env-vars` flag.
*   **Fix:** Restore the connection variables using `--update-env-vars`. **Verified Solution:** Use the direct Private IP of the Cloud SQL instance: `jdbc:postgresql://<PRIVATE_IP>:5432/keycloak`.

### Scenario H: CSP / Iframe Timeout in Cloud Shell
*   **Symptom:** Console shows `Framing violates CSP directive: "frame-src 'self'"` or `Timeout when waiting for 3rd party check iframe`.
*   **Cause:** Keycloak's default security headers prevent it from being loaded within the Cloud Shell Web Preview proxy.
*   **Fix:** Add the following environment variable to the Cloud Run service to allow the Cloud Shell domain:
    ```bash
    KC_HTTP_CONTENT_SECURITY_POLICY="frame-src 'self' https://*.devshell.appspot.com; frame-ancestors 'self' https://*.devshell.appspot.com;"
    ```
*   **Security Warning:** This should only be applied to DEV environments. For PROD, the `frame-ancestors` should be strictly limited to the actual Bank Portal domains.

    2. **To access via Proxy (Recommended for local dev):**
       ```bash
       gcloud run services proxy keycloak-service --region us-south1
       ```
       Then navigate to `http://localhost:8080`.
    3. **Transition to OIDC (Public Access):** When the `retail-app` needs to redirect users for login, the service will eventually require public access, but this should be gated by Cloud Armor in a production-ready environment.

### Scenario J: State Conflict / "Resource Already Exists" (409 Conflict)
*   **Symptom**: `terraform apply` fails with `Error 409: Service account xxx already exists` or `Workload Identity Pool xxx already exists`.
*   **Cause**: Terraform state divergence. The resource exists in GCP but is missing from the local/GCS state file (common after manual console actions or failed imports).
*   **Fix**: Use the `import_project0.sh` script (or manual `terraform import`) to force-align the state with the live GCP ID.
    ```bash
    terraform import module.project0.google_service_account.xxx projects/PROJECT_ID/serviceAccounts/xxx@...
    ```

### Scenario K: Secret Manager 404 / "Not Found" on Version Creation
*   **Symptom**: `Error creating SecretVersion: got HTTP response code 404... /v1/secret-name:addVersion?alt=json was not found`.
*   **Cause**: The Terraform provider is defaulting to the wrong project context or cannot find the parent secret because only the short-name ID was provided.
*   **Fix**: Reference the **full resource ID** (passed via module outputs) in the `secret` attribute of the version resource to ensure absolute anchoring.
    ```hcl
    secret = module.project0.secret_id # Resolves to projects/P/secrets/S
    ```

### Scenario L: Startup Probe Failure (Ready:False) after Networking Success
*   **Symptom**: Cloud Run shows `Ready:False` with `HealthCheckContainerError` despite VPC and DB connection variables being correct.
*   **Cause**: Application-layer initialization failure (e.g., database password mismatch after random_password regeneration) or SSL handshake hangs.
*   **Fix**: 
    1. Temporarily append `?sslmode=disable` to the `KC_DB_URL` to rule out SSL handshake issues.
    2. Increase `initial_delay_seconds` (120+) and `failure_threshold` (30+) in the `startup_probe` configuration.
    3. Check stdout/stderr logs in Cloud Console for `Access denied` errors or database connection timeouts.

### Scenario M: 403 Forbidden after Manual SQL Instance Deletion
*   **Symptom:** `terraform plan` or GitHub Actions fails with `Error 403: Forbidden` when refreshing the state of Cloud SQL databases or users.
*   **Cause:** The parent SQL instance was manually deleted from the GCP Console. Terraform's state still tracks child resources (database, user) and fails when trying to read them from a non-existent parent.
*   **Fix:** 
    1. Select the correct workspace (e.g., `projectZERO`).
    2. Manually remove the ghost resources from the state:
       ```bash
       terraform state rm module.project1.google_sql_database.keycloak_schema
       terraform state rm module.project1.google_sql_user.keycloak_user
       terraform state rm module.project1.google_sql_database_instance.keycloak_db
       ```
    3. Taint the random suffix to force a new instance name (avoids the name reuse cooldown):
       ```bash
       terraform taint module.project1.random_id.database_name_suffix
       ```
    4. Re-run `terraform apply`.

### Scenario N: JDBC Connection Failure (SCRAM Auth Error)
*   **Symptom:** Logs show `Failed to obtain JDBC connection` and `The server requested SCRAM-based authentication, but no password was provided`.
*   **Cause:** Incorrect environment variable names for the database password in the Cloud Run configuration. Keycloak Quarkus (v24+) requires `KC_DB_PASSWORD`.
*   **Fix:** Ensure the following environment variable names are correctly set in `main.tf`:
    - **Database Password:** `KC_DB_PASSWORD` (NOT `KC_DATABASE_PASSWORD`).
    - **Admin Password:** `KEYCLOAK_ADMIN_PASSWORD` (NOT `KEYCLOAK_ADMINISTRATOR_PASSWORD`).

### Scenario O: CI/CD Proxy Health Check Timeout
*   **Symptom:** The `configure-identity` job in GitHub Actions hangs or exits with `ERROR: Proxy or Keycloak health check timed out. Error: Process completed with exit code 1.`
*   **Cause:** This error is caused by a combination of:
    1. **Missing Invoker IAM Roles**: The private Keycloak Cloud Run service does not have IAM invoker permissions configured for the WIF or deployer service accounts, leading to a `403 Forbidden` response.
    2. **Multi-line JSON Parsing**: The curl check previously used `head -n 1` to extract the body. Keycloak health check responses are multi-line JSON, so `head -n 1` gets `{` instead of the status line containing `"UP"`.
    3. **Runner Process Cleanup**: The GitHub Actions runner terminates background processes spawned in a step when that step finishes, killing the proxy tunnel.
*   **Fix:**
    1. Define the `google_cloud_run_service_iam_member` resource in Terraform to grant the `roles/run.invoker` role to both the WIF/CI/CD service account and the Terraform deployer service account.
    2. Update the curl health check validation in `cd.yaml` to search for `"UP"` across the entire response (`grep -q "UP"`) instead of just `head -n 1`.
    3. Add `RUNNER_TRACKING_ID: ""` to the environment variables of the proxy startup step in `cd.yaml` to allow the background process to persist across steps.