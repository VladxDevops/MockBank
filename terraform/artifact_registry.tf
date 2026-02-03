# This file defines the Artifact Registry repository for the project.

resource "google_artifact_registry_repository" "repository" {
  project       = var.compute_project_id
  location      = "us-central1"
  repository_id = "main-repository"
  format        = "DOCKER"

  lifecycle {
    prevent_destroy = true
  }
}
