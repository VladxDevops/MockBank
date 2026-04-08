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

    *   `Removed` for now removed features.
    *   `Fixed` for any bug fixes.
    *   `Security` in case of vulnerabilities.




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
    - Validated diagnostic queries for MFA timeouts.