resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}
