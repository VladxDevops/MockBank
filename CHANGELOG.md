# Changelog

All notable changes to the "Bank" project will be documented in this file. This log serves to track architectural decisions, successful implementations, and failed experiments to avoid regression.

## Usage Guide
1.  **Update Frequency:** Update this file immediately after any significant architectural decision or code merge.
2.  **Format:** Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) convention.
3.  **Categories:**
    *   `Added` for new features.
    *   `Changed` for changes in existing functionality.
    *   `Deprecated` for soon-to-be removed features.
    *   `Removed` for now removed features.
    *   `Fixed` for any bug fixes.
    *   `Security` in case of vulnerabilities.
4.  **Decisions:** Explicitly log *why* a decision was made (e.g., "Selected Cloud Run for cost reasons") to prevent re-litigating settled debates.

## [1.0.0] - Current
### Added
- **security.md**: Established the "Prime Directive" (Security > Privacy). Defined standards for MFA, RBAC, and Incident Response.
- **Architecture.md**: Defined system topology (GCP, Cloud Run, MongoDB, Keycloak). Added "Infrastructure & Operations" section mandating Terraform and cost optimization.
- **AGENTS.md**: Defined protocols for CI/CD, Monitoring, and AI agents.
- **GEMINI.md**: Established usage guidelines for AI assistants (Data sanitization, Security scanning).

### Changed
- **Branching Strategy**: Adopted uppercase branch names (`DEV`, `TEST`, `PROD`) to clearly distinguish environment-specific branches from feature branches.
- **Terraform Structure**: Mandated the use of `dev.tfvars`, `test.tfvars`, and `prod.tfvars` for environment management.
- **Documentation Structure**: Moved internal policy documents (`SECURITY.md`, `GEMINI.md`, `TESTING.md`, `CONTRIBUTING.md`) to the `Documentation/internal/` directory.
- **Project 1 Terraform**: Refactored `google_sql_database_instance` to use `name_prefix` instead of `random_id` to resolve dependency errors.
- **Project 1 Security**: Updated Keycloak Dockerfile to run as non-root user (`USER keycloak`).

### Fixed
- **Terraform**: Added `sqladmin.googleapis.com` to the list of enabled GCP services to fix `SERVICE_DISABLED` error when creating the Cloud SQL instance for Project 1.
- **Terraform**: Fixed IAM permissions for Project 1. Granted `roles/cloudsql.admin` to the deployer service account and verified successful creation of the Keycloak Cloud SQL instance.

### Decisions & Constraints
- **Secrets Management**: Hardcoding secrets is strictly prohibited. Adopted **GCP Secret Manager** as the single source of truth.
- **Infrastructure**: Selected **GCP Cloud Run** for cost-efficiency without compromising security.
- **AI Usage**: AI-generated code is treated as "untrusted" until human review and SAST scan.
- **Database**: MongoDB selected for Audit/Log storage; requires customer-managed encryption keys.

### Pending
- Implementation of Keycloak on Cloud Run.
- Creation of Terraform scripts for base infrastructure.

## [0.3.0] - Infrastructure Hardening
### Added
- **Terraform**: Created `secret_manager` module to create empty secrets in GCP Secret Manager.
- **Terraform**: Added `gcp_services.tf` to enable necessary GCP APIs.
- **Terraform**: Added `network.tf` to create a custom VPC and VPC connector.
- **Terraform**: Added `artifact_registry.tf` to create a Docker repository.
- **Terraform**: Added `backend.tf` to configure remote state (commented by default).

### Changed
- **Terraform**: Updated `project2` module to use the VPC connector.
- **Terraform**: Updated `mongodbatlas` provider to read API keys from GCP Secret Manager.
- **Terraform**: Added `prevent_destroy` to `google_project_service`, `google_artifact_registry_repository`, and `google_secret_manager_secret` resources to prevent accidental data loss.
- **Documentation**: Updated `README.md` and `terraform/terraform-internal-README.MD` with the new infrastructure and secret management workflow.

## [0.3.1] - Deployment Automation & Fixes
### Fixed
- **Terraform**: Automated `docker_image` URL construction in `project2.tf` to reference the Artifact Registry dynamically, removing manual configuration.
- **Terraform**: Added `random_id` suffix to MongoDB Atlas project names to prevent `GROUP_ALREADY_EXISTS` conflicts.
- **Terraform**: Standardized `compute_region` variable usage across modules.

## [0.2.0] - Project 2 Kickoff (Transaction Journey)
### Added
- **Service Definition**: Initiated "Transaction Service" to simulate orchestration logic.
- **Local Dev Strategy**: Decided to use local MongoDB container for rapid iteration and "safe" failure testing before cloud deployment.
- **Documentation**: Created `2/PROJECT_DETAILS.md` detailing the orchestration logic and MongoDB schema for Project 2.
- **Documentation**: Created `1/PROJECT_DETAILS.md` detailing the Infrastructure & Protocol simulation (OIDC/SAML).
- **Documentation**: Created `3/PROJECT_DETAILS.md` detailing the CI/CD & Release Safety simulation.
- **Implementation**: Initialized Node.js project (`package.json`) and Docker Compose for Project 2.
- **Architecture**: Defined standard directory structure in `Architecture.md`, mandating a `container/` directory for Docker assets.
- **Refactor**: Moved `docker-compose.yml` to `2/container/` and created `2/container/Dockerfile` to comply with directory standards.
- **Terraform**: Created Terraform module for Project 2 to deploy the transaction service to Cloud Run.
- **Documentation**: Updated `README.md`, `terraform/terraform-internal-README.MD`, and `BNKprojects/2/PROJECT_DETAILS.md` with MongoDB Atlas instructions and deployment details for Project 2.
### Added
- **Project 2 Transaction Service**:
    - Implemented Node.js microservice for money transfers.
    - Deployed to Google Cloud Run (Region: `us-south1`).
    - Integrated with MongoDB Atlas for Audit Logging.
    - Implemented Step-Up Authentication logic for transactions >= $10,000.
    - Verified end-to-end flow with `curl` and MongoDB Compass.
    - Validated diagnostic queries for MFA timeouts.