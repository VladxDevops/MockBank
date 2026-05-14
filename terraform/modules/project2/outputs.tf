output "mongodb_connection_string" {
  description = "MongoDB Atlas connection string for the application. Use this for the MONGO_URI environment variable."
  # Note: The cluster connection string is a list, we take the first one.
  value     = "mongodb+srv://${mongodbatlas_database_user.user.username}:${random_password.password.result}@${mongodbatlas_cluster.cluster.connection_strings[0].standard_srv}/${tolist(mongodbatlas_database_user.user.roles)[0].database_name}?retryWrites=true&w=majority"
  sensitive = true
}

output "database_password_secret_id" {
  description = "The ID of the GCP Secret Manager secret containing the database password."
  value       = google_secret_manager_secret.db_password_secret.secret_id
}
