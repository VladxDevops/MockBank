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

---
*Refer to `Documentation/internal/SECURITY.md` for global policy alignment.*
---
