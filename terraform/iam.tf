resource "google_project_iam_member" "cloudrun_vpc_access" {
  project = var.compute_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${var.compute_project_number}@serverless-robot-prod.iam.gserviceaccount.com"
}
