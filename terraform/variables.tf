variable "compute_project_id" {
  description = "The GCP Project ID where resources will be deployed."
  type        = string
}

variable "compute_project_number" {
  description = "The GCP Project Number."
  type        = string
}

variable "compute_region" {
  description = "The default region for GCP resources."
  type        = string
  default     = "us-south1"
}

variable "terraform_deployer_service_account" {
  description = "The email address of the service account used to run Terraform."
  type        = string
}

variable "atlas_org_id" {
  description = "MongoDB Atlas Organization ID."
  type        = string
}

variable "mongodb_atlas_project_id" {
  description = "The ID of the MongoDB Atlas project."
  type        = string
}

variable "mongodb_atlas_cluster_region" {
  description = "The region for the MongoDB Atlas cluster."
  type        = string
}

variable "service_name" {
  description = "The name of the service (e.g., transaction-service)."
  type        = string
}

#remote_terraform_state_gcp_ptoject:
variable "remote_terraform_state_gcp_project" {
  description = "GCP proejct where remote terraform states are stored"
  type        = string
}


variable "terraform_state_bucket_name" {
  description = "The name of the GCS bucket for Terraform state."
  type        = string
}

variable "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
}

variable "project1_repository" {
  description = "The Artifact Registry repository for project1."
  type        = string
}

variable "keycloak_admin_password_secret_id" {
  description = "The Secret Manager ID for the Keycloak admin password."
  type        = string
}

variable "keycloak_database_password_secret_id" {
  description = "The Secret Manager ID for the Keycloak database password."
  type        = string
}

variable "keycloak_serv_acc_account_id" {
  description = "The account ID for the Keycloak service account."
  type        = string
}

variable "project1_service_name" {
  description = "The name of the project1 service (e.g., retail-app)."
  type        = string
}

variable "github_repository" {
  description = "The GitHub repository for project3."
  type        = string
}

variable "github_actions_sa_id" {
  description = "The ID of the GitHub Actions service account."
  type        = string
}

variable "workforce_identity_federation_pool_id" {
  description = "The ID of the Workload Identity Federation pool."
  type        = string
}

variable "workforce_identity_federation_provider_id" {
  description = "The ID of the Workload Identity Federation provider."
  type        = string
}

#variable "teller_portal_certificate_id" {
#  description = "Teller portal Certificate ID"
#  type        = string
#  default     = "teller-portal-saml-cert"
#}

#Keycloak: 
variable "keycloak_admin_username" {
  description = "Username for Keycloak Admin API"
  type        = string
  default     = ""
}

variable "keycloak_admin_password" {
  description = "Password for the Keycloak administrator."
  type        = string
  sensitive   = true
}

variable "keycloak_url" {
  description = "The URL of the Keycloak instance"
  type        = string
  default     = ""
}

#keycloak_client_id
variable "keycloak_client_id" {
  description = "Keycloak Clien ID"
  type        = string
}

variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
  default     = ""
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "bootstrap" {
  description = "Set to true to skip secret lookup during initial secret creation"
  type        = bool
  default     = false
}
