#!/bin/bash
# State cleanup script for Altmtrk2026 Bank Platform
# Removes redundant root resources and ghost resources from Project 2 and MongoDB Atlas.

# 1. Remove Legacy Root Resources (Now managed by Project 0)
terraform state rm google_compute_network.vpc
terraform state rm google_compute_subnetwork.subnet
terraform state rm google_artifact_registry_repository.repository
terraform state rm 'google_project_service.gcp_services["artifactregistry.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["cloudresourcemanager.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["compute.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["iam.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["run.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["secretmanager.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["servicenetworking.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["sqladmin.googleapis.com"]'
terraform state rm 'google_project_service.gcp_services["vpcaccess.googleapis.com"]'
terraform state rm google_vpc_access_connector.connector

# 2. Remove Project 2 (Transactions) Ghost Resources
terraform state rm module.project2

# 3. Remove MongoDB Atlas Ghost Resources
terraform state rm mongodbatlas_project.atlas_project
terraform state rm module.atlas_private_key_secret.google_secret_manager_secret.secret
terraform state rm module.atlas_public_key_secret.google_secret_manager_secret.secret
terraform state rm 'data.google_secret_manager_secret_version.atlas_private_key[0]'
terraform state rm 'data.google_secret_manager_secret_version.atlas_public_key[0]'

echo "State cleanup complete!"
