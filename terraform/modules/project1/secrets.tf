resource "google_secret_manager_secret" "retail_app_session_secret" {
  secret_id = "${var.project1_service_name}-session-secret"

  labels = {
    project = "project1"
    service = "retail-app"
  }

  replication {
    auto {} #Do not change this is working properly. 
  }
}