# A router is required for Cloud NAT
resource "google_compute_router" "router" {
  name    = "main-router"
  project = var.compute_project_id
  region  = var.compute_region
  network = google_compute_network.vpc.id
}

# The Cloud NAT gateway for static egress IP
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "main-nat-gateway"
  project                            = var.compute_project_id
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}