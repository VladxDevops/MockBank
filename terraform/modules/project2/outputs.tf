output "service_url" {
  description = "The URL of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.uri
}

output "mongodbatlas_project_id" {
  description = "The ID of the MongoDB Atlas project."
  value       = var.mongodb_atlas_project_id
}
