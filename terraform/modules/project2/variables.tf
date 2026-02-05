variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
  default     = "transaction-service"
}

variable "docker_image" {
  description = "The Docker image for the Cloud Run service."
  type        = string
}

variable "mongodb_atlas_project_id" {
  description = "MongoDB Atlas project ID."
  type        = string
}

variable "vpc_connector_id" {
  description = "The ID of the VPC connector."
  type        = string
  default     = ""
}
