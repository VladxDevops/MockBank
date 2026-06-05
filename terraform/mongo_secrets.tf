module "atlas_public_key_secret" {
  source     = "./modules/secret_manager"
  project_id = var.compute_project_id
  secret_id  = "atlas_public_key"
}

module "atlas_private_key_secret" {
  source     = "./modules/secret_manager"
  project_id = var.compute_project_id
  secret_id  = "atlas_private_key"
}
