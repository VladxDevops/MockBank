# This file defines the Artifact Registry repository for the project.

resource "google_artifact_registry_repository" "repository" {
  project       = var.compute_project_id
  location      = var.compute_region
  repository_id = var.artifact_registry_repository_id
  format        = "DOCKER"

  lifecycle {
    #prevent_destroy = true
  }
}

variable "artifact_registry_repository_id" {
  description = "name of the Artifact Registry Repository"
  type = string
}