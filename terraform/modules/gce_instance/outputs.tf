output "instance_name" {
  description = "The name of the created instance"
  value       = google_compute_instance.default.name
}
