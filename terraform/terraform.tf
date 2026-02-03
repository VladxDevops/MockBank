terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0" # You can specify a different version if needed
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.15.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
  backend "gcs" {
    bucket = "terraform_state_bckup_bnk-project"
    prefix = "terraform/state/dev"
    depends_on
  }

}

provider "google" {
  project = var.compute_project_id
  region  = "us-central1" # Replace with your desired GCP region
}

provider "mongodbatlas" {
  org_id      = var.atlas_org_id
  public_key  = data.google_secret_manager_secret_version.atlas_public_key.secret_data
  private_key = data.google_secret_manager_secret_version.atlas_private_key.secret_data
}

data "google_secret_manager_secret_version" "atlas_public_key" {
  project = var.compute_project_id
  secret  = "atlas_public_key"
}

data "google_secret_manager_secret_version" "atlas_private_key" {
  project = var.compute_project_id
  secret  = "atlas_private_key"
}
