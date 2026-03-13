resource "google_project_iam_member" "compute_sa_secret_accessor" {
  project = var.compute_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${var.compute_project_number}-compute@developer.gserviceaccount.com"
}
