
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
      env {
        name = "MONGO_URI"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_connection_secret.secret_id
            version = "latest"
          }
        }
      }
    }
  }
}

# This resource is more secure as it grants invoker permission only to this specific service, not the entire project.
resource "google_cloud_run_v2_service_iam_member" "run_invoker" {
  project = var.gcp_project_id
  location = google_cloud_run_v2_service.service.location
  name    = google_cloud_run_v2_service.service.name
  role    = "roles/run.invoker"
  member  = "allUsers" # Use "allUsers" to make the service publicly accessible.
}

# Grant the service account permission to access the database password secret
resource "google_secret_manager_secret_iam_member" "db_password_accessor" {
  project   = var.gcp_project_id
  secret_id = google_secret_manager_secret.db_connection_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account.email}"
}
