# Changelog

All notable changes to the "Bank" project will be documented in this file. This log serves to track architectural decisions, successful implementations, and failed experiments to avoid regression.

## Usage Guide
1.  **Update Frequency:** Update this file immediately after any significant architectural decision or code merge.
2.  **Format:** Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) convention.

## [Unreleased]
### Fixed
- **Infrastructure**: Clarified state lock lifecycle in documentation, distinguishing between automatic release and manual `force-unlock` procedures.
- **Infrastructure**: Resolved Terraform state lock contention between local development and GitHub Actions by implementing the `force-unlock` protocol for the `projectZERO` workspace.
- **Infrastructure**: Clarified `terraform state push` workspace targeting logic to prevent accidental state overwrites in `projectZERO`.
- **Infrastructure**: Updated `remote_terraform_state_enabler.sh` to use lowercase environment variables (`remote_state_project_id`, `deployer_sa_email`) to maintain compatibility with the local `.env` configuration.
- **Governance**: Standardized environment variable casing to UPPERCASE across all shell scripts and documentation to ensure consistency, as shell variables are case-sensitive.
- **Infrastructure**: Synchronized `remote_terraform_state_enabler.sh` with standardized `.env` variable names (`REMOTE_STATE_PROJECT_ID`, `DEPLOYER_SA_EMAIL`) to ensure reliable IAM provisioning in the centralized state project.
- **Security**: Provisioned `roles/storage.objectAdmin` for the GitHub Actions Service Account on the `remote_terraform_state_gcp_project` to enable cross-project state management and resolve 403 Forbidden errors during initialization.
- **Documentation**: Standardized changelog filename and fixed redundant "internal" documentation references in Project 1 AGENTS.md.
- **CI/CD**: Updated `ci.yaml` trigger to execute on `push` to the `DEV` branch instead of `pull_request`, ensuring validation runs on direct commits and merges.
- **Documentation**: Created `github-actions.md` to provide a centralized technical reference for the CI/CD pipeline logic, including the auto-fix job and Terraform lifecycle refinements.
- **CI/CD**: Standardized `ci.yaml` and `cd.yaml` with YAML block scalars (`|`) and explicit backend configuration to resolve "Module not installed" and remote state synchronization errors.
- **CI/CD**: Implemented the "Secret-to-File" materialization pattern for `dev.tfvars` using heredocs (`cat <<'EOF'`) to prevent shell-level quote stripping.
- **Infrastructure**: Expanded Project 0 IAM with `roles/logging.logWriter` and `roles/clouddeploy.releaser`.
- **Infrastructure**: Refactored Project 0 IAM to use explicit `google_project_iam_member` resources for 17+ administrative roles to ensure granular auditability.
- **Security**: Added `roles/serviceusage.serviceUsageAdmin` to the Terraform Service Account to resolve 403 errors during `cloudsql.googleapis.com` enablement.
- **Documentation**: Created `actimize_roadmap.md` to define a four-phase integration strategy for financial crime management. Projects status: NOT STARTED/PENDING. 
- **Structure**: Centralized Actimize-related internal documentation within `Documentation/internal/actimize/` for better repository hygiene.
- **Documentation**: Synchronized AI assistant logic with the project's Prime Directive and specialized skills registry. Verified alignment with Project 0 migration goals and Zero-Trust networking standards.
- **Governance**: Validated that all automated agent protocols (AGENTS.md) are correctly enforced across root and internal documentation directories.
- **Security**: Identified missing `roles/iam.workloadIdentityPoolAdmin` and `roles/clouddeploy.admin` for the Deployer Service Account in the bootstrap script, resolving 403 errors during foundation provisioning.
- **Security**: Granted `roles/iam.serviceAccountCreator` to the shared GitHub Actions service account in Project 0 and updated the `project0firstsrun.sh` bootstrap scripts to support automated service account management.
- **Infrastructure**: Added a new empty placeholder secret `mock-secret` to the Project 0 foundation module.
- **CI/CD**: Removed the automated Cloud Deploy release step from `cd.yaml` to focus exclusively on foundational infrastructure (Project 0) stability.
- **Migration**: Resolved `terraform state push` argument error by explicitly providing the local state path to synchronize the `projectZERO` workspace with the remote GCS backend.
- **Migration**: Resolved 403 Permission Denied errors in CI/CD by documenting the "Identity Bootstrapping" requirement; foundational Service Accounts require manual `roles/owner` or `roles/editor` on target projects to manage lifecycle resources.
- **Migration**: Fixed State Divergence by synchronizing local infrastructure state with the `projectZERO` workspace in the remote GCS backend.
- **Documentation**: Elaborated a comprehensive `README.md` for the Project 0 (Foundation) module, detailing the bootstrap process, security standards, and component architecture.
- **Migration**: Resolved State Divergence between local environment and CI/CD by synchronizing the `projectZERO` workspace with the remote GCS backend.
- **Security**: Identified and documented the "Identity Bootstrapping" requirement; the GitHub Actions Service Account requires manual `Owner` or `Editor` roles on the target project to manage foundational lifecycle resources (WIF, APIs, SAs).
- **Security**: Formalized the "Secret-to-File Materialization" pattern for CI/CD. The `TFVARS_DEV` secret is used to generate an ephemeral `dev.tfvars` at runtime, ensuring no sensitive variable files are stored in version control (adhering to the Prime Directive).
- **CI/CD**: Resolved "Invalid character" errors in Terraform by switching to `cat <<'EOF'` for `dev.tfvars` creation, preventing shell-level quote stripping of secrets.
- **CI/CD**: Simplified workspace selection logic using `terraform workspace select -or-create` to prevent premature job failure.
- **CI/CD**: Configured `ci.yaml` and `cd.yaml` to reconstruct `dev.tfvars` from the `TFVARS_DEV` GitHub Secret at the environment level.
- **CI/CD**: Added `environment: DEV` to `ci.yaml` to allow PR validation logic to access environment-protected secrets.
- **CI/CD**: Hardened Terraform workspace selection and re-initialization logic to ensure `.terraform/modules` is populated before validation.
- **CI/CD**: Added explicit validation checks for `dev.tfvars` existence in the runner environment to provide clearer error messaging.
- **CI/CD**: Fixed "Module not installed" errors in GitHub Actions by reordering `terraform init` to execute before `terraform validate`.
- **CI/CD**: Cleaned up duplicated release steps and removed misplaced Terraform commands from the Cloud Deploy stage in `cd.yaml`.
- **CI/CD**: Enabled automated Google Cloud Deploy releases in `cd.yaml` for the `transaction-service-pipeline`.
- **CI/CD**: Corrected syntax errors in GitHub Action workflows (`rrun` typo, malformed `terraform init` arguments, and missing hyphen for `-var-file`).
- **CI/CD**: Created `ci.yaml` and `cd.yaml` to automate Project 0 (Foundation) infrastructure management via GitHub Actions.
- **Security**: Implemented Workload Identity Federation (WIF) in workflows to eliminate the need for long-lived service account keys.
- **Infrastructure**: Reconciled state divergence by importing existing Networking (VPC, Subnet, NAT, Router) and WIF resources into the Project 0 Terraform state.
- **Migration**: Resolved 409 Conflict (Entity already exists) for Workload Identity Federation resources by importing existing GCP assets into the `project0` state.
- **Migration**: Added `prevent_destroy` lifecycle protection to foundational Identity Pool and Provider resources.
- **Infrastructure:** Switched Load Balancer and `bank-platform-lb-ip` to Regional/Standard Network Tier. Provisions are now explicitly disabled/commented for non-PROD environments to prevent unnecessary costs.
- **Documentation:** Corrected `DEV` ingress documentation across `Architecture.md` and Project 1. Services must be accessed via `gcloud run services proxy` to maintain the "No Unauthenticated Access" policy; direct Cloud Run URLs will not work for browser-based testing due to IAM enforcement.
- **CI/CD:** Hardened Docker image path construction in `deploy.yml` to prevent `could not parse reference` errors. 
- **CI/CD:** Added mandatory validation to ensure `PROJECT` and `REPO` identifiers are not empty before attempting builds.
- **CI/CD:** Harmonized secret names between workflow and documentation (using `GCP_BACKEND_PROJECT_ID`).
- **Security**: Provisioned `roles/resourcemanager.projectIamAdmin`, `roles/iam.securityAdmin`, and `roles/iam.roleAdmin` for the Terraform Deployer SA to enable declarative IAM management in the target project.
- **Security**: Granted `roles/resourcemanager.projectIamAdmin` to the Terraform Deployer Service Account on the `remote_terraform_state_gcp_project` to enable cross-project IAM management.
### Pending
### Changed
- **Infrastructure**: (In Progress) Troubleshooting persistent `Module not installed` errors in GitHub Actions. Verified that the runner requires a fresh `terraform init -upgrade` within the same job context to fetch local modules.
- **Infrastructure**: (In Progress) Investigating persistent 409 Conflict errors and backend configuration warnings in CI/CD despite explicit `backend "gcs"` block.
- **Migration**: (In Progress) Re-evaluating remote state synchronization; lineage conflicts and state push outcomes are still being verified.
- **Security**: Renamed `GCP_PROJECT_ID` to `GCP_BACKEND_PROJECT_ID` for backend project identification.
- **Infrastructure**: Re-initialized workspace to address "Unavailable Provider" errors during resource import; monitoring for recurrence.
- **Security:** Centralized all application-layer secret placeholders (Keycloak Admin/DB passwords, MongoDB connection strings) into the Project 0 foundation module.
- **Infrastructure:** Documented resolution for `Backend configuration changed` errors when migrating to cross-project state management.
- **Infrastructure:** Defined cross-project state management protocol allowing the DEV project service account to manage state in a centralized remote project.
- **Governance:** Activated the AI Skills Registry and implemented a modular "one-file-per-skill" architecture with token-saving protocols (AAAK/TOON).
- Governance: Established the `SERVICE_ACCOUNT_GOVERNANCE.md` library to track identity roles across projects.
- Governance: Defined `RESOURCE_TAGGING_POLICY.md` to standardize metadata for cost and ownership audits.
- Infrastructure: Initialized the `projectZERO` Terraform workspace for foundational resource management.
- Infrastructure: Documented Phase A "Provider Only" execution using `-target=google_project_service.gcp_services` to enable APIs before networking.
- Migration: Migrated shared networking (VPC, Main Subnet, Cloud NAT) from Project 2 into Project 0 Phase B.
- Migration: Refactored Project 1 and Project 2 Terraform modules to reference shared resources in Project 0 via remote state or data sources, ensuring modularity.
- **CI/CD:** Reorganized `deploy.yml` to follow a "Foundation First" logic. Infrastructure (Terraform) now provisions the Artifact Registry before builds are attempted.
- **Documentation:** Created `PIPELINE_RESTRUCTURING.md` to document the new deployment strategy.
### Added
 - **Architecture:** Decomposed **Project 0 (Foundation)** into a progressive, multi-phase deployment: Phase A (Services/APIs) and Phase B (VPC/Registry).
 - **CI/CD:** Restructured `deploy.yml` into a five-stage progressive pipeline: APIs -> Foundation Resources -> App Infra -> Artifacts -> Release.
 - **CI/CD:** Cleaned up malformed image path construction and redundant Terraform logic in the deployment workflow.
