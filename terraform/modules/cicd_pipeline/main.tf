/**
 * Reusable CI/CD Module
 * This module creates the Workload Identity Federateion binding and Cloud Deploy pipeline for any service.
 */

resource "google_service_account" "service_actions_sa" {
  account_id   = "sa-${var.service_name}-cicd"
  display_name = "GitHub Actions SA for ${var.service_name}"
  project      = var.compute_project_id
}

resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.service_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.workforce_identity_federation_pool_name}/attribute.repository/${var.github_repo}"
}

# --- Standardized IAM Roles for the Service ---
#
# Note: For clarity and individual management, IAM roles are declared as
# separate `google_project_iam_member` resources rather than using `for_each`.
# This allows for easier modification, specific `depends_on` clauses, or
# lifecycle rules for each role if needed in the future.

resource "google_project_iam_member" "clouddeploy_releaser" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_service_account.service_actions_sa.email}"
}

resource "google_project_iam_member" "clouddeploy_job_runner" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.jobRunner"
  member  = "serviceAccount:${google_service_account.service_actions_sa.email}"
}

resource "google_project_iam_member" "run_admin" {
  project = var.compute_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.service_actions_sa.email}"
}

resource "google_project_iam_member" "logging_log_writer" {
  project = var.compute_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_actions_sa.email}"
}

resource "google_project_iam_member" "iam_service_account_user" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.service_actions_sa.email}"
}

# --- End of IAM Role Declarations ---

resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  location = var.compute_region
  name     = "${var.service_name}-pipeline"
  project  = var.compute_project_id

  serial_pipeline {
    stages { target_id = var.dev_target_id }
    stages { target_id = var.test_target_id }
    stages { target_id = var.prod_target_id }
  }
}

output "service_account_email" {
  value = google_service_account.service_actions_sa.email
}
