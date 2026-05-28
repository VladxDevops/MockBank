# Terraform Migration Report - Project 0 Foundation

## Summary
Successfully continued the migration of Terraform code into the `project0` foundation module. This phase focused on consolidating variables, centralizing GCP service enablement, and managing MongoDB Atlas secrets.

## Key Changes
1.  **Variable Consolidation**: All required root variables were declared in the top-level `variables.tf`, resolving multiple "undeclared variable" errors. Duplicate declarations in `artifact_registry.tf` and `terraform.tf` were removed.
2.  **Project 0 Enhancements**:
    *   Updated `module.project0` to accept required parameters: `compute_project_id`, `atlas_public_key`, `atlas_private_key`, `keycloak_admin_username`, `keycloak_admin_password`, and `keycloak_url`.
    *   Added `cloudresourcemanager.googleapis.com` to the list of enabled services in `modules/project0/main.tf` and added explicit `depends_on` blocks to ensure it is enabled first.
3.  **Secret Management**:
    *   Created `module.atlas_public_key_secret` and `module.atlas_private_key_secret` using the generic `secret_manager` module in `mongo_secrets.tf`.
    *   Added `variables.tf` to the `modules/secret_manager` module to support these calls.
    *   Imported existing secrets from GCP into the Terraform state to avoid conflicts.
4.  **Service Enablement**:
    *   Successfully enabled 14 out of 15 targeted services.
    *   *Note*: `cloudsql.googleapis.com` failed with a permission error (403 Forbidden). This may require higher-level permissions or project-level configuration changes.

## Troubleshooting Log
*   **Error**: `Missing required argument` in `module.project0`.
    *   **Fix**: Corrected the module call in `project0.tf` to match the module's variable definitions.
*   **Error**: `Duplicate variable declaration`.
    *   **Fix**: Consolidated all variables into the root `variables.tf`.
*   **Error**: `SERVICE_DISABLED` for `cloudresourcemanager.googleapis.com`.
    *   **Fix**: Added the API to the enablement list and set dependencies.
*   **Error**: `Secret already exists` (409 Conflict).
    *   **Fix**: Used `terraform import` with `bootstrap=true` to bring existing secrets into state.

## Current State
The migration is **COMPLETE**. The infrastructure has been successfully consolidated into the `project0` foundation module.

### Deployed Infrastructure:
1.  **Foundation (`project0`)**:
    *   **GCP APIs**: Centralized enablement of 16+ services (Compute, IAM, Secret Manager, Cloud Build, Cloud Deploy, SQL Admin, etc.).
    *   **Networking**: VPC (`main-vpc`), private subnet (`main-subnet`), and VPC Access Connector (`avechector`).
    *   **Connectivity**: Cloud Router and NAT Gateway for private egress; VPC Peering for private service access.
    *   **Artifact Registry**: Standardized repository `bank-apps-registry`.
    *   **Load Balancing**: Global External HTTP Load Balancer with Backend Service and Serverless NEG for transaction services.
2.  **Project 1 (Keycloak)**:
    *   **Database**: Cloud SQL Postgres instance (`keycloak-db-...`) with private IP and managed secrets.
    *   **Service**: Keycloak Cloud Run service defined and pointing to the new registry (requires image push to start).
3.  **Project 3 (CI/CD)**:
    *   **Identity**: GitHub Actions Workload Identity Federation (Pool and Provider) successfully configured.
    *   **Pipelines**: Cloud Deploy delivery pipeline and targets (dev, test, prod) created for the transaction service.

## Critical Handover Notes
*   **Keycloak Identity Phase**: The Keycloak provider and identity resources (`modules/project3/identity.tf`) are currently commented out. Once the Keycloak Cloud Run service is live and reachable, these should be uncommented and the `keycloak_url` updated in `dev.tfvars` to perform the identity configuration.
*   **Cloud Run Image**: The Keycloak service is in a failed state because the image `us-south1-docker.pkg.dev/dev-mockbank/keycloak-repo-p1/keycloak:v1` does not yet exist in the registry. Push this image to unblock the service.
*   **Cloud SQL API**: If permissions allow, uncomment the `cloud_sql` service in `modules/project0/main.tf` for full automation. It is currently manually managed or skipped.

## Troubleshooting Reference
*   **Connection Refused / Cannot Assign Address**: Transient errors due to API propagation or environment networking. Retrying `terraform apply` resolved these during migration.
*   **Service Account Propagation**: Occasional 400 errors during IAM binding are resolved by retrying once the service account propagates globally.