- **Security:** Centralized IAM role assignments for the GitHub Actions Service Account within Project 0 to ensure least-privilege consistency across environments.
 - **GitOps:** Provisioned Terraform code for Project 0 (Modular Foundation) including API enablement, Networking, and centralized IAM management.
 - **Architecture:** Documented the rationale for a monolithic `deploy.yml` orchestrator to manage linear foundation dependencies.
 - **Environments:** Provisioned a new dedicated GCP Project for the `DEV` environment to isolate baseline infrastructure testing.



3.  **Categories:**
    *   `Added` for new features.
    *   `Changed` for changes in existing functionality.
    *   `Deprecated` for soon-to-be removed features.
    *   `Removed` for now removed features.
    *   `Fixed` for any bug fixes.
    *   `Security` in case of vulnerabilities.
4.  **Decisions:** Explicitly log *why* a decision was made (e.g., "Selected Cloud Run for cost reasons") to prevent re-litigating settled debates.
    *   `Removed` for now removed features.
    *   `Fixed` for any bug fixes.
    *   `Security` in case of vulnerabilities.

## [2.5.0] - 2024-05-24 (In Progress)
### Added
- **CI/CD**: Integrated GitHub Actions with Workload Identity Federation (WIF) and environment-gated secrets.
- **CI/CD**: Implemented automated Keycloak image builds using Google Cloud Build within the pipeline.
- **CI/CD**: Added Semgrep SAST scanning as a mandatory security gate for all PRs and pushes.
### Fixed
- **Build**: Resolved Keycloak build failure by using a placeholder `realm-export.json` to satisfy Docker context requirements while maintaining Terraform as the source of truth for config.
- **Dependencies**: Fixed `npm ci` failures in Project 2 by implementing a fallback to `npm install` when `package-lock.json` is absent.
- **IAM**: Resolved `403 Forbidden` errors for Cloud Build by granting `Service Usage Consumer` and `Storage Admin` roles to the GitHub Actions Service Account.
- **SAML**: Hardened `teller_portal.py` to use dynamic `APP_BASE_URL`, fixing redirect loops in Cloud Run.
### Security
- **IAM**: Enforced Least Privilege by mapping specific roles (Cloud Build Editor, Cloud Deploy Releaser) to the ephemeral WIF principal. 

