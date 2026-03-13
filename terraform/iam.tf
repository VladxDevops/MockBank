resource "google_project_iam_member" "cloudrun_vpc_access" {
  project = var.compute_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${var.compute_project_number}@serverless-robot-prod.iam.gserviceaccount.com"
}

# This grants the Google-managed Service Networking account the necessary permissions
# to create the VPC peering connection required for Cloud SQL private IP.
resource "google_project_iam_member" "sql_private_ip_permissions" {
  project = var.compute_project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:service-${var.compute_project_number}@service-networking.iam.gserviceaccount.com"
}

