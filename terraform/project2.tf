module "project2" {
  source           = "./modules/project2"
  gcp_project_id   = var.compute_project_id
  docker_image     = "gcr.io/your-project-id/transaction-service:latest" # TODO: Replace with actual image
  atlas_org_id     = var.atlas_org_id
  vpc_connector_id = google_vpc_access_connector.connector.id
}