## [2.4.0] - 2024-05-24
### Added
- **GitOps**: Initialized Keycloak Terraform provider and migrated the `AltmtrkBank` realm to HCL.
- **GitOps**: Implemented SAML 2.0 integration for `teller-portal` with automated self-signed certificate generation and Secret Manager storage.
- **GitOps**: Implemented the `retail-app` OIDC client and the new `risk` scope in Terraform to satisfy Fraud Team requirements.
- **Documentation**: Created `BNKprojects/3/SAML_INTERVIEW_QA.md` detailing interview questions and answers for the SAML implementation.
### Changed
- **Configuration**: Updated Project 3 variables to support Keycloak admin credentials and URL.

## [2.3.0] - 2024-05-24
### Added
- **Infrastructure**: Successfully provisioned Project 3 infrastructure (Workload Identity Federation Pool/Provider and Google Cloud Deploy Pipelines) via modularized Terraform.
### Fixed
- **Terraform**: Corrected OIDC provider `attribute_condition` to properly reference mapped attributes, resolving 400 Bad Request errors.
- **Terraform**: Fixed HCL syntax errors in `google_clouddeploy_target` (replaced semicolons with newlines).
- **IAM**: Resolved propagation race conditions by adding explicit `depends_on` between IAM role assignments and WIF resource creation.
### Pending (Not Started)
- **CI/CD Integration**: Creation of `.github/workflows/deploy.yml` to authenticate via WIF and trigger Cloud Deploy releases.
- **Manifests**: Configuration of `skaffold.yaml` for the Transaction Service (Project 2).
- **Security**: Implementation of SAST (Static Application Security Testing) gates within the GitHub Actions pipeline.

## [2.2.5] - 2024-05-24
### Added
- **CI/CD Implementation**: Started provisioning Workload Identity Federation (WIF) and Google Cloud Deploy pipelines via Terraform.
### Changed
- **Status**: Moved Project 3 from Planning to Implementation phase.

## [2.2.4] - 2024-05-24
### Added
- **CI/CD Strategy**: Adopted a hybrid CI/CD approach utilizing both Google Cloud Deploy and ArgoCD.
### Changed
- **Decisions**: Google Cloud Deploy will be used for continuous delivery of Cloud Run services. ArgoCD will be deployed on a GKE Autopilot cluster to manage future Kubernetes workloads and provide continuous drift detection, optimizing costs by leveraging Autopilot's pay-per-pod model.
- **Documentation**: Updated `BNKprojects/3/PROJECT3_DETAILS.md` to reflect the new hybrid strategy and cost considerations for ArgoCD on GKE Autopilot.
- **Documentation**: Updated `BNKprojects/3/README.md` and `Documentation/internal/INFRASTRUCTURE.md` for consistency.

## [2.2.3] - 2024-05-24
### Added
- **Research**: Evaluated Google Cloud Deploy vs. ArgoCD for drift detection.
### Changed
- **Architecture**: Documented that Google Cloud Deploy is push-based and does not natively support continuous drift detection or auto-remediation.
- **Decisions**: Maintained ArgoCD as the preferred GitOps engine for drift detection, pending GKE cost approval.

## [2.2.2] - 2024-05-24
### Changed
- **Architecture**: Clarified that ArgoCD is Kubernetes-native and cannot run on Cloud Run.
- **Decisions**: Evaluated cost difference between Cloud Run ($0 baseline) and GKE (~$70 baseline) for hosting GitOps engines.
- **Documentation**: Updated `BNKprojects/3/PROJECT3_DETAILS.md` to include GKE as a prerequisite for ArgoCD.

## [2.2.1] - 2024-05-24
### Added
- **Research**: Completed feasibility study on ArgoCD for GitOps implementation.
- **Decisions**: Confirmed ArgoCD as $0 cost (Open Source). Identified requirement for Kubernetes (GKE) to host the GitOps engine.
- **Project 3**: Updated `PROJECT3_DETAILS.md` to include Drift Detection and GitOps as core components.

## [2.2.0] - 2024-05-24
### Added
- **Security**: Updated root(at /Bank/) `.gitignore` to enforce the exclusion of internal documentation (`Documentation/internal/`) and project-specific design details from version control.
- **Project 3**: Commenced Global CI/CD and Release Safety phase.

## [2.1.45] - 2024-05-24
### Changed
- **Documentation**: Synchronized `ARCHITECTURE.md` and `CHECKLIST.md` to reflect the completed SAML integration and OIDC local proxy strategy.
- **Documentation**: Formally documented "Fail-Fast" security enforcement for session secrets.

## [2.1.44] - 2024-05-24
### Added
- **SAML Integration**: Implemented `src/teller_portal.py` using `python3-saml` to handle the SAML 2.0 Service Provider (SP) flow.
- **SAML Integration**: Created `src/generate_saml_certs.sh` to automate the generation of SP certificates required for signed/encrypted assertions.
- **Documentation**: Updated `CHECKLIST.md` to reflect the completion of the SAML implementation phase.

## [2.1.43] - 2024-05-24
### Added
- **SAML Integration**: Created `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/BNKprojects/1/container/realm-export.json` with the `teller-portal` SAML client configuration, including signed and encrypted assertions and attribute mappers.
- **Documentation**: Updated `CHECKLIST.md` to reflect the completion of the Keycloak SAML client configuration.

## [2.1.42] - 2024-05-24
### Added
- **SAML Integration**: Defined the dual-track plan for `teller-portal` configuration in `realm-export.json` and the `python3-saml` implementation strategy.
- **Documentation**: Updated `CHECKLIST.md` to reflect the current active focus on SAML 2.0 mapping and assertion security.

## [2.1.41] - 2024-05-24
### Added
- **SAML Integration**: Initiated the "Legacy Teller Portal" integration phase.
- **Documentation**: Updated `CHECKLIST.md` to mark OIDC connectivity as verified and transition focus to SAML 2.0.

