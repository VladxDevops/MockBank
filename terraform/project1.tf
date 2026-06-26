module "project1" {
  source = "./modules/project1"

  # Pass the required variables into the module
  compute_region                       = var.compute_region
  terraform_deployer_service_account   = var.terraform_deployer_service_account
  compute_project_id                   = var.compute_project_id
  project1_repository                  = var.project1_repository
  keycloak_admin_password_secret_id    = module.project0.keycloak_admin_password_secret_id
  keycloak_database_password_secret_id = module.project0.keycloak_database_password_secret_id
  project1_service_name                = var.project1_service_name
  retail_app_session_secret_id         = module.project0.retail_app_session_secret_id


  # Pass network details to the module using foundation outputs
  vpc_network_id   = module.project0.vpc_id
  vpc_connector_id = module.project0.connector_id

  # Ensure foundation networking is complete
  depends_on = [module.project0.private_vpc_connection]

  #Cloud Run Service account: 
  keycloak_serv_acc_account_id = var.keycloak_serv_acc_account_id

  #keycloak URL PLACEHOLDER for deploying first time: 
  keycloak_url            = var.keycloak_url
  keycloak_client_id      = var.keycloak_client_id
  keycloak_admin_username = var.keycloak_admin_username

  # Pass the GitHub Actions service account email to grant invoker access
  github_actions_sa_email = module.project0.github_actions_sa_email
}

###Habia una vez un barco chiquito...