#!/bin/bash

# Project 0: Foundation First-Run Setup Script
# This script assigns the necessary IAM roles to the Service Account responsible 
# for provisioning Project 0 (Foundation) infrastructure.

set -e

# 1. Variables - Ensure these are set or provided as arguments
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_EMAIL=$1

if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    read -p "Enter the Service Account Email for Project 0: " SERVICE_ACCOUNT_EMAIL
fi

if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    echo "Error: Service Account Email is required to proceed."
    exit 1
fi

echo "------------------------------------------------------------"
echo "Target Project: $PROJECT_ID"
echo "Service Account: $SERVICE_ACCOUNT_EMAIL"
echo "------------------------------------------------------------"

# 2. List of Roles to Assign
# These roles mirror the permissions required to manage APIs, Networking, Registry, and IAM.
ROLES=(
    "roles/serviceusage.serviceUsageAdmin"    # Enable/Disable APIs
    "roles/compute.networkAdmin"            # Manage VPC, Subnets, Cloud NAT
    "roles/artifactregistry.admin"          # Manage Shared Artifact Registries
    "roles/storage.admin"                   # Manage GCS Buckets (Terraform State)
    "roles/resourcemanager.projectIamAdmin" # Assign IAM roles to other identities
    "roles/iam.serviceAccountAdmin"         # Create/Manage Service Accounts for Apps
    "roles/iam.serviceAccountCreator"       # Allow SA to create other service accounts
    "roles/iam.workloadIdentityPoolAdmin"   # Manage WIF Pools and Providers
    "roles/clouddeploy.admin"               # Manage Cloud Deploy pipelines
    "roles/secretmanager.admin"             # Initialize shared secrets
    "roles/cloudbuild.builds.editor"        # Required for image builds
    "roles/iam.serviceAccountUser"          # Allow SA to act as other identities
)

echo "Assigning IAM roles..."

for ROLE in "${ROLES[@]}"; do
    echo "Adding $ROLE..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$ROLE" \
        --quiet > /dev/null
done

echo "------------------------------------------------------------"
echo "Cross-Project Terraform State Access"
read -p "Enter the GCP Project ID where the remote state is stored (Leave blank to skip): " TERRAFORM_GCP_PROJECT

if [ ! -z "$TERRAFORM_GCP_PROJECT" ]; then
    echo "Assigning storage.objectAdmin to $SERVICE_ACCOUNT_EMAIL in $TERRAFORM_GCP_PROJECT..."
    gcloud projects add-iam-policy-binding "$TERRAFORM_GCP_PROJECT" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/storage.objectAdmin" \
        --quiet > /dev/null
fi

echo "------------------------------------------------------------"
echo "SUCCESS: Roles assigned successfully."
echo "Note: It may take a few minutes for IAM changes to propagate."
echo "------------------------------------------------------------"