## [2.1.40] - 2024-05-24
### Fixed
- **Tooling**: Successfully resolved the `Invalid account type for --audiences` error. Implemented localhost detection in `src/app.py` to bypass OIDC token acquisition when using the `gcloud run services proxy`.
- **Environment**: Resolved `ModuleNotFoundError` by standardizing the `requirements.in` manifest and ensuring all necessary Google Auth and configuration libraries are included in the `pip-sync` workflow.
### Changed
- **Documentation**: Updated the root `README.md` to explicitly document the proxy workaround for local development.

## [2.1.39] - 2024-05-24
### Fixed
- **Tooling**: Corrected `gcloud` CLI flag in `app.py` from `--audience` to `--audiences` to resolve local token acquisition failures.
### Changed
- **Tooling**: Confirmed that standard User Accounts cannot generate targeted OIDC tokens via `gcloud` for specific audiences locally.

## [2.1.23] - 2024-05-24
### Changed
- **Documentation**: Updated the root `README.md` with explicit local development steps for Project 1, aligning with the `src/` directory migration and `pip-sync` dependency workflow.

## [2.1.17] - 2024-05-24
### Changed
- **Documentation**: Formally documented the RBAC role mapping (`customer`, `teller`, `manager`, `audit`) in `Architecture.md` to align high-level docs with `realm-export.json` skeletons.

## [2.1.16] - 2024-05-24
### Added
- **Documentation**: Created a detailed, line-by-line explanation of the OIDC implementation in `PYTHON_CODE_EXPLANATION.md`.
## [2.1.21] - 2024-05-24
### Fixed
- **Structure**: Resolved a conflict where a file named `src` prevented the creation of the standard `src/` directory in Project 1; moved `app.py` to the correct location.
## [2.1.22] - 2024-05-24
### Changed
- **Architecture**: Clarified that dependency manifests (requirements.txt) must reside in the service root, not the `src/` directory, to support build caching and standard tooling.
- **Documentation**: Removed redundant directory structure definitions in `Architecture.md`.
## [2.1.26] - 2024-05-24
### Fixed
- **Environment**: Standardized the use of Python Virtual Environments (`venv`) in `README.md` to resolve `ModuleNotFoundError` and ensure dependency isolation.

## [2.1.15] - 2024-05-24
### Fixed
- **Code Quality**: Resolved syntax and indentation errors in `app.py` caused by duplicate code fragments.

## [2.1.14] - 2024-05-24
### Added
- **OIDC Integration**: Implemented JWKS-based decoding and validation for Access Tokens in `app.py`.
- **Session Management**: Configured role extraction from `realm_access` claims for RBAC support.

## [2.1.13] - 2024-05-24
### Added
- **Audit**: Completed comprehensive documentation review of Project 1 and 2.
- **Protocols**: Synchronized internal agent state with Zero-Trust and Declarative Configuration directives.
## [2.1.18] - 2024-05-24
### Added
- **Tooling**: Created `.env.example` for Project 1 to standardize local environment configuration for the Python OIDC client.

## [2.1.12] - 2024-05-24
### Changed
- **Documentation**: Updated `README.md` files to explicitly show the `pip-sync` and `pip-compile` workflow for dependency management.

## [2.1.11] - 2024-05-24
### Changed
- **Documentation**: Clarified the distinction between `requirements.in` (Source of Truth) and `requirements.txt` (Deterministic Lockfile) in `CONTRIBUTING.md`.

## [2.1.9] - 2024-05-24
### Changed
- **Documentation**: Formalized `requirements.in` usage in `BNKprojects/1/ARCHITECTURE.md` and provided usage instructions in `Documentation/internal/CONTRIBUTING.md`.
## [2.1.19] - 2024-05-24
### Added
- **Tooling**: Generated a dedicated `.env` file for the Project 1 Python application to separate runtime configuration from testing shell scripts.

## [2.1.8] - 2024-05-24
### Added
- **Dependency Management**: Introduced `requirements.in` to support `pip-tools` for deterministic dependency resolution.
### Fixed
- **Code Quality**: Cleaned up redundant logic and artifacts in `BNKprojects/1/app.py`.
## [2.1.28] - 2024-05-24
### Security
- **Hardening**: Updated `app.py` to prevent execution if `SESSION_SECRET` or `KEYCLOAK_URL` are missing.
- **Tooling**: Added a `.env` existence check to `setup-and-run.sh` to prevent misconfigured launches.

## [2.1.7] - 2024-05-24
### Added
- **Documentation**: Created `BNKprojects/1/PYTHON_CODE_EXPLANATION.md` with detailed line-by-line analysis of `app.py` and `requirements.txt`.
### Changed
- **Documentation**: Updated `BNKprojects/1/.gitignore` to include the new explanation file.
## [2.1.37] - 2024-05-24
### Security
- **Hardening**: Explicitly prohibited the suggestion of `allUsers` or unauthenticated ingress in all agent protocols and troubleshooting documentation.
- **Architecture**: Reaffirmed the use of the `gcloud run services proxy` as the mandatory method for accessing private Cloud Run services to maintain Zero Trust.

## [2.1.6] - 2024-05-24
### Added
- **Python Implementation**: Created `BNKprojects/1/app.py` and `requirements.txt` as the official OIDC client implementation.
- **OIDC Integration**: Implemented Authorization Code Flow with PKCE and JWT role extraction in Python.
### Changed
- **Documentation**: Updated `BNKprojects/1/CHECKLIST.md` to reflect full completion of OIDC integration tasks.
## [2.1.36] - 2024-05-24
### Changed
- **Security**: Updated Identity Service IAM policy to allow `allUsers` (unauthenticated) ingress. This is a prerequisite for the OIDC front-channel flow, allowing users' browsers to reach the Keycloak login page. Note: This should not work like this. By design "allow `allUsers`" is forbiden. Please refer to security.md for more details.


## [2.1.5] - 2024-05-24
### Changed
- **Security**: Hardened Zero-Trust connectivity definitions in `BNKprojects/1/ARCHITECTURE.md`, mandating IAM-based database authentication via the Cloud SQL Python Connector.
## [2.1.25] - 2024-05-24
### Fixed
- **Tooling**: Resolved `ModuleNotFoundError` by enforcing `pip-sync` workflow for local execution.
- **Structure**: Removed duplicate `app.py` from the project root to maintain alignment with the `src/` directory standard defined in `Architecture.md`.
## [2.1.35] - 2024-05-24
### Fixed
- **Environment**: Updated `app.py` to use absolute pathing for `load_dotenv` to ensure configuration consistency regardless of the current working directory.
- **Observability**: Added startup logging to verify the active `KEYCLOAK_URL` upon application initialization.

