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


variable "atlas_org_id" {
  description = "MongoDB Atlas Organization ID."
  type        = string
}

variable "keycloak_admin_password" {
  description = "Password for the Keycloak administrator."
  type        = string
  sensitive   = true
}