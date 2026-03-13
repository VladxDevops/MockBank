#project ID: 
variable "compute_project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "compute_region" {
  description = "The GCP region for resources."
  type        = string
}

variable "terraform_deployer_service_account" {
  description = "The service account email used to deploy Terraform resources"
  type        = string
}
