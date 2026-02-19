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
  }
}


provider "google" {
  project               = var.compute_project_id
  region                = var.compute_region
  user_project_override = true
}

variable "bootstrap" {
  description = "Set to true to skip secret lookup during initial secret creation"
  type        = bool
  default     = false
}

provider "mongodbatlas" {
  public_key  = var.bootstrap ? "bootstrap" : data.google_secret_manager_secret_version.atlas_public_key[0].secret_data
  private_key = var.bootstrap ? "bootstrap" : data.google_secret_manager_secret_version.atlas_private_key[0].secret_data
}

data "google_secret_manager_secret_version" "atlas_public_key" {
  count   = var.bootstrap ? 0 : 1
  project = var.compute_project_id
  secret  = "atlas_public_key"
}

data "google_secret_manager_secret_version" "atlas_private_key" {
  count   = var.bootstrap ? 0 : 1
  project = var.compute_project_id
  secret  = "atlas_private_key"
}
