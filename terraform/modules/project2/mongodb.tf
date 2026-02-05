
resource "mongodbatlas_cluster" "cluster" {
  project_id   = var.mongodb_atlas_project_id
  name         = "${var.service_name}-db"
  provider_name = "TENANT"
  backing_provider_name = "GCP"
  provider_region_name = var.gcp_region
  provider_instance_size_name = "M0"
}

resource "mongodbatlas_database_user" "user" {
  project_id        = var.mongodb_atlas_project_id
  username          = "user"
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
  override_special = "_%@"
}

data "http" "myip" {
  url = "https://api.ipify.org"
}

resource "mongodbatlas_project_ip_access_list" "ip_access_list" {
  project_id = var.mongodb_atlas_project_id
  ip_address = "${data.http.myip.response_body}/32"
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
