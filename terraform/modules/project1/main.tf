# ==============================================================================
# PROJECT 1: Identity Provider (Keycloak) & Database
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Registry reference
# Registry is managed by Project 0 foundation. Project 1 consumes it via variable.

resource "google_project_iam_member" "terraform_sa_cloudsql_admin" {
  project = var.compute_project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}

# Grant the Terraform deployer service account permissions to manage Secret Manager secrets
resource "google_project_iam_member" "terraform_sa_secretmanager_admin" {
  project = var.compute_project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${var.terraform_deployer_service_account}"
}


# ------------------------------------------------------------------------------
# 1. Secrets Generation (Database & Admin Passwords)
# ------------------------------------------------------------------------------
resource "random_password" "keycloak_database_password" {
  length  = 16
  special = false
}

resource "random_id" "database_name_suffix" {
  byte_length = 4
}

#This saves the keycloak database password in secret manager value. 
resource "google_secret_manager_secret_version" "keycloak_database_password_value" {
  secret      = var.keycloak_database_password_secret_id
  secret_data = var.keycloak_database_password_value #Previously: random_password.keycloak_database_password.result
}

# ------------------------------------------------------------------------------
# 2. Cloud SQL (PostgreSQL) Instance
# ------------------------------------------------------------------------------
# NOTE: The principal (user or service account) running Terraform needs the "Cloud SQL Admin" (roles/cloudsql.admin) role on the project.
resource "google_sql_database_instance" "keycloak_db" {
  name             = "keycloak-database-${random_id.database_name_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.compute_region

  settings {
    tier = "db-g1-small" # Upgraded for stability and to prevent JDBC acquisition timeouts

    ip_configuration {
      ipv4_enabled    = false # Disable public IP for security.
      private_network = var.vpc_network_id
    }
  }

  deletion_protection = false # Allow destroy for lab environment
  depends_on          = [google_project_iam_member.terraform_sa_cloudsql_admin]
}

resource "google_sql_database" "keycloak_schema" {
  name     = "keycloak"
  instance = google_sql_database_instance.keycloak_db.name
}

resource "google_sql_user" "keycloak_user" {
  name     = "keycloak"
  instance = google_sql_database_instance.keycloak_db.name
  password = random_password.keycloak_database_password.result
}

# ------------------------------------------------------------------------------
# 2.1 IAM & Service Account (Least Privilege)
# ------------------------------------------------------------------------------
#KeyCloak Service Account: 
resource "google_service_account" "keycloak_sa" {
  account_id   = var.keycloak_serv_acc_account_id
  display_name = "Keycloak Service Account"
  project      = var.compute_project_id
}

# Required for Cloud Run to connect to Cloud SQL via the Auth Proxy
resource "google_project_iam_member" "keycloak_cloudsql_client" {
  project = var.compute_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

# Required to read the database and admin passwords from Secret Manager
resource "google_project_iam_member" "keycloak_database_secret_access" {
  project = var.compute_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

resource "google_project_iam_member" "keycloak_ar_reader" {
  project = var.compute_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

resource "google_project_iam_member" "keycloak_run_admin" {
  project = var.compute_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

# Allow the Terraform Deployer to act as the Keycloak Service Account
# This facilitates the "Identity Impersonation" protocol from AGENTS.md
resource "google_service_account_iam_member" "terraform_sa_impersonate_keycloak" {
  service_account_id = google_service_account.keycloak_sa.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_deployer_service_account}"
}

# IAM binding to allow the Keycloak/Retail-App service account to access the secret.
# Following AGENTS.md protocol using var.keycloak_serv_acc_account_id.
resource "google_secret_manager_secret_iam_member" "retail_app_session_secret_access" {
  secret_id = "retail-app-session-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

# ------------------------------------------------------------------------------
# 3. Cloud Run Service (Keycloak)
# ------------------------------------------------------------------------------
resource "google_cloud_run_service" "keycloak" {
  name     = "keycloak-service"
  location = var.compute_region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.keycloak_db.connection_name
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_id
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        "run.googleapis.com/startup-cpu-boost"    = "true"
      }
    }
    spec {
      service_account_name = google_service_account.keycloak_sa.email
      containers {
        image = "${var.compute_region}-docker.pkg.dev/${var.compute_project_id}/${var.project1_repository}/keycloak:v1"
        # Arguments are now handled by the Dockerfile ENTRYPOINT to avoid duplication.
        # ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized", "--import-realm"]

        env {
          name  = "KC_DB"
          value = "postgres"
        }
        env {
          name = "KC_DB_URL"
          # NOTE: sslmode=disable is a TEMPORARY diagnostic measure for VPC connectivity debugging.
          # In PROD, this must be switched to sslmode=verify-full or Cloud SQL Auth Proxy.
          value = "jdbc:postgresql://${google_sql_database_instance.keycloak_db.private_ip_address}:5432/${google_sql_database.keycloak_schema.name}?sslmode=disable"
        }
        env {
          name  = "KC_DB_USERNAME"
          value = google_sql_user.keycloak_user.name
        }
        env {
          name = "KC_DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = "keycloak-database-password"
              key  = "latest"
            }
          }
        }
        # Using admin username from Secret Manager for consistency and security
        env {
          name = "KEYCLOAK_ADMIN"
          value_from {
            secret_key_ref {
              name = "keycloak-administrator-username"
              key  = "latest"
            }
          }
        }
        # Password is recovered from the imported Secret Manager secret
        env {
          name = "KEYCLOAK_ADMIN_PASSWORD"
          value_from {
            secret_key_ref {
              name = "keycloak-administrator-password"
              key  = "latest"
            }
          }
        }
        env {
          name  = "KC_PROXY"
          value = "edge"
        }
        # Disable strict hostname checking for Cloud Run dynamic URLs
        env {
          name  = "KC_HOSTNAME_STRICT"
          value = "false"
        }
        env {
          name  = "KC_HEALTH_ENABLED"
          value = "true"
        }
        env {
          name  = "KEYCLOAK_CLIENT_ID"
          value = var.keycloak_client_id
        }
        env {
          name  = "KC_DB_POOL_MAX_SIZE"
          value = "20" #Currently set to 20 due to Cloud SQL Machine Type limitations.
        }
        env {
          name = "SESSION_SECRET"
          value_from {
            secret_key_ref {
              name = "retail-app-session-secret"
              key  = "latest"
            }
          }
        }

        resources {
          limits = {
            cpu    = "2000m"
            memory = "2Gi"
          }
        }

        startup_probe {
          initial_delay_seconds = 120
          timeout_seconds       = 10
          period_seconds        = 10
          failure_threshold     = 30
          http_get {
            path = "/health/live"
            port = 8080
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_service_account.keycloak_sa,
    google_secret_manager_secret_version.keycloak_database_password_value,
    # retail_app_session_secret_version is managed in secrets.tf
    google_sql_database.keycloak_schema,
    google_sql_user.keycloak_user
  ]
}

#Habia una vez un barco chiquito...