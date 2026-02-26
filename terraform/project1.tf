# ==============================================================================
# PROJECT 1: Identity Provider (Keycloak) & Database
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Secrets Generation (Database & Admin Passwords)
# ------------------------------------------------------------------------------
resource "random_password" "keycloak_db_password" {
  length  = 16
  special = false
}

resource "random_password" "keycloak_admin_password" {
  length  = 16
  special = false
}

resource "google_secret_manager_secret" "keycloak_db_password" {
  secret_id = "keycloak-db-password"
  replication {
    auto {}
  }
  depends_on = [google_project_service.gcp_services]
}

resource "google_secret_manager_secret_version" "keycloak_db_password_val" {
  secret      = google_secret_manager_secret.keycloak_db_password.id
  secret_data = random_password.keycloak_db_password.result
}

resource "google_secret_manager_secret" "keycloak_admin_password" {
  secret_id = "keycloak-admin-password"
  replication {
    auto {}
  }
  depends_on = [google_project_service.gcp_services]
}

resource "google_secret_manager_secret_version" "keycloak_admin_password_val" {
  secret      = google_secret_manager_secret.keycloak_admin_password.id
  secret_data = random_password.keycloak_admin_password.result
}

# ------------------------------------------------------------------------------
# 2. Cloud SQL (PostgreSQL)
# ------------------------------------------------------------------------------
resource "google_sql_database_instance" "keycloak_db" {
  name_prefix      = "keycloak-db-"
  database_version = "POSTGRES_15"
  region           = var.compute_region
  
  settings {
    tier = "db-f1-micro" # Use micro for dev/cost savings
    
    ip_configuration {
      ipv4_enabled    = true # Allow public IP for easier initial connectivity (secure with authorized networks in prod)
      # For strict private IP, we would need a Private Service Access peering range configured.
      # Keeping public enabled for simplicity in this lab environment unless VPC peering is fully set up.
    }
  }

  deletion_protection = false # Allow destroy for lab environment
  depends_on          = [google_project_service.gcp_services]
}

resource "google_sql_database" "keycloak_schema" {
  name     = "keycloak"
  instance = google_sql_database_instance.keycloak_db.name
}

resource "google_sql_user" "keycloak_user" {
  name     = "keycloak"
  instance = google_sql_database_instance.keycloak_db.name
  password = random_password.keycloak_db_password.result
}

# ------------------------------------------------------------------------------
# 3. Cloud Run Service (Keycloak)
# ------------------------------------------------------------------------------
resource "google_cloud_run_service" "keycloak" {
  name     = "keycloak-service"
  location = var.compute_region

  template {
    spec {
      containers {
        image = "quay.io/keycloak/keycloak:24.0.1"
        
        # Start in dev mode for the lab (no strict HTTPS requirement on the container itself)
        args = ["start-dev"] 

        env {
          name  = "KC_DB"
          value = "postgres"
        }
        env {
          name  = "KC_DB_URL"
          value = "jdbc:postgresql://${google_sql_database_instance.keycloak_db.public_ip_address}:5432/keycloak"
        }
        env {
          name  = "KC_DB_USERNAME"
          value = google_sql_user.keycloak_user.name
        }
        env {
          name = "KC_DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.keycloak_db_password.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "KEYCLOAK_ADMIN"
          value = "admin"
        }
        env {
          name = "KEYCLOAK_ADMIN_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.keycloak_admin_password.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "KC_PROXY"
          value = "edge"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_secret_manager_secret_version.keycloak_db_password_val]
}