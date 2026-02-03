# This file is for creating empty secrets in GCP Secret Manager.
# The values should be added manually to the secrets in the GCP console.
#
# How to use:
# 1. Run `terraform apply -target=module.atlas_public_key_secret -target=module.atlas_private_key_secret`
# 2. Go to the GCP console and add the secret values manually.

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
