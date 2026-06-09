# Centralized IAM roles for the GitHub Actions / Terraform Service Account
# This ensures the deployment identity has all required permissions across the platform

resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = toset([
    "roles/run.admin",                # Manage Cloud Run services
    "roles/artifactregistry.admin",   # Manage Artifact Registry
    "roles/cloudsql.admin",           # Provision Cloud SQL
    "roles/serviceusage.serviceUsageAdmin", # Required to enable/disable APIs
    "roles/compute.networkAdmin",     # Manage VPC and Connectors
    "roles/iam.serviceAccountUser",   # Impersonate service accounts
    "roles/secretmanager.admin",      # Manage Secrets
    "roles/cloudbuild.builds.editor", # Submit builds
    "roles/storage.admin",            # Manage GCS buckets (Terraform State)
    "roles/logging.logWriter",        # Write logs
    "roles/clouddeploy.releaser"      # Create Cloud Deploy releases
  ])

  project = var.compute_project_id
  role    = each.key
  member  = "serviceAccount:${var.terraform_service_account_email}"

  # Ensure APIs are enabled before assigning roles that depend on them
  depends_on = [
    # This assumes the foundation services module is applied first in the CI/CD pipeline
  ]
}