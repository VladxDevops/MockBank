
terraform {
  backend "gcs" {
    bucket  = "DEV-terraform-state-Banckend-bucket"
    prefix  = "terraform/state"
    project = "bankproject-486308"
  }
  
  required_version = ">= 1.5.0"
}
