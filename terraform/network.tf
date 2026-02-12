resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  project                 = var.compute_project_id
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
  name          = "avechector"
  project       = var.compute_project_id
  region        = var.compute_region
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