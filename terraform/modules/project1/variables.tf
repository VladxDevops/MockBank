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

#Artifact registry: 
variable "project1_repository" {
  description = "name of the Artifact Registry Repository"
  type        = string
}

variable "vpc_network_id" {
  description = "The self-link of the VPC network for private resources."
  type        = string
}

variable "vpc_connector_id" {
  description = "The ID of the Serverless VPC Access Connector."
  type        = string
}

variable "keycloak_serv_acc_account_id" {
  description = "The account ID for the Keycloak Service Account (passed from tfvars to avoid hardcoding)."
  type        = string
}

#Secret manager:
variable "keycloak_admin_password_secret_id" {
  description = "name of the secret for the keyCloak admin password"
  type        = string
}

variable "keycloak_database_password_secret_id" {
  description = "name of the secret for the keyCloak DataBase password"
  type        = string
}

