terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0" # You can specify a different version if needed
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15.0" # Changed from 1.15.4 to a valid constraint
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}


provider "google" {
  project = var.compute_project_id
  region  = var.compute_region
  #user_project_override = true #Disabled to remediate error failing to deploy keycloak instance. 
}

provider "keycloak" {
  client_id = "admin-cli"
  # During bootstrap we keep a local placeholder to avoid attempting
  # real Keycloak logins from CI. When not bootstrapping, use the
  # real `keycloak_url` and real admin credentials.
  username = var.bootstrap ? "bootstrap" : var.keycloak_administrator_username
  password = var.bootstrap ? "bootstrap" : var.keycloak_administrator_password
  url = var.bootstrap ? "http://localhost:8080" : (var.keycloak_url != "" ? var.keycloak_url : "http://localhost:8080")
}

provider "mongodbatlas" {
  public_key  = var.bootstrap ? "bootstrap" : data.google_secret_manager_secret_version.atlas_public_key[0].secret_data
  private_key = var.bootstrap ? "bootstrap" : data.google_secret_manager_secret_version.atlas_private_key[0].secret_data
}

data "google_secret_manager_secret_version" "atlas_public_key" {
  count   = var.bootstrap ? 0 : 1
  project = var.compute_project_id
  secret  = "atlas_public_key"
  version = "latest"
}

data "google_secret_manager_secret_version" "atlas_private_key" {
  count   = var.bootstrap ? 0 : 1
  project = var.compute_project_id
  secret  = "atlas_private_key"
  version = "latest"
}
