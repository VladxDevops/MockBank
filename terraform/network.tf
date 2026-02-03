# This file defines the network resources for the project.

resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  project                 = var.compute_project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "main-subnet"
  project       = var.compute_project_id
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
}

resource "google_vpc_access_connector" "connector" {
  name          = "main-connector"
  project       = var.compute_project_id
  region        = "us-central1"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}
