resource "mongodbatlas_cluster" "cluster" {
  project_id   = mongodbatlas_project.project.id
  name         = "${var.service_name}-db"
  provider_name = "TENANT"
  backing_provider_name = "GCP"
  provider_region_name = "US_CENTRAL1"
  provider_instance_size_name = "M0"
}

resource "mongodbatlas_project" "project" {
  name   = "${var.service_name}-project"
  org_id = var.atlas_org_id
}

resource "mongodbatlas_database_user" "user" {
  project_id        = mongodbatlas_project.project.id
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

resource "mongodbatlas_project_ip_access_list" "ip_access_list" {
  project_id = mongodbatlas_project.project.id
  ip_address = "0.0.0.0/0" # Allow access from anywhere
}
