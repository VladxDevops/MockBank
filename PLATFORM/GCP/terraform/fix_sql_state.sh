#!/bin/bash
# fix_sql_state.sh - State cleanup for Keycloak SQL instance in Project 1
# This script removes deleted/ghost resources from the state and forces a new name suffix.

# Ensure we are in the terraform directory
if [ -d "terraform" ]; then
    cd terraform
fi

# Select the correct workspace used in GitHub Actions
echo "Selecting workspace projectZERO..."
terraform workspace select projectZERO

# Remove ghost SQL resources from state
echo "Removing ghost resources from state..."
terraform state rm module.project1.google_sql_database.keycloak_schema
terraform state rm module.project1.google_sql_user.keycloak_user
terraform state rm module.project1.google_sql_database_instance.keycloak_db

# Force a new instance name by tainting the random suffix
echo "Tainting random_id.database_name_suffix..."
terraform taint module.project1.random_id.database_name_suffix

echo "--------------------------------------------------------"
echo "SQL state fixed and random suffix tainted."
echo "Run 'terraform apply' to recreate the instance with a new name."
echo "--------------------------------------------------------"
