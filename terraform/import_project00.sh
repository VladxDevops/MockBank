#!/bin/bash
# Script to import existing Project 0 / Foundation resources into the current Terraform state.
# This prevents "already exists" errors during apply.

set -e

PROJECT_ID="dev-mockbank"
REGION="us-south1"

echo "Importing resources for project: $PROJECT_ID in region: $REGION"

  module.project0.google_compute_global_forwarding_rule.forwarding_rule \
  projects/${PROJECT_ID}/global/forwardingRules/bank-frontend-rule

# 16. Project 1 Secrets
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project1.google_secret_manager_secret.keycloak_db_password \
  projects/${PROJECT_ID}/secrets/keycloak-database-password

terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project1.google_secret_manager_secret.keycloak_admin_password \
  projects/${PROJECT_ID}/secrets/keycloak-administrator-password

terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project1.google_secret_manager_secret.retail_app_session_secret \
  projects/${PROJECT_ID}/secrets/retail-app-session-secret

# 17. Project 1 Service Account
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project1.google_service_account.keycloak_sa \
  projects/${PROJECT_ID}/serviceAccounts/keycloak-service-account@${PROJECT_ID}.iam.gserviceaccount.com

# 18. Project 3 Workload Identity Pool
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project3.google_iam_workload_identity_pool.github_pool \
  projects/${PROJECT_ID}/locations/global/workloadIdentityPools/github-pool

# 19. Project 3 Service Account
terraform import -var-file="dev.tfvars" -var="bootstrap=true" \
  module.project3.google_service_account.github_actions_sa \
  projects/${PROJECT_ID}/serviceAccounts/sa-github-actions@${PROJECT_ID}.iam.gserviceaccount.com

echo "Import complete!"
