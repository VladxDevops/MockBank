# Altmtrk2026 Bank Platform

## Overview
This repository hosts the source code for the Altmtrk2026 Banking Platform. It is designed as a secure, cloud-native system leveraging GCP, Keycloak (Identity), and MongoDB (Audit).

## ⚠️ Security Warning
**Security is the highest priority.** Before contributing, you must read the [Security Policy](./security.md).
*   No hardcoded secrets.
*   No PII in logs.
*   MFA required for all admin actions.

## Documentation Map
*   **[Architecture](./Architecture.md):** System topology and component design.
*   **[Agents & Bots](./AGENTS.md):** Rules for CI/CD and AI usage.
*   **[Changelog](./CHANGELOG.md):** History of architectural decisions.

## Getting Started

### Prerequisites
1.  **Google Cloud SDK:** Authenticated with `gcloud auth login`.
2.  **Terraform:** v1.5+.
3.  **Node.js:** v18+ (LTS).

### Local Development
```bash
# 1. Clone the repo
git clone <repo_url>

# 2. Install dependencies
npm install

# 3. Run local mock environment
npm run dev:mock
```

## Project 2: Transaction Service Deployment

Project 2 is a Node.js microservice that handles money transfers and records audit trails in MongoDB. It is deployed as a Cloud Run service in GCP.

### MongoDB Atlas Setup

Since this project uses MongoDB Atlas, you will need to create a free account and a new cluster.

1.  **Create a MongoDB Atlas Account:**
    *   Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register) and create a new account.

2.  **Create a New Organization and Project:**
    *   After creating an account, you will be prompted to create an organization and a project. Give them a name (e.g., "BankProject").

3.  **Create a Free Tier Cluster:**
    *   Create a new cluster. Select "Shared" for the cluster type, and choose the "M0" free tier.
    *   Select "GCP" as the cloud provider and choose a region (e.g., `us-central1`).

4.  **Get Your Organization ID:**
    *   In the Atlas UI, go to your organization settings and copy the "Organization ID".

5.  **Create an API Key:**
    *   Go to "Access Management" -> "Organization Access" -> "API Keys".
    *   Click "Create API Key".
    *   Give it a name and select "Organization Owner" for the permissions.
    *   **Important:** Copy the "Public Key" and "Private Key". You will not be able to see the private key again.

6.  **Configure IP Access:**
    *   Go to "Network Access" and add an IP address. For development purposes, you can allow access from anywhere by entering `0.0.0.0/0`. **For production, you should restrict this to the IP addresses of your services.**

### Terraform Deployment

This project uses Terraform to manage the GCP infrastructure. The configuration is located in the `terraform` directory.

#### Initial Setup

1.  **Configure Remote State (Optional but Recommended):**
    *   The `terraform/backend.tf` file is provided to configure a GCS bucket as the remote backend for your Terraform state.
    *   To use it, you need to create a GCS bucket and then uncomment the content of the file, replacing `"your-terraform-state-bucket-name"` with the name of your bucket.
    *   Run `terraform init` to initialize the backend.

2.  **Update `terraform/dev.tfvars`:**
    *   Open the `terraform/dev.tfvars` file and fill in the following values:
        ```hcl
        compute_project_id = "your-gcp-project-id"
        atlas_org_id       = "your-atlas-organization-id"
        ```

3.  **Enable GCP Services:**
    *   Run the following command to enable the necessary GCP APIs (requires `bootstrap=true` to skip secret validation):
        ```bash
        terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=google_project_service.gcp_services
        ```

4.  **Store your Atlas API Keys in Secret Manager:**
    *   Run the following command to create empty secrets for your Atlas API keys (using bootstrap mode):
        ```bash
        terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.atlas_public_key_secret -target=module.atlas_private_key_secret
        ```
    *   Go to the GCP Console -> Secret Manager and add the values for `atlas_public_key` and `atlas_private_key` manually.

5.  **Update `terraform/project2.tf`:**
    *   Open `terraform/project2.tf` and replace the `docker_image` placeholder with the correct URL of your Docker image in the `main-repository` Artifact Registry repository.

6.  **Deploy the Infrastructure:**
    *   Navigate to the `terraform` directory and run the following commands:
        ```bash
        terraform init
        terraform workspace select project2 || terraform workspace new project2
        terraform apply
        ```

### Infrastructure Preservation

To prevent accidental data loss, some resources are configured with `prevent_destroy = true`. This means that you will not be able to destroy these resources with `terraform destroy` unless you remove the `lifecycle` block from the Terraform code.

The following resources are protected:

*   **Enabled GCP Services:** The enabled GCP APIs will not be disabled.
*   **Artifact Registry Repository:** The Docker repository will not be deleted.
*   **Secrets in Secret Manager:** The empty secrets for the Atlas API keys will not be deleted.

It is also highly recommended to protect your Terraform state GCS bucket from deletion by using bucket policies and IAM permissions.
