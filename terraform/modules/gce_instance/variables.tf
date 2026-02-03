variable "project_id" {
  description = "The project ID to deploy the instance to"
  type        = string
}
variable "zone" {
  description = "The zone to deploy the instance to"
  type        = string
  default     = "us-central1-a"
}
variable "instance_name" {
  description = "The name of the instance"
  type        = string
}
variable "machine_type" {
  description = "The machine type of the instance"
  type        = string
  default     = "e2-medium"
}
