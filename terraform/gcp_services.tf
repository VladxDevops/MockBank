# This file enables the necessary GCP services for the project.

resource "google_project_service" "gcp_services" {
  for_each = toset([
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])

  project = var.compute_project_id
  service = each.key

  lifecycle {
    prevent_destroy = true
  }
}
