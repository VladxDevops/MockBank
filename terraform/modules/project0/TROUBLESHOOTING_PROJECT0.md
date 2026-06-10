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

### [2026-05-28] Mass 409 Conflict: Infrastructure State Divergence
*   **Issue:** GitHub Actions failed with `Error 409: Resource already exists` for VPC, WIF, Secrets, and Artifact Registry.
*   **Reason:** Resources were provisioned but the Terraform state file in the GCS backend was either cleared or not updated, leading to a "chicken and egg" recreation attempt.
*   **Resolution:** Performed manual `terraform import` for all foundational resources to reconcile the remote state with actual GCP infrastructure.
*   **Commands Used:**
    *   `terraform import module.project0.google_compute_network.vpc dev-mockbank/main-vpc`
    *   `terraform import module.project0.google_iam_workload_identity_pool.github_pool projects/dev-mockbank/locations/global/workloadIdentityPools/github-pool`
    *   `terraform import module.project0.google_service_account.github_actions_sa projects/dev-mockbank/serviceAccounts/sa-github-actions@dev-mockbank.iam.gserviceaccount.com`
*   **Commands Used (Non-Interactive):**
    *   `terraform import -var-file="dev.tfvars" module.project0.google_compute_network.vpc dev-mockbank/main-vpc`
    *   `terraform import -var-file="dev.tfvars" module.project0.google_compute_address.nat_ip dev-mockbank/us-south1/nat-static-ip`
    *   `terraform import -var-file="dev.tfvars" module.project0.google_iam_workload_identity_pool.github_pool projects/dev-mockbank/locations/global/workloadIdentityPools/github-pool`
    *   `terraform import -var-file="dev.tfvars" module.project0.google_service_account.github_actions_sa projects/dev-mockbank/serviceAccounts/sa-github-actions@dev-mockbank.iam.gserviceaccount.com`
    *   `terraform import -var-file="dev.tfvars" module.project0.google_secret_manager_secret.retail_app_session_secret projects/dev-mockbank/secrets/retail-app-session-secret`
    *   `terraform import -var-file="dev.tfvars" module.project0.google_secret_manager_secret.mock_secret projects/dev-mockbank/secrets/mock-secret`
    *   `terraform import -var-file="dev.tfvars" module.project0.google_artifact_registry_repository.repository projects/dev-mockbank/locations/us-south1/repositories/bank-apps-registry`
*   **Outcome:** State synchronized; subsequent `terraform plan` now shows `0 to add, 0 to change, 0 to destroy`.

### [2026-05-28] Alternative Resolution: Manual State Push (Lineage Conflict)
*   **Action:** Used `terraform state push -force` to synchronize local state to the GCS remote backend.
*   **Issue:** Encountered `Failed to write state: cannot import state with lineage ... over unrelated state with lineage ...`.
*   **Reason:** The local and remote states were initialized independently, resulting in different lineage IDs. Terraform blocks the push by default to prevent accidental data loss.
*   **Strategy:** Overwriting the remote state with the verified local "Source of Truth" using the `-force` flag.
*   **Command:** `terraform state push -force terraform.tfstate`
*   **Outcome:** Attempted synchronization; however, GitHub Actions continues to report 409 Conflict errors. Lineage or state consistency remains under investigation.

### [2026-05-28] GitHub Secrets: WIF Credentials Synchronization
*   **Action:** Manual update of GitHub Actions secrets in the repository settings.
*   **Secrets Affected:** `WIF_SERVICE_ACCOUNT`, `WIF_PROVIDER`.
*   **Reason:** Synchronization of the CI/CD environment with the Workload Identity Federation resources provisioned in the foundation layer.
*   **Outcome:** Verified that GitHub Actions can successfully authenticate using the updated identity provider and service account strings.

### [2026-05-28] Provider Initialization Error (Unavailable Provider)
*   **Issue:** `terraform import` fails with `unavailable provider "registry.terraform.io/hashicorp/http"`.
*   **Reason:** Terraform requires all providers referenced in any part of the configuration (even unused modules or data sources like `module.project2.data.http.myip`) to be initialized before it can perform an import.
*   **Resolution:** Run `terraform init` to download and install missing provider plugins.
*   **Outcome:** Successfully re-initialized the workspace, allowing imports to proceed.

### [2026-05-28] Warning: Missing Backend Configuration
*   **Issue:** `terraform init` ignored `-backend-config` flags, resulting in local state usage in CI/CD and persistent 409 Conflict errors.
*   **Symptoms:** `Warning: Missing backend configuration` in logs; Terraform attempting to recreate existing resources.
*   **Reason:** The Terraform configuration lacked an explicit `backend "gcs" {}` block, which is required even when providing configuration via CLI.
*   **Resolution:** Added an empty `backend "gcs" {}` block to the root `terraform/` configuration.
*   **Outcome:** CI/CD now correctly attaches to the GCS remote backend, recognizing existing infrastructure.

### [2026-05-28] Infrastructure: Explicit Backend Configuration
*   **Action:** Re-instated hardcoded `bucket` and `project` in `backend.tf` per project requirements.
*   **Issue:** `Error: Invalid backend configuration argument` in GitHub Actions.
*   **Reason:** Conflict between hardcoded HCL values and redundant `-backend-config` CLI flags.
*   **Resolution:** Simplified `terraform init` in workflows to rely on `backend.tf` for remote state connectivity.
*   **Status:** **ACTIVE INVESTIGATION**. **EXPLICIT NOTE:** Local `terraform apply` is confirmed to work properly and synchronizes with the remote state without errors. The failure is exclusively manifesting during the GitHub Actions `terraform plan` step, suggesting a disparity in the CI environment's workspace or backend initialization.

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
*Refer to `CHANGELOG.md` for historical context on architectural shifts.*
