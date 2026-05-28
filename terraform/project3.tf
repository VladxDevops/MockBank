module "project3" {
  source = "./modules/project3"

  compute_project_id                        = var.compute_project_id
  compute_region                            = var.compute_region
  workforce_identity_federation_pool_id     = var.workforce_identity_federation_pool_id
  workforce_identity_federation_provider_id = var.workforce_identity_federation_provider_id
  github_actions_sa_id                      = var.github_actions_sa_id
  github_repository                         = var.github_repository
  terraform_deployer_service_account        = var.terraform_deployer_service_account
  
  keycloak_url            = var.keycloak_url
  keycloak_admin_username = var.keycloak_admin_username
  keycloak_admin_password = var.keycloak_admin_password
  
  teller_portal_certificate_id = var.teller_portal_certificate_id
}
