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

## [0.6.0] - 2024-05-24
### Added
- **Infrastructure**: Completed the modularization of Project 3. Verified successful creation of identity federation and delivery pipelines.
### Security
- **IAM**: Enforced explicit resource declaration for all Project 3 IAM roles to improve auditability.
### Pending (Not Started)
- **Workflow**: End-to-end automation linking GitHub Actions to the Cloud Deploy targets.
- **Governance**: Final review of the CI/CD service account permissions against the "Least Privilege" directive.

## [0.5.2] - 2024-05-24
### Changed
- **Refactor**: Renamed all Workload Identity variables from `wif_` prefix to `workforce_identity_federation_` for better architectural alignment and clarity.
- **Terraform**: Updated `variables.tf`, `project3.tf`, and `modules/cicd_pipeline/main.tf` to reflect the new variable names.

## [0.5.1] - 2024-05-24
### Fixed
- **Terraform**: Declared missing variables for Workload Identity and GitHub Actions SAs in `variables.tf`.
- **IAM**: Granted `roles/iam.serviceAccountUser` to the GitHub Actions SA in `project3.tf` to resolve deployment authorization errors.
### Added
- **Governance**: Synchronized variable naming between `project3.tf` and `variables.tf` for consistency.

## [0.5.0] - 2024-05-24
### Added
- **Architecture**: Transitioned to a modular CI/CD architecture by implementing the `cicd_pipeline` module.
- **Decision**: Mandated modularity for all CI/CD infrastructure to allow for standardized release safety across multiple microservices (e.g., Transaction, Loans).
- **Security**: Standardized IAM role assignment within the module to prevent permission drift between services.

## [0.5.0] - 2024-05-24
### Added
- **Architecture**: Transitioned to a modular CI/CD architecture by implementing the `cicd_pipeline` module.
- **Decision**: Mandated modularity for all CI/CD infrastructure to allow for standardized release safety across multiple microservices (e.g., Transaction, Loans).
- **Security**: Standardized IAM role assignment within the module to prevent permission drift between services.

## [0.4.1] - 2024-05-24
### Fixed
- **Terraform**: Fixed `google_clouddeploy_target` attribute references in `project3.tf` (switched `.target_id` to `.name`).
- **Terraform**: Corrected Cloud Deploy API service name to `clouddeploy.googleapis.com`.

## [0.4.0] - 2024-05-24
### Added
- **Terraform**: Consolidated Cloud Deploy infrastructure into `project3.tf` to ensure it is provisioned alongside CI/CD resources.
- **Infrastructure**: Enabled `clouddeploy.googleapis.com` API.
- **Security**: Configured `DEV` target for rapid iteration while maintaining manual approval gates for `TEST` and `PROD`.
- **IAM**: Added `roles/clouddeploy.jobRunner`, `roles/logging.logWriter`, and `roles/iam.serviceAccountUser` to the GitHub Actions service account.
- **Governance**: Created `SERVICE_ACCOUNT_GOVERNANCE.md` to document and regulate IAM roles and service account purposes.
- **Decision**: Adopted full `terraform apply` over targeted applies for Project 3 to ensure dependency graph integrity between GCP APIs and Cloud Deploy resources.

## [0.1.0] - Initial Setup
### Added
- **security.md**: Established the "Prime Directive" (Security > Privacy). Defined standards for MFA, RBAC, and Incident Response.
- **Architecture.md**: Defined system topology (GCP, Cloud Run, MongoDB, Keycloak). Added "Infrastructure & Operations" section mandating Terraform and cost optimization.
- **AGENTS.md**: Defined protocols for CI/CD, Monitoring, and AI agents.
- **GEMINI.md**: Established usage guidelines for AI assistants (Data sanitization, Security scanning).

