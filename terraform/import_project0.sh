#!/bin/bash
# Script to import existing Project 0 / Foundation resources into the current Terraform state.
# This prevents "already exists" errors during apply.

set -e

PROJECT_ID="dev-mockbank"
REGION="us-south1"

echo "Importing resources for project: $PROJECT_ID in region: $REGION"

# 1. VPC Network
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_network.vpc \
  projects/${PROJECT_ID}/global/networks/main-vpc

# 2. Subnetwork
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_subnetwork.private \
  projects/${PROJECT_ID}/regions/${REGION}/subnetworks/main-subnet

# 3. VPC Connector
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_vpc_access_connector.connector \
  projects/${PROJECT_ID}/locations/${REGION}/connectors/avechector

# 4. Router
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_router.router \
  projects/${PROJECT_ID}/regions/${REGION}/routers/main-router

# 5. NAT IP Address
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_address.nat_ip \
  projects/${PROJECT_ID}/regions/${REGION}/addresses/nat-static-ip

# 6. Router NAT
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_router_nat.nat_gateway \
  ${PROJECT_ID}/${REGION}/main-router/main-nat-gateway

# 7. Global Load Balancer IP
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_global_address.bank_lb_ip \
  projects/${PROJECT_ID}/global/addresses/bank-platform-lb-ip

# 8. Private Service Access Peering Range
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_global_address.private_service_access_range \
  projects/${PROJECT_ID}/global/addresses/private-service-access-range

# 9. VPC Peering Service Connection
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_service_networking_connection.private_vpc_connection \
  projects/${PROJECT_ID}/global/networks/main-vpc:servicenetworking.googleapis.com

# 10. Firewall rule (Allow egress)
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_firewall.allow_egress \
  projects/${PROJECT_ID}/global/firewalls/main-vpc-allow-egress

# 11. Cloud Run Serverless NEG
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_region_network_endpoint_group.transaction_svc_neg \
  projects/${PROJECT_ID}/regions/${REGION}/networkEndpointGroups/transaction-svc-neg

# 12. Backend Service
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_backend_service.transaction_backend \
  projects/${PROJECT_ID}/global/backendServices/transaction-backend

# 13. URL Map
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_url_map.bank_url_map \
  projects/${PROJECT_ID}/global/urlMaps/bank-platform-url-map

# 14. Target HTTP Proxy
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_target_http_proxy.http_proxy \
  projects/${PROJECT_ID}/global/targetHttpProxies/bank-http-proxy

# 15. Global Forwarding Rule
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project0.google_compute_global_forwarding_rule.forwarding_rule \
  projects/${PROJECT_ID}/global/forwardingRules/bank-frontend-rule

echo "Import complete!"
