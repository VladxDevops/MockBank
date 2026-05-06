# Release Safety Policy

**CLASSIFICATION: INTERNAL**

## 1. The Safety Mandate
No code shall reach the `PROD` environment without passing the full suite of automated safety gates.

## 2. Mandatory Safety Gates
1.  **Static Application Security Testing (SAST):** All application code must be scanned for vulnerabilities (e.g., hardcoded secrets, insecure libraries).
2.  **Infrastructure as Code (IaC) Validation:** Terraform plans must be linted and checked for compliance with the Zero-Trust network policy.
3.  **Functional Verification:** Service-specific verification scripts (e.g., `test-keycloak.sh`) must return `200 OK` across all critical endpoints.
4.  **No Unauthenticated Ingress:** Verification scripts must confirm that services are NOT reachable via `allUsers`.

## 3. Environment Promotion
*   **DEV to TEST:** Promotion requires a 100% pass rate on unit tests and successful deployment to the `DEV` environment.
*   **TEST to PROD:** Promotion requires a signed-off manual approval and a successful "Green" run of the integration test suite in the `TEST` environment.

## 4. Rollback Protocol
*   **Automatic:** If a Cloud Run revision fails its `startup_probe` or `liveness_probe`, traffic is never shifted to the new revision.
*   **Manual:** In the event of a post-deployment logic failure, the pipeline must support a single-click "Revert to Last Stable" command.

## 5. Audit Trail
Every deployment, including the results of all safety gates and the identity of the approver, must be logged in the permanent audit trail (Cloud Logging).

---
*This document is a formal directive. Violations are treated as security incidents.*
```