## [2.1.4] - 2024-05-24
### Changed
- **Architecture**: Formalized Python as the exclusive language for the application service layer. 
- **Tech Stack**: Deprecated Node.js/JavaScript implementation paths in `CONTRIBUTING.md` and `ARCHITECTURE.md`.
## [2.1.24] - 2024-05-24
### Changed
- **Configuration**: Updated `.env` to reflect the Cloud Run URL for Keycloak.
- **Security**: Noted the requirement for GCP IAM authorization (Identity Tokens) when accessing the private Identity Service.
## [2.1.27] - 2024-05-24
### Added
- **Tooling**: Created `setup-and-run.sh` in Project 1 to automate virtual environment initialization, dependency synchronization, and application execution.

## [2.1.2] - 2024-05-24
### Changed
- **Documentation**: Reconciled `BNKprojects/1/CHECKLIST.md` to confirm OIDC redirect logic completion.
### Added
- **Strategic Goal**: Identified `test-transactions.sh` for Project 2 as the next mandatory compliance task per `TESTING.md`.

## [2.1.1] - 2024-05-24
### Added
- **Agent Protocols**: Mandated "preview in diff mode" for all AI-generated code suggestions in `AGENTS.md` (Global and Project 1).

## [2.1.0] - 2024-05-24
### Added
- **OIDC Integration**: Implemented Authorization Code Flow with PKCE logic for the `retail-app` service layer.
### Changed
- **Documentation**: Updated `BNKprojects/1/CHECKLIST.md` to reflect completion of redirect logic integration.

## [2.0.0] - 2024-05-24
### Changed
- **Focus Shift**: Transitioned from Service implementation to Global CI/CD and Release Safety (Project 3).
### Added
- **Decisions**: Formally deferred `test-transactions.sh` automation in favor of establishing the primary deployment pipeline.
- **Documentation**: Created `Documentation/internal/MONITORING.md` to define the cross-project observability and alerting strategy.
- **Strategy**: Initiated the "Release Safety" framework to enforce SAST and automated deployment gates for all Cloud Run services.

## [1.8.11] - 2024-05-24
### Added
- **Tooling**: Created `test-env.sh.example` as a template for developers.
### Changed
- **Documentation**: Synchronized `README-TESTING.md` with the new environment file requirements.
- **Documentation**: Cleaned up duplicate headers and empty categories in `CHANGELOG.md`.

## [1.8.10] - 2024-05-24
### Fixed
- **Tooling**: Updated `TROUBLESHOOTING_SCRIPTS.md` to document variable enforcement errors in `test-keycloak.sh`.
- **AI Operations**: Refined `GEMINI-TEST-PROTOCOL.md` to handle missing environment configuration signatures.

## [1.8.9] - 2024-05-24
### Changed
- **Security**: Removed all hardcoded default values from `test-keycloak.sh`.
- **Tooling**: Mandated the presence of `test-env.sh` for script execution; implemented strict variable validation and removed the "admin" password fallback.

## [1.8.8] - 2024-05-24
### Changed
- **Tooling**: Refactored `test-keycloak.sh` to remove hardcoded secret names and resource IDs.
- **Configuration**: Introduced `test-env.sh` to manage environment-specific variables for automated testing.

## [1.8.7] - 2024-05-24
### Added
- **Tooling**: Added `run_comprehensive_validation` to `test-keycloak.sh` to allow simultaneous execution of both Internal (Method 1) and External (Method 2) test suites.
- **Documentation**: Updated `README-TESTING.md` and `GEMINI-TEST-PROTOCOL.md` to reflect the new `all` testing argument.

## [1.8.6] - 2024-05-24
### Fixed
- **Security**: Corrected Secret Manager reference from `keycloak-admin-password` to `keycloak-administrator-password` in the test script.
- **Performance**: Optimized JDBC connection pool (`KC_DB_POOL_MAX_SIZE=20`) to prevent "Acquisition timeout" on `db-f1-micro` SQL instances.
### Added
- **Tooling**: Enhanced `test-keycloak.sh` with pre-flight infrastructure checks and exponential backoff for admin token retrieval.

## [1.8.5] - 2024-05-24
### Changed
- **AI Operations**: Updated `BNKprojects/1/GEMINI-TEST-PROTOCOL.md` with strict cost-control instructions to prevent resource upscaling.
- **Cost Management**: Prohibited AI-driven suggestions for increasing CPU/Memory or enabling always-on features without human approval.

## [1.8.4] - 2024-05-24
### Changed
- **AI Operations**: Updated `BNKprojects/1/GEMINI-TEST-PROTOCOL.md` to restrict troubleshooting scope to `test-keycloak.sh` output.
- **Security**: Explicitly prohibited Gemini from modifying Terraform files to maintain strict human-in-the-loop control over infrastructure.

## [1.8.3] - 2024-05-24
### Added
- **AI Operations**: Created `BNKprojects/1/GEMINI-TEST-PROTOCOL.md` to define autonomous troubleshooting logic for the Identity Service.
- **Security**: Embedded architectural constraints (VPC, Private IP, PKCE) into the AI testing workflow to prevent insecure "Click-Ops" suggestions.

## [1.8.2] - 2024-05-24
### Added
- **Documentation**: Created `README-TESTING.md` for Project 1 verification instructions.
- **Documentation**: Created `Documentation/internal/TESTING-KEYCLOAK-INTERNAL.md` to define security protocols for automated testing.

## [1.7.9] - 2024-05-24
### Added
- **Policy Enforcement**: Mandated **Declarative Configuration** for all service updates. Manual "Click-Ops" or direct container shell modifications are now strictly prohibited to prevent configuration drift and lost engineering hours.

## [1.7.8] - 2024-05-24
### Added
- **OIDC Configuration**: Transitioned `retail-app` client from manual UI setup to declarative configuration in `realm-export.json`.
- **Security**: Enforced **PKCE (S256)** and defined valid Redirect URIs and Web Origins for development within the JSON specification.

## [1.7.7] - 2024-05-24
### Fixed
- **Cloud Run Deployment**: Successfully restored Keycloak service by applying the actual Private IP to `KC_DB_URL` and configuring `KC_HTTP_CONTENT_SECURITY_POLICY` for Cloud Shell compatibility.
- **Connectivity**: Verified end-to-end connectivity between Cloud Run and Cloud SQL via the Serverless VPC Access Connector.

