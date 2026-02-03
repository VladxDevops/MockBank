# This file configures the remote backend for Terraform.
#
# To use this backend, you need to:
# 1. Create a GCS bucket to store the state.
# 2. **Important:** Make sure to enable object versioning on the bucket to prevent accidental data loss.
# 3. **Important:** Do not delete this bucket manually or through any other means.
# 4. Run `terraform init` to initialize the backend.

terraform {
  backend "gcs" {
    bucket = "terraform_state_bckup_bnk-project"
    prefix = "terraform/state"
  }
}
