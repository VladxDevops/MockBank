# Root Orchestrator (Project 0)

# Phase A: Enable Services
module "project0" {
  source                  = "./modules/project0"
  compute_project_id      = var.compute_project_id
  atlas_public_key        = var.atlas_public_key
  atlas_private_key       = var.atlas_private_key
  keycloak_admin_username = var.keycloak_admin_username
  keycloak_admin_password = var.keycloak_admin_password
  keycloak_url            = var.keycloak_url
}
