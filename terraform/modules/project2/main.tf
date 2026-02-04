
resource "google_service_account" "service_account" {
  project      = var.gcp_project_id
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
}

resource "google_cloud_run_v2_service" "service" {
  project  = var.gcp_project_id
  name     = var.service_name
  location = var.gcp_region

  template {
    service_account = google_service_account.service_account.email
    vpc_access {
      connector = var.vpc_connector_id
      egress    = "ALL_TRAFFIC"
    }
    containers {
      image = var.docker_image
    }
  }
}

resource "google_project_iam_member" "run_invoker" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
