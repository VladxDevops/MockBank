# NOTE: Regional Load Balancer (Standard Network Tier) and static IP resources 
# inside this module are DISABLED for non-PROD environments to minimize costs.
# These resources should only be uncommented/enabled for PROD deployments.

module "project0" {
  source = "./modules/project0"

  compute_project_id                        = var.compute_project_id
  compute_project_number                    = var.compute_project_number
  compute_region                            = var.compute_region
  service_name                              = var.service_name
  artifact_registry_repository_id           = var.artifact_registry_repository_id
  atlas_public_key                          = var.bootstrap ? "bootstrap" : data.google_secret_manager_secret_version.atlas_public_key[0].secret_data
  atlas_private_key                         = var.bootstrap ? "bootstrap" : data.google_secret_manager_secret_version.atlas_private_key[0].secret_data
  keycloak_admin_username                   = var.keycloak_admin_username
  keycloak_admin_password                   = var.keycloak_admin_password
  keycloak_url                              = var.keycloak_url
  github_repository                         = var.github_repository
  github_actions_sa_id                      = var.github_actions_sa_id
  workforce_identity_federation_pool_id     = var.workforce_identity_federation_pool_id
  workforce_identity_federation_provider_id = var.workforce_identity_federation_provider_id
  terraform_deployer_service_account        = var.terraform_deployer_service_account
  remote_terraform_state_gcp_project        = var.remote_terraform_state_gcp_project
}