## [1.7.5] - 2024-05-24
### Fixed
- **Database Connectivity**: Resolved "Connection to localhost:5432 refused" error caused by inadvertent clearing of environment variables during manual CLI updates.
- **Configuration Management**: Documented Scenario J in `TROUBLESHOOTING.md` regarding the risks of using `--set-env-vars` on production-grade Cloud Run services.

## [1.7.4] - 2024-05-24
### Fixed
- **CLI Syntax**: Corrected `gcloud run` command syntax in troubleshooting docs where `--update-env-vars` and `--set-env-vars` were incorrectly combined.

## [1.7.3] - 2024-05-24
### Fixed
- **Troubleshooting**: Documented the "Admin UI Loading" hang specific to Cloud Shell Web Preview and provided verification steps.
- **Diagnostics**: Added instructions for extracting browser console logs and Network HAR/cURL data to `TROUBLESHOOTING.md`.

## [1.7.2] - 2024-05-24
### Fixed
- **Access Strategy**: Resolved Port 8080 conflict in GCP Cloud Shell by utilizing the `--port` flag with `gcloud run services proxy`.
- **Security**: Maintained "Private Service" posture by avoiding public `allUsers` IAM bindings during the OIDC configuration phase.
## [2.1.32] - 2024-05-24
### Fixed
- **Code Quality**: Added robust error handling to the `/login` route in `app.py` to catch OIDC discovery failures caused by misconfigured proxy settings or private service connectivity issues.
## [2.1.38] - 2024-05-24
### Security
- **Environment**: Recommended adding `venv/` to `.gitignore` to prevent committing platform-specific binaries and maintain repository hygiene, following the standardized `setup-and-run.sh` workflow.

## [1.7.1] - 2024-05-24
### Security
- **Verification**: Confirmed `403 Forbidden` response for direct unauthenticated browser access to Keycloak Cloud Run. This validates the "Private Service" posture and ensures IAM policies are enforcing the Zero Trust requirement.

## [1.7.0] - 2024-05-24
### Added
- **OIDC Integration**: Defined the technical specification for the `retail-app` client in the `AltmtrkBank` realm.
- **Security**: Mandated **PKCE (S256)** for the public client to mitigate code interception attacks.
- **Documentation**: Updated `PROJECT1_DETAILS.md` and `CHECKLIST.md` with OIDC implementation specifics.

## [1.6.7] - 2024-05-23
### Changed
- **Documentation**: Refined the Project 1 Development Plan and Checklist to break down OIDC and SAML integration into actionable sub-tasks.
- **Architecture**: Fixed redundant IAM section in `BNKprojects/1/ARCHITECTURE.md`.

## [1.6.6] - 2024-05-23
### Added
- **Verification**: Commenced post-deployment testing phase for Keycloak on Cloud Run using authenticated requests.
- **Testing**: Verified health endpoints (`/health/live`) via identity token-bearing `curl` commands; confirmed `200 OK` and `{"status": "UP"}`.

## [1.6.5] - 2024-05-22
### Changed
- **Security**: Decision made to keep Cloud Run service private. `403 Forbidden` is expected for unauthenticated external access.
- **Verification**: Updated verification protocol to check Cloud Run service status in GCP Console and use authenticated `gcloud` requests for testing.

## [1.6.4] - 2024-05-22
### Added
- **Verification**: Successfully deployed Keycloak to Cloud Run.
- **Documentation**: Initiated verification protocol (URL retrieval, Health Check, Admin Console login).

## [1.6.3] - 2024-05-22
### Fixed
- **Infrastructure**: Removed redundant `args` from `google_cloud_run_service` in `project1/main.tf`.
- **Root Cause**: Resolved a conflict where arguments were being appended to the Dockerfile's `ENTRYPOINT`, causing Keycloak to crash on startup.

## [1.6.2] - 2024-05-22
### Fixed
- **Documentation**: Resolved redundant VPC connector verification sections in `TROUBLESHOOTING.md`.
- **CI/CD**: Finalized deployment commands in `localTSkeycloakContainer.md` by replacing placeholders with concrete repository names.

## [1.6.1] - 2024-05-22
### Changed
- **CI/CD**: Updated `localTSkeycloakContainer.md` with the explicit `--tag` command for Cloud Build to ensure the `:v1` image is correctly pushed and recognized by Cloud Run.

## [1.6.0] - 2024-05-22
### Fixed
- **Local Verification**: Confirmed `kc.db = postgres` is active in the local container configuration.
- **Strategy**: Identified that Cloud Run is likely pulling the wrong image tag, causing the H2 driver error. Switched to explicit version tagging (`:v1`).

## [1.5.9] - 2024-05-22
### Fixed
- **Troubleshooting**: Identified Scenario F (H2 URL format error) in Cloud Run logs.
- **Root Cause**: Confirmed database vendor mismatch where H2 driver is active despite Postgres JDBC URL.

## [1.5.8] - 2024-05-22
### Changed
- **Troubleshooting**: Optimized log retrieval commands in `TROUBLESHOOTING.md` with pagination (`less`) and payload formatting to handle verbose output.
- **Documentation**: Removed redundant VPC verification sections in `TROUBLESHOOTING.md`.

## [1.5.7] - 2024-05-22
### Changed
- **Deployment**: Transitioned from Local Troubleshooting to Cloud Deployment Phase.
- **Strategy**: Initiated Cloud Build for the corrected Keycloak image including health fixes and realm imports.

## [1.5.6] - 2024-05-22
### Added
- **Configuration**: Created `realm-export.json` with `AltmtrkBank` realm, `retail-app` (OIDC), and `teller-portal` (SAML) skeletons.
- **Docker**: Updated `Dockerfile` to automatically import realm configuration on startup using the `--import-realm` flag.

## [1.5.5] - 2024-05-22
### Added
- **Troubleshooting**: Added steps for Browser Redirection (Redirect URI) fixes, Configuration Exporting, and Database Persistence verification to `localTSkeycloakContainer.md`.
- **Documentation**: Finalized local verification protocol before cloud deployment.

## [1.5.4] - 2024-05-22
### Fixed
- **Local Verification**: Confirmed `/health/live` returns `200 OK`. The build-time fix for `KC_HEALTH_ENABLED` is successful.
### Changed
- **Infrastructure**: Synchronized `project1/main.tf` with optimized `startup_probe` settings (60s delay, 20 failures) to ensure cloud deployment stability.

