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

output "keycloak_administrator_password_secret_id" {
  value = google_secret_manager_secret.keycloak_administrator_password.id
}

output "retail_app_session_secret_id" {
  value = google_secret_manager_secret.retail_app_session_secret.id
}

# ------------------------------------------------------------------------------
# Monitoring Outputs
# ------------------------------------------------------------------------------

output "platform_observability_dashboard_id" {
  description = "The resource ID of the centralized platform observability dashboard in Cloud Monitoring."
  value       = google_monitoring_dashboard.platform_observability_dashboard.id
}

output "project2_audit_log_errors_metric_name" {
  description = "The name of the logging metric tracking MongoDB audit log errors."
  value       = google_logging_metric.project2_audit_log_errors.name
}

output "project2_mfa_challenges_metric_name" {
  description = "The name of the logging metric tracking MFA challenge events."
  value       = google_logging_metric.project2_mfa_challenges_issued.name
}

output "project2_mfa_timeouts_metric_name" {
  description = "The name of the logging metric tracking MFA timeouts."
  value       = google_logging_metric.project2_mfa_timeouts.name
}

output "keycloak_login_errors_metric_name" {
  description = "The name of the logging metric tracking Keycloak authentication failures."
  value       = google_logging_metric.keycloak_login_errors.name
}

output "keycloak_db_acquisition_timeouts_metric_name" {
  description = "The name of the logging metric tracking Keycloak Cloud SQL connection timeouts."
  value       = google_logging_metric.keycloak_db_acquisition_timeouts.name
}
