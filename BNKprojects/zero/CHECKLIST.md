# Project 0: Foundation Infrastructure Checklist

## 1. Bootstrapping & APIs - COMPLETED
- [x] **API Enablement:** Provisioned 16+ GCP APIs (Compute, IAM, SQL Admin, etc.) via Phase A bootstrap.
- [x] **Project Variables:** Validated `compute_project_id` and `compute_project_number` across modules.

## 2. Networking Stack - COMPLETED
- [x] **Global VPC:** Provisioned `main-vpc` with custom subnets.
- [x] **Private Connectivity:** Configured Serverless VPC Access (`avechector`) and Private Service Access peering.
- [x] **Egress Control:** Cloud NAT and Router deployed for secure private subnet egress.

## 3. Identity Root (WIF) - COMPLETED
- [x] **Workload Identity Federation:** Provisioned GitHub Pool and OIDC Provider.
- [x] **Shared Service Account:** Created `sa-github-actions` with cross-project administrative roles.
- [x] **GCP Authentication:** Verified OIDC token exchange for GitHub Actions workflows.

## 4. Terraform Governance - STABILIZED
- [x] **Remote State Sync:** GCS backend configured and synchronized with the `projectZERO` workspace.
- [x] **Workspace Strategy:** Established `projectZERO` for foundation and environment-specific workspaces (DEV/PROD) for apps.
- [x] **State Recovery:** Documented and verified `force-unlock` and `terraform import` procedures for disaster recovery.

## 5. Shared Resources - COMPLETED
- [x] **Artifact Registry:** Created `bank-apps-registry` for platform-wide Docker image storage.
- [x] **Shared Secrets:** Provisioned Secret Manager placeholders for MongoDB and Keycloak credentials.

---
**Note:** This checklist tracks the platform's base layer. Stability here is a prerequisite for Projects 1, 2, and 3.
**Classification: INTERNAL**
