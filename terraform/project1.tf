# In terraform/project1.tf

module "project1" {
  source = "./modules/project1"

  # Pass the required variables into the module
  compute_region                     = var.compute_region
  terraform_deployer_service_account = var.terraform_deployer_service_account
  compute_project_id                 = var.compute_project_id
  project1_repository = var.project1_repository
}
