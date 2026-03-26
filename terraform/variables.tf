variable "compute_region" {
  description = "The GCP region for resources."
  type        = string
}

variable "compute_project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "compute_project_number" {
  description = "The GCP project number, used for IAM bindings to Google-managed service accounts."
  type        = string
}

variable "atlas_org_id" {
  description = "The MongoDB Atlas Organization ID."
  type        = string
}

variable "mongodb_atlas_cluster_region" {
  description = "The region for the MongoDB Atlas cluster."
  type        = string
  default     = "US_CENTRAL"
}

variable "docker_image" {
  description = "The Docker image to deploy for the transaction service."
  type        = string
  default     = "gcr.io/cloudrun/hello" # Default to a placeholder image as per README
}

variable "service_name" {
  description = "The name of the Cloud Run service for Project 2."
  type        = string
  default     = "transaction-service"
}

variable "mongodb_atlas_project_id" {
  description = "The ID of the MongoDB Atlas project. If not provided, a new project will be created."
  type        = string
  default     = null
}


#project1: 

variable "terraform_deployer_service_account" {
  description = "The service account email used to deploy Terraform resources"
  type        = string
}

#Artifact Registry repository for Project1: 
variable "project1_repository"  {
  description = "name of the Artifact Registry Repository"
  type        = string
}

#Cloud Run Service account: 
variable "keycloak_serv_acc_account_id" {
  description = "The account ID for the Keycloak Service Account (passed from tfvars to avoid hardcoding)."
  type        = string
}

#Secret manager:

#Project1:
#Project1 KeyCloak admin Password secret id/name: 
variable "keycloak_admin_password_secret_id" {
  description = "name of the secret for the keyCloak admin password"
  type        = string
}

#Project1 KeyCloak DataBase Password secret id/name: 
variable "keycloak_database_password_secret_id" {
  description = "name of the secret for the keyCloak DataBase password"
  type        = string
}

###End of project1 Secrets. 