# modules/project0/main.tf - Centralized GCP Service Enablement

resource "google_project_service" "resource_manager" {
  project            = var.compute_project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = var.compute_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "iam" {
  project            = var.compute_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "cloud_run" {
  project            = var.compute_project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "secret_manager" {
  project            = var.compute_project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "sql_admin" {
  project            = var.compute_project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

# resource "google_project_service" "cloud_sql" {
#   project            = var.compute_project_id
#   service            = "cloudsql.googleapis.com"
#   disable_on_destroy = false
#   depends_on         = [google_project_service.resource_manager]
# }

resource "google_project_service" "vpc_access" {
  project            = var.compute_project_id
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "service_networking" {
  project            = var.compute_project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "artifact_registry" {
  project            = var.compute_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "cloud_build" {
  project            = var.compute_project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "cloud_deploy" {
  project            = var.compute_project_id
  service            = "clouddeploy.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "service_usage" {
  project            = var.compute_project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "logging" {
  project            = var.compute_project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

resource "google_project_service" "monitoring" {
  project            = var.compute_project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.resource_manager]
}

# --- Networking ---

resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  project                 = var.compute_project_id
  depends_on              = [google_project_service.compute]
}

resource "google_compute_subnetwork" "private" {
  name          = "main-subnet"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.id
  region        = var.compute_region
  project       = var.compute_project_id
}

resource "google_vpc_access_connector" "connector" {
  name    = "avechector"
  project = var.compute_project_id
  region  = var.compute_region
  subnet {
    name = google_compute_subnetwork.private.name
  }

  depends_on = [google_project_service.vpc_access]
}

resource "google_compute_firewall" "allow_egress" {
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

# --- NAT ---

resource "google_compute_router" "router" {
  name    = "main-router"
  project = var.compute_project_id
  region  = var.compute_region
  network = google_compute_network.vpc.id
}

resource "google_compute_address" "nat_ip" {
  name         = "nat-static-ip"
  project      = var.compute_project_id
  region       = var.compute_region
  network_tier = "STANDARD"
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "main-nat-gateway"
  project                            = var.compute_project_id
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option              = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --- VPC Peering for Private Services ---

resource "google_compute_global_address" "private_service_access_range" {
  project       = var.compute_project_id
  name          = "private-service-access-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_range.name]

  depends_on = [google_project_service.service_networking]
}

# --- IAM Foundation ---

resource "google_project_iam_member" "cloudrun_vpc_access" {
  project = var.compute_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${var.compute_project_number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "sql_private_ip_permissions" {
  project = var.compute_project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:service-${var.compute_project_number}@service-networking.iam.gserviceaccount.com"
}

# --- Artifact Registry ---

resource "google_artifact_registry_repository" "repository" {
  project       = var.compute_project_id
  location      = var.compute_region
  repository_id = var.artifact_registry_repository_id
  format        = "DOCKER"
  depends_on    = [google_project_service.artifact_registry]
}

# ==============================================================================
# COST OPTIMIZATION: Regional Load Balancer (Standard Tier)
# NOTE: For non-PROD environments (DEV/TEST), the Load Balancer is DISABLED.
# In DEV, ingress is handled via 'gcloud run services proxy'. 
# This architecture uses a Regional External LB on the STANDARD Network Tier 
# instead of Global/Premium to minimize regional data costs.
# ==============================================================================

# resource "google_compute_address" "bank_lb_ip" {
#   name         = "bank-platform-lb-ip"
#   project      = var.compute_project_id
#   region       = var.compute_region
#   address_type = "EXTERNAL"
#   network_tier = "STANDARD" # Downgraded for regional cost optimization
# }

# resource "google_compute_region_network_endpoint_group" "transaction_svc_neg" {
#   name                  = "transaction-svc-neg"
#   network_endpoint_type = "SERVERLESS"
#   region                = var.compute_region
#   project               = var.compute_project_id
#   cloud_run {
#     service = var.service_name
#   }
# }

# resource "google_compute_region_backend_service" "transaction_backend" {
#   name                  = "transaction-backend"
#   project               = var.compute_project_id
#   region                = var.compute_region
#   protocol              = "HTTP"
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   timeout_sec           = 30

#   backend {
#     group = google_compute_region_network_endpoint_group.transaction_svc_neg.id
#   }
# }

# resource "google_compute_region_url_map" "bank_url_map" {
#   name            = "bank-platform-url-map"
#   project         = var.compute_project_id
#   region          = var.compute_region
#   default_service = google_compute_region_backend_service.transaction_backend.id

#   host_rule {
#     hosts        = ["*"]
#     path_matcher = "all-paths"
#   }

#   path_matcher {
#     name            = "all-paths"
#     default_service = google_compute_region_backend_service.transaction_backend.id
#   }
# }

# resource "google_compute_region_target_http_proxy" "http_proxy" {
#   name    = "bank-http-proxy"
#   project = var.compute_project_id
#   region  = var.compute_region
#   url_map = google_compute_region_url_map.bank_url_map.id
# }

# resource "google_compute_forwarding_rule" "forwarding_rule" {
#   name                  = "bank-frontend-rule"
#   project               = var.compute_project_id
#   region                = var.compute_region
#   ip_address            = google_compute_address.bank_lb_ip.address
#   ip_protocol           = "TCP"
#   port_range            = "80"
#   target                = google_compute_region_target_http_proxy.http_proxy.id
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   network_tier          = "STANDARD" # Must match the IP tier
# }
