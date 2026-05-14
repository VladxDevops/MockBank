resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  project                 = var.compute_project_id
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_subnetwork" "private" {
  name = "main-subnet"
  # This CIDR block is a /28, providing 16 total IP addresses (12 usable in GCP).
  # This size is required for the VPC Access Connector.
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.id
  region        = var.compute_region
  project       = var.compute_project_id
}

resource "google_vpc_access_connector" "connector" {
  # IMPORTANT: Replace "vpc-conn" with the actual name of your connector in GCP.
  name    = "avechector"
  project = var.compute_project_id
  region  = var.compute_region
  subnet {
    name = google_compute_subnetwork.private.name
  }

  # Ensures the VPC Access API is enabled before creating the connector.
  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "google_compute_firewall" "allow-egress" {
  name    = "main-vpc-allow-egress"
  network = google_compute_network.vpc.name
  project = var.compute_project_id

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  direction          = "EGRESS"
  priority           = 1000
}

# This IP range is reserved for Google's services (like Cloud SQL) to use
# when they peer with your VPC.
resource "google_compute_global_address" "private_service_access_range" {
  project       = var.compute_project_id
  name          = "private-service-access-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

# This resource establishes the VPC peering connection that allows Cloud SQL
# to have a private IP address inside your VPC.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_range.name]

  # This depends on the Service Networking API being enabled.
  depends_on = [google_project_service.gcp_services]
}