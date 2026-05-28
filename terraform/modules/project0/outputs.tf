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
