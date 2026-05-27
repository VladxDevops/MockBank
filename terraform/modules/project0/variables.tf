variable "compute_project_id" {
  description = "The GCP Project ID where services will be enabled"
  type        = string
}


variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  sensitive   = true
}

variable "keycloak_admin_username" {
  description = "Username for Keycloak Admin API"
  type        = string
}

variable "keycloak_admin_password" {
  description = "Password for Keycloak Admin API"
  type        = string
  sensitive   = true
}

variable "keycloak_url" {
  description = "The URL of the Keycloak instance"
  type        = string
}
