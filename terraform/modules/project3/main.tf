# --- Workload Identity Federation for GitHub Actions ---
# Migrated to module.project0 for foundational security architecture.

# Allow GitHub to impersonate the SA
resource "google_service_account_iam_member" "workload_identity_federation_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
}

# --- IAM Roles (Separated per AGENTS.md Standards) ---

#Terraform service account: 
resource "google_project_iam_member" "terraform_sa_workload_identity_admin" {
  project = var.compute_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_google_cloud_deploy_admin" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

#Github Actions Service account Deployer:
# Grant Service Usage Admin to the GitHub Actions Service Account.
# This allows the CI/CD pipeline to enable or disable GCP services as defined in Terraform configurations.
resource "google_project_iam_member" "github_actions_service_usage_admin" {
  project = var.compute_project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}" #Mock Comment to rePush. Remove later. 
}

resource "google_project_iam_member" "github_actions_cloud_build_editor" {
  project = var.compute_project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_storage_admin" {
  project = var.compute_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_service_usage_consumer" {
  project = var.compute_project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "cloud_deploy_admin" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "cloud_run_admin" {
  project = var.compute_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.compute_project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "iam_workload_identity_admin" {
  project = var.compute_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "cloud_deploy_releaser" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "cloud_deploy_job_runner" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.jobRunner"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "logging_writer" {
  project = var.compute_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "iam_service_account_user" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# --- Google Cloud Deploy Pipeline ---

resource "google_clouddeploy_delivery_pipeline" "transaction_pipeline" {
  project     = var.compute_project_id
  location    = var.compute_region
  name        = "transaction-service-pipeline"
  description = "Managed delivery pipeline for the Transaction Service"

  serial_pipeline {
    stages { target_id = google_clouddeploy_target.dev_target.name }
    stages { target_id = google_clouddeploy_target.test_target.name }
    stages { target_id = google_clouddeploy_target.prod_target.name }
  }

  #depends_on = [google_project_service.cloud_deploy]
}

resource "google_clouddeploy_target" "dev_target" {
  project  = var.compute_project_id
  location = var.compute_region
  name     = "dev-target"
  run { location = "projects/${var.compute_project_id}/locations/${var.compute_region}" }
  execution_configs {
    usages          = ["RENDER", "DEPLOY"]
    service_account = google_service_account.github_actions_sa.email
  }
  require_approval = false
}

resource "google_clouddeploy_target" "test_target" {
  project  = var.compute_project_id
  location = var.compute_region
  name     = "test-target"
  run { location = "projects/${var.compute_project_id}/locations/${var.compute_region}" }
  execution_configs {
    usages          = ["RENDER", "DEPLOY"]
    service_account = google_service_account.github_actions_sa.email
  }
  require_approval = true
}

resource "google_clouddeploy_target" "prod_target" {
  project  = var.compute_project_id
  location = var.compute_region
  name     = "prod-target"
  run { location = "projects/${var.compute_project_id}/locations/${var.compute_region}" }
  execution_configs {
    usages          = ["RENDER", "DEPLOY"]
    service_account = google_service_account.github_actions_sa.email
  }
  require_approval = true
}
