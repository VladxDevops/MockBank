variable "compute_project_id" {
  description = "The project ID to deploy the resources to"
  type        = string
}

variable "compute_region" {
  description = "The GCP region to deploy resources in."
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "The name of the GCS bucket to store the Terraform state. Must be globally unique."
  type        = string
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
  #default     = "transaction-service"
}

#variable "gcp_region" { ###May not be necessary. This variable is used by the project2 module. 
#  description = "The GCP region to deploy resources in."
#  type        = string
#}

#Mongodb Atlas: 

variable "atlas_org_id" {
  description = "MongoDB Atlas organization ID."
  type        = string
  #sensitive   = true
}

variable "mongodb_atlas_project_id" {
  description = "MongoDB Atlas project ID."
  type        = string
}

#mongodb_atlas_cluster_region:
variable "mongodb_atlas_cluster_region" {
  description = "The GCP region to deploy resources in mongodb Atlas."
  type        = string
}