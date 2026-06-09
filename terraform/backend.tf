#File added to .gitignore to prevent exposure of GCP project id and bucket name. 

terraform {
  backend "gcs" {
    bucket  = "DEV-terraform-state-Banckend-bucket"
    prefix  = "terraform/state"
    project = "bankproject-486308"
  }
  
  required_version = ">= 1.5.0"
}
