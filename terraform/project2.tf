module "project2" {
  source           = "./modules/project2"
  gcp_project_id   = var.compute_project_id
  docker_image     = "${google_artifact_registry_repository.repository.location}-docker.pkg.dev/${var.compute_project_id}/${google_artifact_registry_repository.repository.repository_id}/transaction-service:latest"
  atlas_org_id     = var.atlas_org_id
  vpc_connector_id = google_vpc_access_connector.connector.id
  gcp_region       = var.compute_region
}
