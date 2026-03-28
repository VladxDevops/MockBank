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