## [1.5.3] - 2024-05-22
### Changed
- **Docker Optimization**: Refactored the `Dockerfile` to move `KC_HEALTH_ENABLED` and the `build` command back to the `builder` stage. This preserves multi-stage benefits while ensuring health endpoints are baked into the optimized image.

## [1.5.2] - 2024-05-22
### Changed
- **Troubleshooting**: Identified that `KC_HEALTH_ENABLED` must be set during the build phase for `--optimized` mode.
- **Documentation**: Updated `localTSkeycloakContainer.md` and `TROUBLESHOOTING.md` to reflect build-time property requirements.

## [1.5.1] - 2024-05-22
### Fixed
- **Local Troubleshooting**: Identified `404 Not Found` on `/health/live` endpoint. 
- **Root Cause Analysis**: Confirmed that `KC_HEALTH_ENABLED` is likely missing or set to false, which directly correlates with the Cloud Run startup failures.

## [1.5.0] - 2024-05-22
### Fixed
- **Local Environment**: Confirmed successful local container startup. Logs verify Quarkus is listening on port 8080.
- **Troubleshooting**: Moving to Phase 2 (Local Health Check verification).

## [1.4.9] - 2024-05-22
### Changed
- **Infrastructure**: Increased `startup_probe` latency thresholds in Project 1 to accommodate JVM initialization on Cloud Run.
- **Documentation**: Updated `TROUBLESHOOTING.md` with more robust probe settings (260s total window).

## [1.4.8] - 2024-05-22
### Added
- **Troubleshooting**: Commenced deep-dive troubleshooting session. 
- **Strategy**: Established a two-phase verification protocol (Local Health Verification -> Cloud IAM/VPC Audit).

## [1.4.7] - Architecture Documentation Sync
### Changed
- **Documentation**: Updated `BNKprojects/1/ARCHITECTURE.md` to specify the startup arguments and the health check endpoint used by Cloud Run probes. Removed duplicate IAM section.

## [1.4.6] - Startup Command Correction
### Fixed
- **Keycloak Startup**: Added `args = ["start", "--optimized"]` to the Cloud Run service in `project1/main.tf`. This resolves the issue where the container would print the help menu and exit instead of starting the server.
- **Documentation**: Added Scenario E to `BNKprojects/1/TROUBLESHOOTING.md` to track this failure mode.

## [1.4.5] - Log Filtering Expansion
### Changed
- **Troubleshooting**: Expanded the `grep` command in `BNKprojects/1/TROUBLESHOOTING.md` to include `exec format error` and `Permission denied`, which are common "silent" killers that prevent Java from starting.

## [1.4.4] - Log Filtering Optimization
### Added
- **Troubleshooting**: Added an optimized `grep` command to `BNKprojects/1/TROUBLESHOOTING.md` to quickly identify Java exceptions and connection errors in Cloud Run logs.

## [1.4.3] - Deep Dive Troubleshooting
### Added
- **Troubleshooting**: Added "Critical Troubleshooting Steps" to `BNKprojects/1/TROUBLESHOOTING.md` covering architecture mismatches (M1/M2 Mac), application log inspection via gcloud, and VPC connector verification for private-only Cloud SQL.

## [1.4.2] - Commit Summary
### Added
- **Commit History**: Finalized today's session by documenting the stabilization of the Keycloak Identity service and the institutionalization of the "Docker Precision" protocol.

## [1.4.1] - Agent Troubleshooting Protocol
### Added
- **Protocols**: Updated `BNKprojects/1/AGENTS.md` and `Documentation/internal/AGENTS.md` with strict rules for Docker container naming. This ensures future interactions prioritize actual container discovery (`docker ps`) over service name assumptions.
- **Monitoring**: Documented the healthy idle state of Keycloak (~4% Mem) to serve as a baseline for future performance audits.

## [1.4.0] - Docker Naming Documentation
### Fixed
- **Troubleshooting**: Updated `localTSkeycloakContainer.md` to clarify that `docker stats` requires the actual container name (e.g., `container-keycloak-1`) rather than the service name, resolving "No such container" errors.

## [1.3.9] - Advanced Diagnostics Documentation
### Added
- **Troubleshooting**: Added `docker stats` and internal network connectivity tests to `localTSkeycloakContainer.md` to help diagnose "silent" failures like OOM or network isolation.

## [1.3.8] - Troubleshooting Workflow Refinement
### Added
- **Documentation**: Updated `localTSkeycloakContainer.md` to clarify that log inspection commands require a secondary terminal window when the primary process is running in foreground mode.

## [1.3.7] - Health Configuration Verified
### Fixed
- **Verification**: Confirmed `KC_HEALTH_ENABLED=true` is correctly mapped inside the container using `kc.sh show-config`. This resolves the root cause of Cloud Run 404 errors during startup probes.

## [1.3.6] - Health Extension Verification
### Added
- **Troubleshooting**: Added instructions to `localTSkeycloakContainer.md` for verifying Quarkus health extensions using `kc.sh show-config`. This ensures the build-time optimization included the necessary health modules.

## [1.3.5] - Health Check and Documentation Fix
### Fixed
- **Keycloak Probes**: Added `KC_HEALTH_ENABLED=true` to `project1/main.tf`. Without this, the `/health/live` endpoint returns 404, causing Cloud Run to fail health checks and restart the service.
- **Documentation**: Updated `ARCHITECTURE.md` to reflect the health check requirement and secret mapping mechanism.

## [1.3.4] - Documentation Sync
### Fixed
- **Architecture Alignment**: Updated `BNKprojects/1/ARCHITECTURE.md` to reflect `KC_HOSTNAME_STRICT=false`, resolving a contradiction with the troubleshooting guide and actual Cloud Run requirements.

## [1.3.3] - IAM Privileges Expansion
### Security
- **Service Account Roles**: Granted `roles/run.admin` and `roles/iam.serviceAccountUser` to the Keycloak service account (`keycloak-sa`) in `project1/main.tf`.

## [1.3.2] - Local Environment Verified
### Verified
- **Local Setup:** Confirmed successful startup of Keycloak and Postgres locally after resolving the race condition. Updated verification steps in `BNKprojects/1/localTSkeycloakContainer.md`.

## [1.3.1] - Local Development Stability
### Fixed
- **Container Race Condition**: Updated `BNKprojects/1/container/docker-compose.yaml` to include a `healthcheck` for Postgres and set Keycloak to `depends_on: service_healthy`. This prevents Keycloak from crashing while Postgres is performing its initial restart during database creation.

