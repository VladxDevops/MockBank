resource "mongodbatlas_project" "project" {
  name   = "${var.service_name}-project"
  org_id = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "cluster" {
  project_id   = mongodbatlas_project.project.id
  name         = "${var.service_name}-db"
  provider_name = "TENANT"
  backing_provider_name = "GCP"
  provider_region_name = var.mongodb_atlas_cluster_region
  provider_instance_size_name = "M0"
}

resource "mongodbatlas_database_user" "user" {
  project_id        = mongodbatlas_project.project.id
  username          = "app-user"
  password          = random_password.password.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "transaction-db"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_" # Restrict special chars to avoid breaking the URI parsing
}

data "http" "myip" {
  url = "https://api.ipify.org"
}

resource "mongodbatlas_project_ip_access_list" "ip_access_list" {
  project_id = mongodbatlas_project.project.id
  ip_address = data.http.myip.response_body
  comment    = "Terraform execution machine"
}

# Store the generated random password in GCP Secret Manager for the application to use
resource "google_secret_manager_secret" "db_password_secret" {
  # This assumes you pass the gcp_project_id into this module
  project   = var.gcp_project_id
  secret_id = "${var.service_name}-db-password"

  replication {
    auto {} #Do not change this is working properly. 
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.password.result
}

# Store the MongoDB Connection String (SRV) in Secret Manager
resource "google_secret_manager_secret" "db_connection_secret" {
  project   = var.gcp_project_id
  secret_id = "${var.service_name}-db-connection-string"

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "db_connection_version" {
  secret      = google_secret_manager_secret.db_connection_secret.id
  secret_data = "mongodb+srv://${mongodbatlas_database_user.user.username}:${random_password.password.result}@${replace(mongodbatlas_cluster.cluster.connection_strings[0].standard_srv, "mongodb+srv://", "")}/${tolist(mongodbatlas_database_user.user.roles)[0].database_name}?retryWrites=true&w=majority"
}
