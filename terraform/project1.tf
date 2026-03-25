# In terraform/project1.tf

module "project1" {
  source = "./modules/project1"

  # Pass the required variables into the module
  compute_region                     = var.compute_region
  terraform_deployer_service_account = var.terraform_deployer_service_account
  compute_project_id                 = var.compute_project_id
  project1_repository = var.project1_repository

  # Pass network details to the module
  vpc_network_id   = google_compute_network.vpc.id
  vpc_connector_id = google_vpc_access_connector.connector.id

  # Ensure the VPC peering for private services is complete before creating module resources
  depends_on = [google_service_networking_connection.private_vpc_connection]

  #Cloud Run Service account: 
  keycloak_serv_acc_account_id = var.keycloak_serv_acc_account_id
}
