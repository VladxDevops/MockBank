# --- Required GCP Services for Project 3 ---

resource "google_project_service" "cloud_deploy" {
  project            = var.compute_project_id
  service            = "deploy.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_credentials" {
  project            = var.compute_project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_resource_manager" {
  project            = var.compute_project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# --- Workload Identity Federation for GitHub Actions ---

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions automation"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [
    google_project_service.iam_credentials
  ]
}

# Service Account that GitHub Actions will impersonate
resource "google_service_account" "github_actions_sa" {
  account_id   = "sa-github-actions"
  display_name = "GitHub Actions CI/CD Service Account"
}

# Allow GitHub to impersonate the SA (Restrict to our specific repository)
resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
}

# Permissions for the CI/CD SA to manage deployments
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

# --- Google Cloud Deploy Pipeline (Project 2: Transaction Service) ---

resource "google_clouddeploy_delivery_pipeline" "transaction_pipeline" {
  location    = var.compute_region
  name        = "transaction-service-pipeline"
  description = "Managed delivery pipeline for the Transaction Service"

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.dev_target.target_id
    }
    stages {
      target_id = google_clouddeploy_target.test_target.target_id
    }
    stages {
      target_id = google_clouddeploy_target.prod_target.target_id
    }
  }

  depends_on = [
    google_project_service.cloud_deploy
  ]
}

# DEV Target (Cloud Run)
resource "google_clouddeploy_target" "dev_target" {
  location = var.compute_region
  name     = "dev-target"

  run {
    location = "projects/${var.compute_project_id}/locations/${var.compute_region}"
  }

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    service_account   = google_service_account.github_actions_sa.email
  }

  require_approval = false

  depends_on = [
    google_project_service.cloud_deploy
  ]
}

# TEST Target (Cloud Run)
resource "google_clouddeploy_target" "test_target" {
  location = var.compute_region
  name     = "test-target"

  run {
    location = "projects/${var.compute_project_id}/locations/${var.compute_region}"
  }

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    service_account   = google_service_account.github_actions_sa.email
  }

  # Requirement for promotion gate
  require_approval = true

  depends_on = [
    google_project_service.cloud_deploy
  ]
}

# PROD Target (Cloud Run)
resource "google_clouddeploy_target" "prod_target" {
  location          = var.compute_region
  name              = "prod-target"
  require_approval  = true

  run {
    location = "projects/${var.compute_project_id}/locations/${var.compute_region}"
  }

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    service_account   = google_service_account.github_actions_sa.email
  }

  depends_on = [
    google_project_service.cloud_deploy
  ]
}
