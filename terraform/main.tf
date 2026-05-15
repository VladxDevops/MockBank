/**
 * Global Provider Configuration
 * The logic for CI/CD and Project infrastructure is moved to project-specific 
 * files (e.g., project3.tf) and reusable modules (/modules).
 */

module "project3" {
  source                                    = "./modules/project3"
  compute_project_id                        = var.compute_project_id
  compute_region                            = var.compute_region
  workforce_identity_federation_pool_id     = var.workforce_identity_federation_pool_id
  workforce_identity_federation_provider_id = var.workforce_identity_federation_provider_id
  github_actions_sa_id                      = var.github_actions_sa_id
  github_repository                         = var.github_repository
  terraform_deployer_service_account        = var.terraform_deployer_service_account
}