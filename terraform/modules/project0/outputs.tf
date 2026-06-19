output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "connector_id" {
  description = "The ID of the VPC Access Connector"
  value       = google_vpc_access_connector.connector.id
}

output "private_vpc_connection" {
  description = "The VPC peering connection for private services"
  value       = google_service_networking_connection.private_vpc_connection
}

output "github_actions_sa_email" {
  value = google_service_account.github_actions_sa.email
}

output "keycloak_database_password_secret_id" {
  value = google_secret_manager_secret.keycloak_database_password.id
}

output "keycloak_admin_password_secret_id" {
  value = google_secret_manager_secret.keycloak_administrator_password.id
}

output "retail_app_session_secret_id" {
  value = google_secret_manager_secret.retail_app_session_secret.id
}
