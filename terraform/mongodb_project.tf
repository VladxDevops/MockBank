variable "atlas_project_name" {
  description = "The name of the MongoDB Atlas project."
  type        = string
  default     = "BankProject"
}

resource "mongodbatlas_project" "atlas_project" {
  name   = var.atlas_project_name
  org_id = var.atlas_org_id
}