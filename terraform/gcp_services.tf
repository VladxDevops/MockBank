# This file enables the necessary GCP services for the project.

resource "google_project_service" "compute" {
  project            = var.compute_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "iam" {
  project            = var.compute_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "cloud_run" {
  project            = var.compute_project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "secret_manager" {
  project            = var.compute_project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "cloud_sql" {
  project            = var.compute_project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "vpc_access" {
  project            = var.compute_project_id
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "service_networking" {
  project            = var.compute_project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "artifact_registry" {
  project            = var.compute_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "cloud_build" {
  project            = var.compute_project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "cloud_deploy" {
  project            = var.compute_project_id
  service            = "clouddeploy.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "logging" {
  project            = var.compute_project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}

resource "google_project_service" "resource_manager" {
  project            = var.compute_project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
  lifecycle { prevent_destroy = true }
}
