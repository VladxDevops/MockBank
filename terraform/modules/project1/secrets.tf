resource "random_password" "retail_app_session_secret" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret_version" "retail_app_session_secret_version" {
  secret      = google_secret_manager_secret.retail_app_session_secret.id
  secret_data = random_password.retail_app_session_secret.result
}