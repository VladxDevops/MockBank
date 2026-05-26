#!/bin/bash

# Project 0: Foundation First-Run Setup Script
# This script assigns the necessary IAM roles to the Service Account responsible 
# for provisioning Project 0 (Foundation) infrastructure.

set -e

# 1. Variables - Ensure these are set or provided as arguments. Step1: 
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_EMAIL=$1

if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    read -p "Enter the Terraform Service Account Email for Project 0: " SERVICE_ACCOUNT_EMAIL
fi

if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    echo "Error: Service Account Email is required to proceed."
    exit 1
fi

echo "------------------------------------------------------------"
echo "Target Project: $PROJECT_ID"
echo "Service Account: $SERVICE_ACCOUNT_EMAIL"
echo "------------------------------------------------------------"

read -p "Skip Step 1 (IAM role assignment in $PROJECT_ID)? (y/n): " SKIP_STEP1

if [[ ! "$SKIP_STEP1" =~ ^[Yy]$ ]]; then
    # 2. List of Roles to Assign
    # These roles mirror the permissions required to manage APIs, Networking, Registry, and IAM.
    ROLES=(
        "roles/artifactregistry.admin"
        "roles/artifactregistry.writer"
        "roles/cloudbuild.builds.editor"
        "roles/clouddeploy.admin"
        "roles/cloudsql.admin"
        "roles/compute.networkAdmin"
        "roles/iam.infrastructureAdmin"
        "roles/iam.securityAdmin"
        "roles/iam.serviceAccountCreator"
        "roles/iam.serviceAccountUser"
        "roles/iam.workloadIdentityPoolAdmin"
        "roles/resourcemanager.projectIamAdmin"
        "roles/run.admin"
        "roles/secretmanager.admin"
        "roles/secretmanager.secretAccessor"
        "roles/serviceusage.serviceUsageAdmin"
        "roles/serviceusage.serviceUsageConsumer"
        "roles/storage.admin"
        "roles/vpcaccess.admin"
    )

    echo "Assigning IAM roles..."

    for ROLE in "${ROLES[@]}"; do
        echo "Adding $ROLE..."
        gcloud projects add-iam-policy-binding "$PROJECT_ID" \
            --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
            --role="$ROLE" \
            --quiet > /dev/null
    done
fi

#Step2: 
echo "------------------------------------------------------------"
echo "Step 2: Cross-Project Terraform State Access"
read -p "Enter the GCP Project ID where the remote state is stored (Leave blank to skip): " TERRAFORM_GCP_PROJECT

if [ ! -z "$TERRAFORM_GCP_PROJECT" ]; then
    echo "Assigning storage.admin to $SERVICE_ACCOUNT_EMAIL in $TERRAFORM_GCP_PROJECT..."
    gcloud projects add-iam-policy-binding "$TERRAFORM_GCP_PROJECT" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/storage.admin" \
        --quiet > /dev/null
fi

echo "------------------------------------------------------------"
echo "SUCCESS: Roles assigned successfully."
echo "Note: It may take a few minutes for IAM changes to propagate."
echo "------------------------------------------------------------"
