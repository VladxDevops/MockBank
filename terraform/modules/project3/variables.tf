variable "compute_project_id" {
  description = "The GCP project ID where Project 3 resources will be deployed."
  type        = string
}

variable "compute_region" {
  description = "The GCP region for the Cloud Deploy pipeline and deployment targets."
  type        = string
}

variable "workforce_identity_federation_pool_id" {
  description = "The unique identifier for the Workload Identity Pool."
  type        = string
}

variable "workforce_identity_federation_provider_id" {
  description = "The unique identifier for the Workload Identity Pool Provider."
  type        = string
}

variable "github_actions_sa_id" {
  description = "The account ID for the Service Account that GitHub Actions will impersonate for CI/CD."
  type        = string
}

variable "github_repository" {
  description = "The GitHub repository (owner/repo) allowed to authenticate via Workload Identity Federation."
  type        = string
}

variable "terraform_deployer_service_account" {
  description = "The email address of the service account used to run Terraform, used for administrative IAM bindings."
  type        = string
}