## [1.3.0] - Documentation Enhancements
### Added
- **Docker Compose Flags**: Clarified the difference between foreground (`up`) and detached (`up -d`) modes in `BNKprojects/1/localTSkeycloakContainer.md`.

## [1.2.9] - Troubleshooting Documentation
### Added
- **Connection Refused Guide**: Updated `BNKprojects/1/localTSkeycloakContainer.md` with specific steps to diagnose browser connection errors (Startup delay vs Container crash).

## [1.2.8] - Troubleshooting Updates
### Added
- **Docker Permissions**: Updated `BNKprojects/1/localTSkeycloakContainer.md` with instructions for resolving "permission denied" errors regarding the Docker socket.

## [1.2.7] - Local Documentation
### Added
- **Local Guide**: Created `BNKprojects/1/localTSkeycloakContainer.md` providing step-by-step instructions for troubleshooting the Keycloak container locally using Docker Compose.

## [1.2.6] - Performance Optimization
### Changed
- **Cloud Run Startup**: Enabled "Startup CPU Boost" (`run.googleapis.com/startup-cpu-boost`) for the Keycloak service in `project1/main.tf`. This provides additional CPU during container initialization to reduce cold start times, which is critical for Java/Quarkus applications.

## [1.2.5] - Documentation
### Added
- **Troubleshooting**: Created `BNKprojects/1/TROUBLESHOOTING.md` to capture knowledge regarding common Cloud Run failures (OOM, IAM, Hostname Strictness, Probes) encountered during Project 1 deployment.

## [1.2.4] - Project 1 Deployment Fixes
### Fixed
- **Keycloak Startup Loop**: Set `KC_HOSTNAME_STRICT=false` in `project1/main.tf`. Keycloak production mode requires a hostname, but Cloud Run URLs are dynamic. Disabling strictness allows the service to boot successfully.
- **Health Check Probe**: Corrected `startup_probe` syntax from camelCase to snake_case in `project1/main.tf`. Optimized settings for Java startup (`period_seconds=10`, `failure_threshold=12`) to prevent premature termination during JVM initialization.

## [1.2.3] - Local Development Configuration Update
### Changed
- **Docker Compose Command**: Removed `start-dev` override in `BNKprojects/1/container/docker-compose.yaml` to rely on the Dockerfile's default `start --optimized` command. This ensures local development uses the same optimized runtime as production while still allowing HTTP via environment variables.
- **Cleanup**: Removed duplicate `volumes` block in `BNKprojects/1/container/docker-compose.yaml`.

## [1.2.2] - Local Development Fix
### Fixed
- **Docker Compose Entrypoint**: Fixed `BNKprojects/1/container/docker-compose.yaml` to explicitly override the `entrypoint`. This resolves a conflict where the Dockerfile's `ENTRYPOINT ["...","start","--optimized"]` was being concatenated with the compose `command: ["start-dev"]`, causing the container to fail on startup.

## [1.2.1] - Project 1 Developer Experience
### Added
- **Local Development**: Added `docker-compose.yaml` to `BNKprojects/1/container/` to allow running Keycloak and PostgreSQL locally. Configured it to override production security flags (`KC_PROXY`, `KC_HOSTNAME_STRICT`) for local compatibility.
- **CI/CD**: Added `cloudbuild.yaml` to `BNKprojects/1/container/` to automate building and pushing the custom Keycloak image to Artifact Registry.

## [1.1.2] - Project 1 IAM & Permissions Fix
### Security
- **Service Account**: Created a dedicated Service Account (`keycloak-sa`) for the Keycloak Cloud Run service instead of using the default Compute Engine account.
- **Least Privilege**: Explicitly granted `roles/cloudsql.client` (for DB connection) and `roles/secretmanager.secretAccessor` (for DB/Admin passwords) to `keycloak-sa`.
- **Artifact Access**: Granted `roles/artifactregistry.reader` to `keycloak-sa` to ensure reliable image pulling.
- **IAM Syntax**: Updated Secret Manager IAM bindings in `project1` module to use `.secret_id` instead of `.id`. This prevents malformed resource IDs (e.g., `projects/p/secrets/projects/p/secrets/s`) ensuring permissions are correctly applied.
### Fixed
- **Container Crash**: Resolved `HealthCheckContainerError` by fixing missing IAM permissions that caused the Keycloak container to crash during startup (unable to access secrets/DB).

## [1.1.1] - Project 1 Deployment Fixes
### Fixed
- **Keycloak Resources**: Increased Cloud Run resource limits to `2000m` (2 vCPU) and `2Gi` Memory. The default `512Mi` was causing the Java container to crash (OOM) before startup completed, resulting in `Ready:False` errors.

## [1.1.0] - Project 1 Hardening & Private Networking
### Security
- **Cloud SQL Private IP**: Configured the Keycloak Cloud SQL instance to use a Private IP only, disabling its Public IP to reduce attack surface.
- **Cloud Run Private Connectivity**: Updated the Keycloak Cloud Run service to connect to Cloud SQL securely over the private VPC network using the Cloud SQL Auth Proxy (Unix Socket).
- **VPC Egress**: Configured the Cloud Run service's VPC connector with `egress = "all-traffic"` to ensure all outbound traffic is routed through the VPC and Cloud NAT, enabling static IPs for external service allow-listing.

### Fixed
- **Terraform Dependency**: Added an explicit `depends_on` to the Keycloak Cloud Run service to ensure the Artifact Registry repository is created first, resolving a race condition during deployment.
- **Container Startup**: Resolved a container crash by removing the conflicting `args = ["start-dev"]` from the Cloud Run service definition, allowing the container to use its correct `start --optimized` entrypoint.
- **Terraform Syntax**: Corrected an `Unsupported block type` error by replacing the `vpc_access` block with the appropriate `run.googleapis.com/vpc-access-connector` annotation for the Cloud Run v1 service.

### Changed
- **CI/CD Portability**: Refactored the Keycloak image mirroring process to use a parameterized Cloud Build file (`mirror-keycloak.yaml`) with substitutions, eliminating hardcoded project IDs and repository names.

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
    - Validated diagnostic queries for MFA timeouts.nsfers.
    - Deployed to Google Cloud Run (Region: `us-south1`).
    - Integrated with MongoDB Atlas for Audit Logging.
    - Implemented Step-Up Authentication logic for transactions >= $10,000.
    - Verified end-to-end flow with `curl` and MongoDB Compass.
    - Validated diagnostic queries for MFA timeouts.DB Compass.
    - Validated diagnostic queries for MFA timeouts.