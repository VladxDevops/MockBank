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
