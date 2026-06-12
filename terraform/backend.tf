
terraform {
  backend "gcs" {
    bucket = "terraform_state_bckup_bnk-project"
    prefix = "terraform/state"
  }

  #required_version = ">= 1.5.0"
}
