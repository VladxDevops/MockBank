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


###Mongodb Atlas: 
variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  sensitive   = true
}


###Keycloak: 
variable "keycloak_administrator_username" {
  description = "Username for Keycloak Admin API"
  type        = string
}

variable "keycloak_administrator_password" {
  description = "Password for Keycloak Admin API"
  type        = string
  sensitive   = true
}

variable "keycloak_url" {
  description = "The URL of the Keycloak instance"
  type        = string
}

#keycloak_serv_acc_account_id:
variable "keycloak_serv_acc_account_id" {
  description = "The ID of the Keycloak Service Account"
  type        = string
}


###Github: 
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

#remote_terraform_state_gcp_ptoject:
variable "remote_terraform_state_gcp_project" {
  description = "GCP proejct where remote terraform states are stored"
  type        = string
}


#Habia una vez un barco chiquito...
# ------------------------------------------------------------------------------
# Monitoring & Observability Variables (Foundation / Project 0)
# Reference: Documentation/internal/MONITORING.md
# ------------------------------------------------------------------------------

variable "enable_alerting" {
  description = "Whether to provision Cloud Monitoring alert policies"
  type        = bool
  default     = true
}

variable "notification_channels" {
  description = "List of Cloud Monitoring notification channel IDs for alert routing"
  type        = list(string)
  default     = []
}

variable "mfa_timeout_threshold" {
  description = "Threshold count for MFA timeout failures in a 5-minute evaluation window (Severity 2)"
  type        = number
  default     = 5
}

variable "latency_threshold_ms" {
  description = "Threshold in milliseconds for p95 Cloud Run request latency (Severity 2)"
  type        = number
  default     = 1500
}

variable "project1_service_name" {
  description = "The name of the project 1 identity service (e.g., retail-app)"
  type        = string
  default     = "retail-app"
}

variable "transaction_service_name" {
  description = "The name of the project 2 transaction service"
  type        = string
  default     = "transaction-service"
}
