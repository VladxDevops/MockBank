/**
 * Reusable CI/CD Module
 * This module creates the Workload Identity Federateion binding and Cloud Deploy pipeline for any service.
 */

resource "google_service_account" "service_actions_sa" {
  account_id   = "sa-${var.service_name}-cicd"
  display_name = "GitHub Actions SA for ${var.service_name}"
  project      = var.project_id
}

resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.service_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.workforce_identity_federation_pool_name}/attribute.repository/${var.github_repo}"
}

# Standardized IAM Roles for the Service
resource "google_project_iam_member" "roles" {
  for_each = toset([
    "roles/clouddeploy.releaser",
    "roles/clouddeploy.jobRunner",
    "roles/run.admin",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.service_actions_sa.email}"
}

resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  location = var.region
  name     = "${var.service_name}-pipeline"
  project  = var.project_id

  serial_pipeline {
    stages { target_id = var.dev_target_id }
    stages { target_id = var.test_target_id }
    stages { target_id = var.prod_target_id }
  }
}

output "service_account_email" {
  value = google_service_account.service_actions_sa.email
}
