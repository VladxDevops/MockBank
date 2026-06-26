# INTERNAL: Identity Service Testing Protocol

**CLASSIFICATION: INTERNAL USE ONLY**

## Architectural Context
The `test-keycloak.sh` script is the authoritative tool for validating the "Security First" posture of the Keycloak deployment. It operates across the VPC boundary by utilizing the `gcloud run services proxy` command, allowing administrative validation without exposing the service to the public internet.

## Security Protocols

### 1. Secret Handling
*   **Dynamic Fetching:** The script never stores the `keycloak-admin-password`. It utilizes `gcloud secrets versions access` to pull the password into an ephemeral variable at runtime.
*   **Zero-Persistence:** Admin tokens (`$TKN`) are held only in memory and are not logged or written to disk.
*   **Leak Prevention:** The `fetch_logs` function uses strict `grep` patterns to avoid accidentally ingesting PII or session tokens into the troubleshooting output.

### 2. Validation Logic (Declarative Verification)
The script enforces the **Declarative Configuration Directive** by checking specific JSON path values in the Keycloak Admin API:
*   **PKCE Enforcement:** It verifies that `pkce.code.challenge.method` is set to `S256`. If this returns null or any other value, the validation fails, flagging a violation of the Security Policy.
*   **Realm Integrity:** It verifies that the `Mockbankrealm` matches the current version-controlled `realm-export.json`.

### 3. Cleanup & Isolation
*   **Trap Handling:** The script uses `trap cleanup_proxy EXIT` to ensure that the background proxy process is terminated regardless of script success, failure, or manual interruption (SIGINT). This prevents stale tunnels from consuming system resources or presenting a security risk.

## Operational SOP

### When to Execute
1.  **Post-Deployment:** Every Terraform apply affecting Project 1 must be followed by a Method 1 validation.
2.  **Configuration Changes:** Any update to `realm-export.json` must be verified using the `validate` argument of the script.
3.  **Incident Response:** Method 2 should be used to distinguish between Application-layer failures (Quarkus) and Infrastructure-layer failures (IAM/Cloud Run).

### Automated Integration
The script is designed for CI/CD compatibility. Use the following exit codes for pipeline gates:
*   `0`: All security and health checks passed.
*   `1`: Critical failure (IAM, Health, or Policy mismatch).

## Compliance Verification
| Requirement | Check Method |
| :--- | :--- |
| No Hardcoded Secrets | Verified (Secret Manager integration) |
| Private IP Routing | Verified (Method A Tunneling) |
| PKCE Enforcement | Verified (Admin API Query) |
| Least Privilege | Verified (IAM Token Validation) |

## CI/CD Proxy Troubleshooting & Fix Details (June 2026)

### 1. Root Cause Analysis
During CI/CD execution in the `configure-identity` job (`cd.yaml`), the step trying to establish the proxy tunnel to Keycloak (`gcloud run services proxy`) timed out. This occurred due to several combined issues:
* **Missing IAM Invoker Bindings**: The Keycloak Cloud Run service is deployed as private (`--no-allow-unauthenticated`). No explicit `google_cloud_run_service_iam_member` resource was defined in Terraform. As a result, the GitHub Actions WIF service account and the Terraform deployer service account lacked `roles/run.invoker` permissions. Further, when first added, the bindings lacked the explicit `project` argument, defaulting to the provider's default project configuration instead of the target project workspace.
* **Missing Token Creator Roles**: The active WIF service account (`sa-github-actions`) lacked `roles/iam.serviceAccountOpenIdTokenCreator` and `roles/iam.serviceAccountTokenCreator` roles. When `gcloud run services proxy` attempted to generate an OIDC token to authenticate requests, Google Cloud returned a `403 Forbidden` error with the message `Permission 'iam.serviceAccounts.getOpenIdToken' denied on resource`.
* **Multi-Line JSON Parsing Bug in curl Wait Loop**: The wait-loop logic in `cd.yaml` extracted the response body via `BODY=$(echo "$RESPONSE" | head -n 1)`. Quarkus/Keycloak returns multi-line formatted JSON. `head -n 1` extracted only the opening brace `{`, making `grep -q "UP"` fail even if the proxy and container were fully operational.
* **Process Cleanup Orphan Kill**: Leaving proxy startup and Terraform apply in separate workflow steps causes the runner to terminate the background proxy process at the end of the first step.

### 2. Actions Taken & Remediation
* **Explicit Project Variable for IAM**: Updated `google_cloud_run_service_iam_member` resources in `terraform/modules/project1/main.tf` to explicitly specify `project = var.compute_project_id`, ensuring they are configured on the correct target project.
* **Token Creator Privileges Granted**: Granted `roles/iam.serviceAccountOpenIdTokenCreator` and `roles/iam.serviceAccountTokenCreator` to the GitHub Actions service account (`sa-github-actions`) at the project level in `terraform/modules/project0/main.tf`.
* **IAM Privileges Added**: Declared the `github_actions_sa_email` variable and added explicit `google_cloud_run_service_iam_member` bindings to `terraform/modules/project1/main.tf` for both the Terraform deployer and the GitHub Actions WIF service accounts.
* **Multi-Line JSON Parsing Fix**: Updated the curl check in `cd.yaml` to search for `"UP"` across the entire response (`echo "$RESPONSE" | grep -q "UP"`) instead of slicing the first line.
* **Runner Process Preservation**: Added `RUNNER_TRACKING_ID: ""` to the environment variables of the `Start GCloud Proxy` step. This instructs the GitHub Actions runner to bypass process tracking for the background proxy tunnel, ensuring it is not killed when the step ends and remains available for the subsequent `Configure Identity` step.
* **Redundancy Cleanup**: Removed duplicate Terraform setup and apply blocks in `cd.yaml`.

---
*Refer to `Documentation/internal/SECURITY.md` for global policy alignment.*
---
