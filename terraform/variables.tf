variable "compute_project_id" {
  description = "The project ID to deploy the resources to"
  type        = string
}

variable "atlas_org_id" {
  description = "MongoDB Atlas organization ID."
  type        = string
  sensitive   = true
}

variable "terraform_state_bucket_name" {
  description = "The name of the GCS bucket to store the Terraform state. Must be globally unique."
  type        = string
}

variable "atlas_public_key" {
  description = "MongoDB Atlas public key."
  type        = string
  sensitive   = true
}

variable "atlas_private_key" {
  description = "MongoDB Atlas private key."
  type        = string
  sensitive   = true
}

# This variable is no longer needed because we are getting the ID
# directly from the mongodbatlas_project.atlas_project resource.
variable "docker_image" {
  description = "The Docker image to deploy to Cloud Run."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello" # Default placeholder
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
  default     = "transaction-service"
}

variable "vpc_connector_id" {
  description = "The ID of the VPC connector."
  type        = string
  default     = ""
}
