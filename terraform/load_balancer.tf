# 1. Reserve a Global Static IP for the Bank API
### Note: While Cloud Run provides a default URL, a Global Static IP is required 
# for the Global External Load Balancer. This enables the use of Cloud Armor 
# (WAF) and a unified entry point for all microservices, adhering to the 
# "Security First" objective of this educational platform.
resource "google_compute_global_address" "bank_lb_ip" {
  name         = "bank-platform-lb-ip"
  project      = var.compute_project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# 2. Serverless NEG for Transaction Service (Project 2)
resource "google_compute_region_network_endpoint_group" "transaction_svc_neg" {
  name                  = "transaction-svc-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.compute_region
  project               = var.compute_project_id
  cloud_run {
    service = var.service_name
  }
}

# 3. Backend Service with Cloud Armor Placeholder
resource "google_compute_backend_service" "transaction_backend" {
  name                  = "transaction-backend"
  project               = var.compute_project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30

  backend {
    group = google_compute_region_network_endpoint_group.transaction_svc_neg.id
  }

  # Security Note: Cloud Armor Security Policy would be linked here
  # security_policy = google_compute_security_policy.bank_waf_policy.id
}

# 4. URL Map (Routing Logic)
resource "google_compute_url_map" "bank_url_map" {
  name            = "bank-platform-url-map"
  project         = var.compute_project_id
  default_service = google_compute_backend_service.transaction_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "all-paths"
  }

  path_matcher {
    name            = "all-paths"
    default_service = google_compute_backend_service.transaction_backend.id

    # Example routing for Project 1 (Identity) could be added here
    # path_rule {
    #   paths   = ["/auth/*"]
    #   service = google_compute_backend_service.identity_backend.id
    # }
  }
}

# 5. HTTP Target Proxy (Note: For PROD, use Target HTTPS Proxy)
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "bank-http-proxy"
  project = var.compute_project_id
  url_map = google_compute_url_map.bank_url_map.id
}

# 6. Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "bank-frontend-rule"
  project               = var.compute_project_id
  ip_address            = google_compute_global_address.bank_lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}