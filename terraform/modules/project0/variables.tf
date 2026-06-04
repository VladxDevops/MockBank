variable "compute_project_id" {
  description = "The GCP Project ID where services will be enabled"
  type        = string
}

variable "compute_region" {
  description = "The GCP region for resources"
  type        = string
}


variable "compute_project_number" {
  description = "The GCP Project Number"
  type        = string
}

variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository"
  type        = string
}

variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  sensitive   = true
}

variable "keycloak_admin_username" {
  description = "Username for Keycloak Admin API"
  type        = string
}

variable "keycloak_admin_password" {
  description = "Password for Keycloak Admin API"
  type        = string
  sensitive   = true
}

variable "keycloak_url" {
  description = "The URL of the Keycloak instance"
  type        = string
}

variable "github_repository" {
  description = "The GitHub repository in 'username/repo' format"
  type        = string
}

variable "github_actions_sa_id" {
  description = "The ID for the GitHub Actions Service Account"
  type        = string
}

variable "workforce_identity_federation_pool_id" {
  description = "The ID for the Workload Identity Pool"
  type        = string
}

variable "workforce_identity_federation_provider_id" {
  description = "The ID for the Workload Identity Provider"
  type        = string
}

variable "terraform_deployer_service_account" {
  description = "The email address of the service account used to run Terraform, used for administrative IAM bindings."
  type        = string
}

