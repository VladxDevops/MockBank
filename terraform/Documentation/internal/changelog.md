# Changelog

## [2026-05-28] - Infrastructure Migration to Project 0

### Added
- Created `MIGRATION.md` to track foundation migration progress and technical findings.
- Added `cloudresourcemanager.googleapis.com` and `sqladmin.googleapis.com` to the automated service enablement list in `module.project0`.
- Implemented `module.atlas_public_key_secret` and `module.atlas_private_key_secret` in `mongo_secrets.tf` for managed Atlas API keys.
- Added `variables.tf` to `modules/secret_manager` to support modular secret creation.
- Added `outputs.tf` to `modules/project0` to export VPC and networking details.

### Changed
- **Consolidation**: Migrated all core networking (`network.tf`, `nat.tf`), load balancing (`load_balancer.tf`), and foundational IAM (`iam.tf`) into the `project0` module.
- **Standardization**: Renamed all region-related variables to `compute_region` across the `project0` module and root configuration for project-wide consistency.
- **CI/CD Integration**: Updated `project1.tf` and `project3.tf` to depend on standardized outputs from `module.project0`.
- **Artifact Registry**: Renamed the primary repository to `bank-apps-registry` for a more professional and generic naming convention.

### Fixed
- Resolved "Undeclared Variable" errors by centralizing all root variables in the top-level `variables.tf`.
- Fixed "Duplicate Variable" errors by removing redundant declarations in `artifact_registry.tf` and `terraform.tf`.
- Resolved dependency race conditions by implementing explicit `depends_on` blocks for the Cloud Resource Manager API.
- Fixed 409 Conflict errors for existing secrets by importing them into the Terraform state.

### Note
- **Keycloak Identity**: Identity resources in `modules/project3/identity.tf` are temporarily commented out. They require a live Keycloak instance to be managed by the provider.
- **Service Status**: Keycloak Cloud Run service is defined but in a failed state until the container image is pushed to the new registry.
