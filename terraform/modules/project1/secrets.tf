resource "random_password" "retail_app_session_secret" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret_version" "retail_app_session_secret_version" {
  secret      = "retail-app-session-secret"
  secret_data = random_password.retail_app_session_secret.result
}