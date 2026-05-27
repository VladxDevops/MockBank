#!/bin/bash

# Project 0: Foundation First-Run Setup Script
# This script assigns the necessary IAM roles to the Service Account responsible 
# for provisioning Project 0 (Foundation) infrastructure.

set -e

# 1. Variables - Ensure these are set or provided as arguments. Step1: 
PROJECT_ID=$(gcloud config get-value project --quiet 2>/dev/null | tr -d '[:space:]')
SERVICE_ACCOUNT_EMAIL=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No active GCP project found in gcloud config."
    echo "Please run 'gcloud config set project [PROJECT_ID]' first."
    exit 1
fi

if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    read -p "Enter the Terraform Service Account Email for Project 0: " SERVICE_ACCOUNT_EMAIL
fi

if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    echo "Error: Service Account Email is required to proceed."
    exit 1
fi

# Sanitize: Trim whitespace and remove 'serviceAccount:' prefix if user provided it
SERVICE_ACCOUNT_EMAIL=$(echo "$SERVICE_ACCOUNT_EMAIL" | tr -d '[:space:]')
# Ensure we strip the prefix if it exists so we can add it safely in the gcloud flags
SERVICE_ACCOUNT_EMAIL=${SERVICE_ACCOUNT_EMAIL#serviceAccount:}

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
        if ! gcloud projects add-iam-policy-binding "$PROJECT_ID" \
            --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
            --role="$ROLE" \
            --quiet; then
            echo "[DEBUG] Failed to add role. Arguments used:"
            echo "  Project ID: '$PROJECT_ID'"
            echo "  Member String: 'serviceAccount:$SERVICE_ACCOUNT_EMAIL'"
            exit 1
        fi
    done
fi

# Step 2: Cross-Project Terraform State Access
echo "------------------------------------------------------------"
echo "Step 2: Terraform State Access (GCS)"
echo "Terraform states are often stored in a central project's GCS bucket."
echo "Current project is: $PROJECT_ID"
read -p "Enter the Project ID where the remote state is stored [Default: $PROJECT_ID, type 'skip' to skip]: " TERRAFORM_GCP_PROJECT

# Handle default and skip
TERRAFORM_GCP_PROJECT=$(echo "${TERRAFORM_GCP_PROJECT:-$PROJECT_ID}" | tr -d '[:space:]')

if [[ "$TERRAFORM_GCP_PROJECT" != "skip" ]]; then
    echo "Assigning storage.admin to $SERVICE_ACCOUNT_EMAIL in $TERRAFORM_GCP_PROJECT..."
    if ! gcloud projects add-iam-policy-binding "$TERRAFORM_GCP_PROJECT" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/storage.admin" \
        --quiet; then
        echo "[DEBUG] Failed to add cross-project role. Arguments used:"
        echo "  Target Project ID: '$TERRAFORM_GCP_PROJECT'"
        echo "  Member String: 'serviceAccount:$SERVICE_ACCOUNT_EMAIL'"
        exit 1
    fi
fi

echo "------------------------------------------------------------"
echo "SUCCESS: Roles assigned successfully."
echo "Note: It may take a few minutes for IAM changes to propagate."
echo "------------------------------------------------------------"
