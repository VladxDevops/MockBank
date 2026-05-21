resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main_subnet" {
  name          = "main-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.compute_region
  network       = google_compute_network.main_vpc.id
}

# Required for Cloud Run to access Private IP Cloud SQL
resource "google_vpc_access_connector" "avechector" {
  name          = "avechector"
  region        = var.compute_region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.main_vpc.name
}

# Central Artifact Registry for all projects
resource "google_artifact_registry_repository" "bank_repo" {
  location      = var.compute_region
  repository_id = "bank-platform-repo"
  description   = "Docker repository for Bank Platform services"
  format        = "DOCKER"

  lifecycle {
    prevent_destroy = true
  }
}

# Cloud NAT for stable outbound static IP
resource "google_compute_router" "router" {
  name    = "main-router"
  region  = var.compute_region
  network = google_compute_network.main_vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "main-nat"
  router                             = google_compute_router.router.name
  region                             = var.compute_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}