### Changed
- **Branching Strategy**: Adopted uppercase branch names (`DEV`, `TEST`, `PROD`) to clearly distinguish environment-specific branches from feature branches.
- **Terraform Structure**: Mandated the use of `dev.tfvars`, `test.tfvars`, and `prod.tfvars` for environment management.
- **Documentation Structure**: Moved internal policy documents (`SECURITY.md`, `GEMINI.md`, `TESTING.md`, `CONTRIBUTING.md`) to the `Documentation/internal/` directory.

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
### Added
- **Project 2 Transaction Service**:
    - Implemented Node.js microservice for money transfers.
    - Deployed to Google Cloud Run (Region: `us-south1`).
    - Integrated with MongoDB Atlas for Audit Logging.
    - Implemented Step-Up Authentication logic for transactions >= $10,000.
    - Verified end-to-end flow with `curl` and MongoDB Compass.
    - Validated diagnostic queries for MFA timeouts.
### Security
- **Project 1 Container**:
    - Hardened Keycloak container for Cloud Run deployment.
    - Added `KC_PROXY=edge` to handle TLS termination securely.
### Added
- **Documentation**: Created `GLOSSARY_TOON_AAAK.md` to provide human-readable definitions for AI-optimized notations used in the Long-Term Memory (LTM) strategy.
## [2.1.38] - 2024-05-24
### Security
- **Environment**: Enforced exclusion of Python virtual environments from version control to ensure cross-platform compatibility and clean repository state.

## [2.1.34] - 2024-05-24
### Fixed
- **Environment**: Forced `load_dotenv(override=True)` in `app.py` to prevent stale shell environment variables from overriding the local `.env` configuration, ensuring the OIDC proxy is correctly utilized.

## [1.9.0] - 2024-05-24
### Fixed
- **Verification**: Confirmed Project 2 (Transaction Service) manual verification is successful. Orchestration logic, Step-Up Auth (>= $10,000), and MongoDB Audit logging are functional.
### Added
- **Project 3 Kickoff**: Transitioned focus to CI/CD & Release Safety simulation.
### Decisions
- **Testing**: Deferred the automation of `test-transactions.sh` to prioritize the global CI/CD pipeline and release safety gates.

## [1.8.11] - 2024-05-24
### Added


## [1.8.1] - 2024-05-24
### Added
- **Tooling**: Created `test-keycloak.sh` in `BNKprojects/1/` to automate deployment verification for both GCloud Proxy and Direct IAM-Authenticated flows.

## [1.8.2] - 2024-05-24
### Changed
- **Tooling**: Enhanced `test-keycloak.sh` with automated `gcloud logging` retrieval on health check or validation failure to streamline troubleshooting.
### Added
- **Operations**: Formalized the "Script-First" testing SOP. Mandated that all current and future projects (including Project 3) include automated test scripts and secondary troubleshooting documentation for those scripts.
- **Documentation**: Created `BNKprojects/1/TROUBLESHOOTING_SCRIPTS.md`.
### Pending
- **Verification**: First execution of `test-keycloak.sh` to validate the Identity Service deployment.
### Documentation
- **Traffic Analysis**:
    - Updated `Documentation/internal/Architecture.md` to define Global Ingress and VPC Egress standards.
    - Updated `BNKprojects/1/ARCHITECTURE.md` with explicit Ingress/Egress flow details for the Identity Service.
    - Refactored `BNKprojects/1/ARCHITECTURE.md` to group traffic flow under a dedicated "Networking" section.
    - Clarified the decision to use Cloud Run's built-in Load Balancer instead of a dedicated resource in `BNKprojects/1/ARCHITECTURE.md`.
    - Documented `keycloak-sa` Service Account purpose and the requirement for parameterizing IAM names in `BNKprojects/1/ARCHITECTURE.md`.
    - Updated `Documentation/internal/Architecture.md`, `Documentation/internal/AGENTS.md`, and `BNKprojects/1/AGENTS.md` to enforce the prohibition of hardcoded Service Account names.
    - Created `BNKprojects/1/TROUBLESHOOTING.md` to institutionalize knowledge about Cloud Run/Java deployment issues.
    - Added `BNKprojects/1/localTSkeycloakContainer.md` to assist developers with local container debugging workflows.
    - Updated `BNKprojects/1/localTSkeycloakContainer.md` with Docker socket permission fixes.
    - Enhanced `BNKprojects/1/localTSkeycloakContainer.md` with an explanation of Docker Compose's detached (`-d`) mode.
    - Updated `BNKprojects/1/localTSkeycloakContainer.md` to reflect successful verification steps.
