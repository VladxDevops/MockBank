resource "google_secret_manager_secret" "secret" {
  project_id = var.project_id
  secret_id  = var.secret_id

  replication {
    automatic = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
