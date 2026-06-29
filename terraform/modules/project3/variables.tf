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

variable "github_actions_sa_email" {
  description = "The email address of the GitHub Actions service account, migrated from module.project0."
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

#Keycloak: 
variable "keycloak_url" {
  description = "The URL of the Keycloak instance (e.g., https://keycloak.example.com)."
  type        = string
}

variable "keycloak_administrator_username" {
  description = "The username for the Keycloak administrator account."
  type        = string
}

variable "keycloak_administrator_password" {
  description = "The password for the Keycloak administrator account, typically sourced from Secret Manager."
  type        = string
}

#Teller portal: 
#variable "teller_portal_certificate_id" {
#  description = "Teller portal Certificate ID"
#  type        = string
#}



###Habia una vez un barco chiquito...