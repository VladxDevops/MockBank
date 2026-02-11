module "project2" {
  source = "./modules/project2"

  # Pass variables from the root configuration to the module
  gcp_project_id               = var.compute_project_id
  gcp_region                   = var.compute_region
  mongodb_atlas_cluster_region = var.mongodb_atlas_cluster_region
  docker_image                 = var.docker_image
  service_name                 = var.service_name
  vpc_connector_id             = google_vpc_access_connector.connector.id
  mongodb_atlas_org_id         = var.atlas_org_id

  # CRITICAL FIX: This links the module to the imported/managed project resource.
  # It ignores the static value in dev.tfvars and uses the real ID from the state.
  atlas_project_id = var.mongodb_atlas_project_id
}