# --- Google Cloud Deploy Pipeline ---
# Note: Foundational CI/CD resources (GitHub SA, WIF, and project-level IAM) 
# have been migrated to the foundation module (module.project0).

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
    service_account = var.github_actions_sa_email
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
    service_account = var.github_actions_sa_email
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
    service_account = var.github_actions_sa_email
  }
  require_approval = true
}
