/**
 * Global Provider Configuration
 * The logic for CI/CD and Project infrastructure is moved to project-specific 
 * files (e.g., project3.tf) and reusable modules (/modules).
 */
# Root Orchestrator (Project 0)

data "google_secret_manager_secret_version" "keycloak_admin_password" {
  secret  = var.keycloak_admin_password_secret_id
  project = var.compute_project_id
# Phase A: Enable Services
module "project0" {
  source             = "./modules/project0"
  compute_project_id = var.compute_project_id
}

data "google_secret_manager_secret_version" "keycloak_admin_username" {
  secret  = var.keycloak_admin_username
  project = var.compute_project_id
}

# Fetching the Keycloak URL from the Cloud Run service dynamically
data "google_cloud_run_service" "keycloak" {
  name     = var.project1_service_name
  location = var.compute_region
  project  = var.compute_project_id
}

# Phase B: Provision Infrastructure (Example Project 3 call)
module "project3" {
  source                                    = "./modules/project3"
  compute_project_id                        = var.compute_project_id
  compute_region                            = var.compute_region
  workforce_identity_federation_pool_id     = var.workforce_identity_federation_pool_id
  workforce_identity_federation_provider_id = var.workforce_identity_federation_provider_id
  github_actions_sa_id                      = var.github_actions_sa_id
  github_repository                         = var.github_repository
  terraform_deployer_service_account        = var.terraform_deployer_service_account
  keycloak_admin_username                   = data.google_secret_manager_secret_version.keycloak_admin_username.secret_data
  keycloak_admin_password                   = data.google_secret_manager_secret_version.keycloak_admin_password.secret_data
  keycloak_url                              = data.google_cloud_run_service.keycloak.status[0].url
  teller_portal_certificate_id              = var.teller_portal_certificate_id
  source             = "./modules/project3"
  compute_project_id = var.compute_project_id
  compute_region     = var.compute_region
  
  # Ensure APIs are enabled first
  depends_on = [module.project4]
  
  # ... other variables from dev.tfvars ...
} github_repository                         = var.github_repository
  terraform_deployer_service_account        = var.terraform_deployer_service_account
  keycloak_admin_username                   = data.google_secret_manager_secret_version.keycloak_admin_username.secret_data
  keycloak_admin_password                   = data.google_secret_manager_secret_version.keycloak_admin_password.secret_data
  keycloak_url                              = data.google_cloud_run_service.keycloak.status[0].url
  teller_portal_certificate_id              = var.teller_portal_certificate_id
  source             = "./modules/project3"
  compute_project_id = var.compute_project_id
  compute_region     = var.compute_region
  
  # Ensure APIs are enabled first
  depends_on = [module.project4]
  
  # ... other variables from dev.tfvars ...
}