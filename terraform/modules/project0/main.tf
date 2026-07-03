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
  nat_ip_allocate_option             = "MANUAL_ONLY"
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

# --- Workload Identity Federation (Migrated from Project 3) ---

resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.compute_project_id
  workload_identity_pool_id = var.workforce_identity_federation_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions automation"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.compute_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workforce_identity_federation_provider_id
  display_name                       = "GitHub Provider"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }
  attribute_condition = "attribute.repository == '${var.github_repository}'"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Shared CI/CD Service Account
resource "google_service_account" "github_actions_sa" {
  project      = var.compute_project_id
  account_id   = var.github_actions_sa_id
  display_name = "GitHub Actions CI/CD Service Account"
}

resource "google_service_account_iam_member" "workload_identity_federation_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
}

# --- Centralized CI/CD IAM Roles (Migrated from Project 3) ---
# Following AGENTS.md standards for explicit IAM declaration.

# Terraform Deployer Service Account Roles:

resource "google_project_iam_member" "terraform_sa_service_usage_admin" {
  project = var.compute_project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_workload_identity_admin" {
  project = var.compute_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_google_cloud_deploy_admin" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_cloud_deploy_releaser" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_artifact_registry_admin" {
  project = var.compute_project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_artifact_registry_writer" {
  project = var.compute_project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_cloud_build_editor" {
  project = var.compute_project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_cloud_run_admin" {
  project = var.compute_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_cloud_run_invoker" {
  project = var.compute_project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_cloud_sql_admin" {
  project = var.compute_project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_compute_network_admin" {
  project = var.compute_project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_iam_service_account_creator" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountCreator"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_infrastructure_admin" {
  project = var.compute_project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_project_iam_admin" {
  project = var.compute_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_secret_manager_admin" {
  project = var.compute_project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_secret_manager_accessor" {
  project = var.compute_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_iam_security_admin" {
  project = var.compute_project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_serverless_vpc_access_admin" {
  project = var.compute_project_id
  role    = "roles/vpcaccess.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_iam_service_account_user" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_service_usage_consumer" {
  project = var.compute_project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_storage_admin" {
  project = var.compute_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_cloudsql_admin" {
  project = var.compute_project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_remote_project_iam_admin" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_remote_secret_viewer" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_remote_secret_accessor" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_project_iam_member" "terraform_sa_logging_writer" {
  project = var.compute_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

# GitHub Actions Service Account Roles: 

#resourcemanager.projectIamAdmin"
resource "google_project_iam_member" "github_actions_sa_resource_manager_adimin" {
  project = var.compute_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}


resource "google_project_iam_member" "github_actions_service_usage_admin" {
  project = var.compute_project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_cloud_build_editor" {
  project = var.compute_project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_storage_admin" {
  project = var.compute_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_service_usage_consumer" {
  project = var.compute_project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_cloud_deploy_admin" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Cross-Project Backend State Access: Verify this Role was added to SA. 
resource "google_project_iam_member" "github_actions_sa_remote_storage_admin" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Cross-Project Backend State Access: Required for Project IAM management in the state project
resource "google_project_iam_member" "github_actions_sa_remote_iam_admin" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_sa_remote_secret_viewer" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_sa_remote_secret_accessor" {
  project = var.remote_terraform_state_gcp_project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}


resource "google_project_iam_member" "github_actions_cloud_run_admin" {
  project = var.compute_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_sa_cloud_run_invoker" {
  project = var.compute_project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_sa_openid_token_creator" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountOpenIdTokenCreator"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_sa_token_creator" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_artifact_registry_writer" {
  project = var.compute_project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_iam_workload_identity_admin" {
  project = var.compute_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_iam_service_account_creator" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountCreator"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_cloud_deploy_releaser" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_cloud_deploy_job_runner" {
  project = var.compute_project_id
  role    = "roles/clouddeploy.jobRunner"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_logging_writer" {
  project = var.compute_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_iam_service_account_user" {
  project = var.compute_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

#iam.devOps:
resource "google_project_iam_member" "github_actions_iam_devops" {
  project = var.compute_project_id
  role    = "roles/iam.devOps"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

#Secret Manager admin: 
resource "google_project_iam_member" "github_actions_sa_secret_manager_admin" {
  project = var.compute_project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "github_actions_sa_cloudsql_admin" {
  project = var.compute_project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

#"roles/compute.networkAdmin"
resource "google_project_iam_member" "github_actions_sa_network_admin" {
  project = var.compute_project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}


###Add role secretmanager.viewer to Github Service Account: 
resource "google_project_iam_member" "github_actions_sa_secret_viewer" {
  project = var.compute_project_id
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

###Add role secretmanager.secretAccessor to Github Service Account: 
resource "google_project_iam_member" "github_actions_sa_secret_accessor" {
  project = var.compute_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

#vpcaccess.user
resource "google_project_iam_member" "github_actions_sa_vpcaccess_user" {
  project = var.compute_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}


#artifactregistry.admin
resource "google_project_iam_member" "github_actions_sa_artifactregistry_admin" {
  project = var.compute_project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# iam.securityAdmin
resource "google_project_iam_member" "github_actions_sa_iam_security_admin" {
  project = var.compute_project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# roles/viewer: Required for GitHub Actions to stream Cloud Build logs
resource "google_project_iam_member" "github_actions_sa_viewer" {
  project = var.compute_project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}


# --- Keycloak Service Account Impersonation (Least Privilege) ---

resource "google_service_account_iam_member" "terraform_sa_impersonate_keycloak" {
  service_account_id = "projects/${var.compute_project_id}/serviceAccounts/${var.keycloak_serv_acc_account_id}@${var.compute_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_deployer_service_account}"
}

resource "google_service_account_iam_member" "github_actions_sa_impersonate_keycloak" {
  service_account_id = "projects/${var.compute_project_id}/serviceAccounts/${var.keycloak_serv_acc_account_id}@${var.compute_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_actions_sa.email}"
}





# --- Shared Secret Placeholders ---

resource "google_secret_manager_secret" "keycloak_database_password" {
  project   = var.compute_project_id
  secret_id = "keycloak-database-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "keycloak_administrator_password" {
  project   = var.compute_project_id
  secret_id = "keycloak-administrator-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "retail_app_session_secret" {
  project   = var.compute_project_id
  secret_id = "retail-app-session-secret"
  replication {
    auto {}
  }
}

#atlas_public_key_secret and atlas_private_key_secret are located at terraform/mongo_secrets. 

resource "google_secret_manager_secret" "keycloak_administrator_username_placeholder" {
  project   = var.compute_project_id
  secret_id = "keycloak-administrator-username"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "keycloak_administrator_username_val" {
  secret      = google_secret_manager_secret.keycloak_administrator_username_placeholder.id
  secret_data = var.keycloak_administrator_username
}

resource "google_secret_manager_secret" "keycloak_administrator_password_placeholder" {
  project   = var.compute_project_id
  secret_id = "keycloak-administrator-password-placeholder"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "keycloak_administrator_password_val" {
  secret      = google_secret_manager_secret.keycloak_administrator_password.id
  secret_data = var.keycloak_administrator_password
}



resource "google_secret_manager_secret" "mock_secret" {
  project   = var.compute_project_id
  secret_id = "mock-secret"
  replication {
    auto {}
  }
  lifecycle {
    prevent_destroy = true
  }
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



#Habia una vez un barco chiquito...