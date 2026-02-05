output "debug_atlas_project_id" {
  description = "The ID of the MongoDB Atlas Project currently in the Terraform state."
  value       = mongodbatlas_project.atlas_project.id
}