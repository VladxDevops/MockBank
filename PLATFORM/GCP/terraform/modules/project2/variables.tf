variable "gcp_project_id" {
  description = "The GCP Project ID where resources will be deployed."
  type        = string
}

variable "gcp_region" {
  description = "The default region for GCP resources."
  type        = string
  default     = "us-south1"
}

variable "service_name" {
  description = "The name of the service (e.g., transaction-service)."
  type        = string
  default     = "transaction-service"
}

variable "docker_image" {
  description = "The Docker image URI to deploy to Cloud Run."
  type        = string
  default     = "us-south1-docker.pkg.dev/dev-mockbank/dev-mongodb-atlas-container/transaction-service:latest"
}

variable "vpc_connector_id" {
  description = "The Serverless VPC Access Connector ID for private networking."
  type        = string
  default     = ""
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID."
  type        = string
}

variable "mongodb_atlas_cluster_region" {
  description = "The region for the MongoDB Atlas cluster (e.g., CENTRAL_US)."
  type        = string
  default     = "CENTRAL_US"
}
