# Project 0 (Foundation) Troubleshooting Log

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Overview
This document tracks the debugging steps, failed experiments, and successful resolutions encountered during the deployment of Project 0 (Foundational Infrastructure).

## 2. Status Log

### [2024-05-24] Provider Centralization & Proxy Issues
*   **Issue:** Terraform encountered "Provider Proxy" issues and authentication inconsistencies when providers were declared inside the `project0` module.
*   **Symptoms:** Authentication failures during complex deployments and difficulty managing CI/CD secrets.
*   **Attempted:** Keeping providers modularized within the sub-module.
*   **Result:** **FAILED**. Dependency leakage and scope issues occurred.
*   **Resolution:** Moved all provider declarations (`google`, `mongodbatlas`, `keycloak`) to the root `terraform/` directory. This ensures a consistent authentication context across the entire workspace.

### [2024-05-24] API Enablement vs. Secret Validation (Bootstrap)
*   **Issue:** A "chicken and egg" problem where Terraform tries to validate Secret Manager resources before the Secret Manager API is fully enabled.
*   **Symptoms:** `Error: Google Cloud Secret Manager API has not been used in project...` during the initial `apply`.
*   **Resolution:** Implemented a `bootstrap` variable at the root level.
    *   **Step taken:** Used `-var="bootstrap=true" -target=google_project_service.gcp_services`.
    *   **Outcome:** Allows APIs to be enabled first, skipping resource validation that requires those APIs.

### [2026-05-28] Service Account Propagation
*   **Issue:** Occasional 400 Bad Request or 403 Forbidden errors when performing IAM bindings immediately after service account creation.
*   **Symptoms:** `Error: Identity 'service-ACCOUNT@PROJECT.iam.gserviceaccount.com' does not exist.`
*   **Resolution:** Implemented a retry strategy. Allowing 60-120 seconds for global propagation or simply retrying the `apply` usually resolves this transient sync issue.

### [2026-05-28] Secret Already Exists (409 Conflict)
*   **Issue:** Terraform fails to create secrets that were previously created manually or by a different process.
*   **Symptoms:** `Error: googleapi: Error 409: Secret already exists...`
*   **Resolution:** Used `terraform import` with the `bootstrap=true` flag. This allows Terraform to take ownership of existing GCP secrets without attempting a destructive recreation.

### [2026-05-28] Cloud SQL API Permission Error
*   **Issue:** `cloudsql.googleapis.com` service enablement failed during automation.
*   **Symptoms:** `Error 403: Forbidden. The caller does not have permission.`
*   **Status:** **ACTIVE INVESTIGATION**. Currently, Cloud SQL is manually managed or its enablement is skipped in the foundation module. Requires "Project Owner" or specific Service Usage Admin permissions.

## 3. Pending Issues & Active Debugging

### Issue: Keycloak Identity Provider Integration
*   **Description:** The Keycloak provider cannot initialize until the Cloud Run service is stable and reachable.
*   **Steps Taken:** Commented out identity resources in `modules/project3/identity.tf`.
*   **What Didn't Work:** Direct deployment without a live endpoint.
*   **Current Hypothesis:** Once the Keycloak image is pushed to the new registry and the service is live, the provider can be safely re-enabled.

## 4. Environment Checklist
Before running Project 0 deployments, ensure:
1.  [ ] `gcloud auth application-default login` is active.
2.  [ ] Terraform workspace is correctly selected (`terraform workspace select default`).
3.  [ ] `dev.tfvars` contains the correct `compute_project_id` and `compute_project_number`.
4.  [ ] No stale `.terraform` directories (run `terraform init -upgrade` if providers were moved).

## 5. AI Agent Usage Protocol

This document serves as a living knowledge base for debugging Project 0. AI Agents and future engineers must adhere to the following protocols:

1.  **Consult First:** Before initiating new debugging efforts, always review the `Status Log` (Section 2) for previously encountered issues and their resolutions. This prevents re-litigating solved problems.
2.  **Document New Issues:** For any new or recurring issue, create a new entry under `3. Pending Issues & Active Debugging`. Fill in all fields (`Description`, `Steps Taken`, `What Didn't Work`, `Current Hypothesis`).
3.  **Update Progress:** As debugging progresses, update the relevant entry in Section 3 with new findings, attempted solutions, and their outcomes.
4.  **Formalize Resolutions:** Once an issue is fully resolved, move its entry from `3. Pending Issues & Active Debugging` to `2. Status Log`, ensuring all fields are completed (especially `Resolution`).
5.  **Environment Verification:** Always cross-reference the `4. Environment Checklist` before attempting any deployment or diagnostic steps.
6.  **Confirmation of Resolution:** An issue is NOT considered resolved until explicit confirmation of its fix has been provided and verified. Do not assume a fix is complete without this confirmation.
6.  **Contextual Awareness:** Refer to `CHANGELOG.md` for broader architectural shifts and decisions that might impact Project 0.
7.  **Format Adherence:** Maintain the established markdown format for consistency and readability.

---
*Refer to `CHANGELOG.md` for historical context on architectural shifts.*
