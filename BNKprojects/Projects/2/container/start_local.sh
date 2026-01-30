#!/bin/bash

# 1. Define the Secret Names (as stored in GCP Secret Manager)
SECRET_USER="mongo-root-username"
SECRET_PASS="mongo-root-password" 

echo "🔌 Fetching secrets from GCP Secret Manager..."

# 2. Fetch secrets using gcloud and export them as Environment Variables
# We use '||' to provide a fallback for local dev if GCP is unreachable (optional)
export MONGO_ROOT_USERNAME=$(gcloud secrets versions access latest --secret="$SECRET_USER" 2>/dev/null || echo "local_bank_admin")
export MONGO_ROOT_PASSWORD=$(gcloud secrets versions access latest --secret="$SECRET_PASS" 2>/dev/null || echo "local_dev_password_only")

echo "✅ Secrets loaded. Starting Docker Compose..."

# 3. Start Docker Compose
# The variables exported above are now available to the .yml file
docker-compose up -d

echo "🚀 MongoDB is running on port 27017"
