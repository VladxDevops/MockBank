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

variable "mongodb_atlas_project_id" {
  description = "MongoDB Atlas project ID."
  type        = string
}
