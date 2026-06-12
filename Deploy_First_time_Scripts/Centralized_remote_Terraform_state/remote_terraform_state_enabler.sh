#!/bin/bash

# Script to grant Project IAM Admin roles to the Deployer Service Account 
# in the Terraform Remote State Project.

# 1. Source the .env file from the same directory
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found in the current directory."
    exit 1
fi

# 2. Validate required variables
if [ -z "$remote_terraform_state_gcp_project_id" ] || [ -z "$dev_terraform_deployer_service_account" ]; then
    echo "Error: remote_terraform_state_gcp_project_id or dev_terraform_deployer_service_account is not set in .env."
    exit 1
fi

# 3. Variables Assignment with .env priority
CENTRALIZED_TARGET_PROJECT=$remote_terraform_state_gcp_project_id
DEV_TERRAFORM_DEPLOYER_SA_EMAIL=$dev_terraform_deployer_service_account
TARGET_ROLE="roles/resourcemanager.projectIamAdmin"

echo "Assigning '${TARGET_ROLE}' to ${DEV_TERRAFORM_DEPLOYER_SA_EMAIL} in project ${CENTRALIZED_TARGET_PROJECT}..."

gcloud projects add-iam-policy-binding "$CENTRALIZED_TARGET_PROJECT" \
    --member="serviceAccount:${DEV_TERRAFORM_DEPLOYER_SA_EMAIL}" \
    --role="$TARGET_ROLE"
