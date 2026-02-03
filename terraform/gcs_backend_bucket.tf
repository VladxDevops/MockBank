# This file creates the GCS bucket for the Terraform remote state.


resource "google_storage_bucket" "terraform_state" {
  name          = var.terraform_state_bucket_name
  project       = var.compute_project_id
  location      = "US"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = "" # Using Google-managed keys.
  }

  lifecycle {
    prevent_destroy = true
  }
}
