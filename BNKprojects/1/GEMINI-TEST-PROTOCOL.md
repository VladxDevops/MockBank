# GEMINI SOP: Keycloak Automated Testing & Troubleshooting

**CLASSIFICATION: INTERNAL / AI-OPERATIONAL**

## 1. Objective
To provide Gemini Code Assist with a structured logic for executing `./test-keycloak.sh` and performing root-cause analysis based on script output and logs. Gemini is restricted to identifying failures; infrastructure modification (Terraform) is strictly out of scope.

## 2. Architectural Context (Project 1)
*   **Compute:** Cloud Run (Private Ingress).
*   **Database:** Cloud SQL via Serverless VPC Connector (Private IP).
*   **Security:** Secrets injected via Secret Manager; PKCE enforced on `retail-app`.
*   **Egress:** All traffic through Cloud NAT for static IP verification.

## 3. Execution Protocol
When instructed to "run the test script," Gemini must:
1.  **Verify Environment:** Check for `gcloud` authentication and project context.
2.  **Invoke Script:** Use `bash ./test-keycloak.sh all` for a full system audit, or specify a method if troubleshooting a specific layer.
3.  **Capture Streams:** Intercept both `STDOUT` and `STDERR`.

## 4. Automated Troubleshooting Logic
If the script returns a non-zero exit code, Gemini must parse the output against these failure signatures:

### A. Infrastructure Layer (IAM/Networking)
| Error Message | Likely Root Cause | Required Action |
| :--- | :--- | :--- |
| `403 Forbidden` | Missing `roles/run.invoker` or IAM Policy mismatch. | Audit `google_cloud_run_service_iam_member` in `main.tf`. |
| `Acquisition timeout` | `db-f1-micro` tier exhaustion. | Advise user of resource constraints; verify pool size is <= 20. |
| `Connection refused` | VPC Connector is down or Cloud Run Proxy failed. | Verify VPC Connector status and Port 8888 availability. |
| `Could not resolve host` | DNS/NAT Issue. | Check VPC Egress settings (`all-traffic`). |
| `Required variable not set` | Missing entry in `test-env.sh`. | Instruct user to add the missing variable to `test-env.sh`. |

### B. Application Layer (Quarkus/Keycloak)
| Error Message | Likely Root Cause | Required Action |
| :--- | :--- | :--- |
| `404 Not Found` on `/health` | `KC_HEALTH_ENABLED` set to `false` during build. | Refactor `Dockerfile` to include health in build-stage. |
| `Connection to localhost:5432` | Database URL mismatch or Private IP change. | Verify `KC_DB_URL` vs Cloud SQL Private IP. |
| `Secret NOT_FOUND` | Incorrect naming in script. | Ensure script uses `keycloak-administrator-password`. |
| `PKCE challenge null` | Realm drift in `Mockbankrealm`. | Re-apply `realm-export.json` via container build. |

## 5. Security Constraints
*   **No Manual Fixes:** Gemini must NEVER suggest using the Keycloak Admin UI to fix a failure. All corrections must be proposed as HCL (Terraform) or JSON (Realm Export) diffs.
*   **Log Sanitization:** If fetching logs for troubleshooting, Gemini must filter out `Set-Cookie`, `Authorization`, and `access_token` strings.
*   **Non-Root:** Ensure `USER keycloak` is maintained in any Dockerfile suggestions.

## 6. Feedback Loop
1.  Run `./test-keycloak.sh`.
2.  If fail: Run `gcloud logs read keycloak-service --limit 50`.
3.  Cross-reference logs with `BNKprojects/1/TROUBLESHOOTING.md`.
4.  Present the user with a **Root Cause Identification** and a **Declarative Fix**.

## 7. Cost Optimization Constraints
*   **NO RESOURCE UPSCALING:** Gemini CLI must NOT propose increasing Cloud Run CPU/Memory limits, Cloud SQL instance tiers, or storage capacity to resolve performance issues.
*   **NO IDLE COSTS:** Do not suggest setting `min-instances` > 0 or enabling "Always-on CPU" unless specifically requested for production traffic.
*   **LEAN DIAGNOSTICS:** Troubleshooting should rely on existing logs and free-tier command-line tools. Do not suggest enabling premium GCP features (e.g., Cloud Trace, Profiler) for standard health verification.

---
*Refer to `Documentation/internal/SECURITY.md` for the Prime Directive.*
---
