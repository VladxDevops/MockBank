# Keycloak on Cloud Run - Troubleshooting Guide

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
    1. Ensure `KC_HEALTH_ENABLED=true` is set in the environment.
    2. Verify the config inside the container: `kc.sh show-config | grep health`.
    3. Tune the probe in Terraform to be patient:
    ```hcl
    startup_probe {
      initial_delay_seconds = 30
      period_seconds        = 10
      failure_threshold     = 12 # Allow up to 120s total
    }
    ```

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