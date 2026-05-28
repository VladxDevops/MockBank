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
*   **Projects:**
    *   Project 0: Foundation Infrastructure (Networking & APIs)
    *   Project 1: Identity Service
    *   Project 2: Transaction Service
    *   Project 3: CI/CD & Release Safety

## Getting Started

### Prerequisites
1.  **Google Cloud SDK:** Authenticated with `gcloud auth login`.
2.  **Terraform:** v1.5+.
3.  **Python:** v3.10+ (Mandatory for application layer).
4.  **pip-tools:** Required for dependency management (`pip install pip-tools`).

### Local Development
```bash
# 1. Clone the repo
git clone <repo_url>

# 2. Setup Project 1 (Identity Client)
cd BNKprojects/1

# 3. Sync dependencies from the lockfile
pip-sync requirements.txt

# 4. Configure local environment variables
# Copy the template and update with your local Keycloak/Secret settings
cp .env.example .env

# 5. Start the application
python src/app.py
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

### Terraform Deployment (Foundation First)

The infrastructure is managed using a decoupled, multi-stack approach. **Project 0 (Foundation) must be deployed before any other services.**

#### 1. Initial Setup
*   **Configure Remote State (Optional):** See `terraform/terraform.tf` to configure a GCS backend.
*   **Update `terraform/dev.tfvars`:**
    ```hcl
    compute_project_id     = "your-gcp-project-id"
    compute_project_number = "your-gcp-project-number"
    atlas_org_id           = "your-atlas-organization-id"
    ```

#### 2. Deploy Project 0 (Foundation)
This module enables 16+ GCP APIs, configures the Global VPC, NAT, and Artifact Registry.
```bash
cd terraform
terraform init
terraform workspace select projectZERO || terraform workspace new projectZERO

# Bootstrap APIs and Core Infrastructure
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.project0
```

#### 3. Shared Secrets Management
Provision placeholders for shared secrets (e.g., MongoDB Atlas keys):
```bash
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.atlas_public_key_secret -target=module.atlas_private_key_secret
```
*Note: Manually populate these values in the GCP Console after creation.*

#### 4. Deploy Application Projects
Once the foundation is live, you can deploy Project 1 (Identity), Project 2 (Transactions), or Project 3 (CI/CD) by targeting their respective modules or using the unified workspace.

### Infrastructure Preservation

To prevent accidental data loss, some resources are configured with `prevent_destroy = true`. This means that you will not be able to destroy these resources with `terraform destroy` unless you remove the `lifecycle` block from the Terraform code.

The following resources are protected:

*   **Enabled GCP Services:** The enabled GCP APIs will not be disabled.
*   **Artifact Registry Repository:** The Docker repository will not be deleted.
*   **Secrets in Secret Manager:** The empty secrets for the Atlas API keys will not be deleted.

It is also highly recommended to protect your Terraform state GCS bucket from deletion by using bucket policies and IAM permissions.

### Container Deployment

After the infrastructure is provisioned via Terraform, you need to build and push the Docker image to the Artifact Registry. We use **Cloud Build** instead of `docker push` to avoid local network/proxy issues.

**Prerequisites:**
Ensure your user account has the following IAM roles:
*   **Cloud Build Editor** (`roles/cloudbuild.builds.editor`)
*   **Service Account User** (`roles/iam.serviceAccountUser`)

You can grant these roles using the following commands (replace `<YOUR_PROJECT_ID>` and `<YOUR_EMAIL>`):

```bash
gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
    --member="user:<YOUR_EMAIL>" \
    --role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
    --member="user:<YOUR_EMAIL>" \
    --role="roles/iam.serviceAccountUser"
```

1.  **Navigate to the project directory:**
    ```bash
    cd BNKprojects/2
    ```

2.  **Submit the build to Cloud Build:**
    From the `BNKprojects/2` directory, run the following command to submit the build using its configuration file:
    ```bash
    gcloud builds submit --config container/cloudbuild.yaml .
    ```
    This uses the build configuration located at `container/cloudbuild.yaml` and automatically substitutes the project ID.

### Deploy to Cloud Run

Once the build is successful, deploy the service to Cloud Run. The following command will automatically fetch your current GCP Project ID.

```bash
    PROJECT_ID=$(gcloud config get-value project) && REPO_ID="<ARTIFACT_REGISTRY_REPOSITORY_ID>" && gcloud run deploy transaction-service \
        --image "us-south1-docker.pkg.dev/${PROJECT_ID}/${REPO_ID}/transaction-service:v1" \
    --region us-south1 \
    --no-allow-unauthenticated \
    --set-secrets MONGO_URI=transaction-service-db-connection-string:latest \
    --vpc-connector avechector \
    --vpc-egress all
```

*Note: Ensure you configure the `MONGO_URI` environment variable (refer to Project Details) so the service can connect to the database.*

## Project 3: CI/CD & Release Safety Workflow

This project implements a secure, automated pipeline for the Transaction Service using GitHub Actions and Google Cloud Deploy.

### 1. Setup & Configuration (Prerequisites)
Before the pipeline can run, you must configure the following in your GitHub Repository Settings:

**GitHub Secrets (`Settings > Secrets > Actions` or via `gh` CLI):**

To find the correct values for your secrets via Google Cloud Shell:
```bash
# For WIF_PROVIDER:
gcloud iam workload-identity-pools list --location=global
OR: 
gcloud iam workload-identity-pools providers list --location="global" --workload-identity-pool="YOUR_POOL_NAME" --format="value(name)"

# For WIF_SERVICE_ACCOUNT:
gcloud iam service-accounts list --filter="name:github-actions" --format="value(email)"
```

To set secrets via terminal (Safety First):
```bash
# 1. Verify current repository context
gh repo view --json nameWithOwner

#It should print: username/repo_name


# 2. Set environment-specific secrets (e.g., for DEV)
gh secret set WIF_PROVIDER --env DEV --body "your-DEV-provider-string"
gh secret set WIF_SERVICE_ACCOUNT --env DEV --body "your-sa-email"
gh secret set KEYCLOAK_ADMIN_PASSWORD --env DEV --body "your-password"
gh secret set GCP_PROJECT_ID --env DEV --body "your-actual-dev-project-id"

```

*   `WIF_PROVIDER`: The full resource name of the Workload Identity Provider (e.g., `projects/NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider`).
*   `WIF_SERVICE_ACCOUNT`: The email of the Service Account created for CI/CD (e.g., `github-actions-sa@PROJECT_ID.iam.gserviceaccount.com`).
*   `KEYCLOAK_ADMIN_PASSWORD`: Admin password for Terraform provider auth.

**GitHub Variables (`Settings > Variables > Actions` or via `gh` CLI):**

```bash
gh variable set GCP_PROJECT_ID --body "your-project-id"
gh variable set GCP_COMPUTE_REGION --body "replace with region (e.g., us-central1)"
```

*   `GCP_PROJECT_ID`: Your Google Cloud Project ID.
*   `GCP_COMPUTE_REGION`: The region for deployment (e.g., `us-central1`).

### 2. The Deployment Manifests
*   **`skaffold.yaml`**: This file bridges the gap between your source code and the cloud. It tells Cloud Deploy how to build your image (using the Dockerfile in `BNKprojects/2/container/`) and which Kubernetes-style manifests to render.
*   **`service.yaml`**: A Knative Service definition for Cloud Run. It configures:
    *   **VPC Egress**: Routes traffic through `avechector` for private MongoDB access.
    *   **Secrets**: Maps the MongoDB connection string from Secret Manager to the `MONGO_URI` environment variable.

### 3. Pipeline Execution Flow
1.  **Code Push**: Push code to the `DEV` or `main` branch.
2.  **SAST Gate**: The `sast-scan` job runs **Semgrep**. It scans for hardcoded secrets, Node.js security vulnerabilities, and general audit failures. If vulnerabilities are found, the pipeline fails.
3.  **Authentication**: The workflow uses **Workload Identity Federation (WIF)** to exchange a GitHub OIDC token for a short-lived GCP access token—no static keys required.
4.  **Release Creation**: The `gcloud deploy releases create` command bundles the source code from `BNKprojects/2`, sends it to Cloud Deploy, and triggers the `transaction-service-pipeline`.

### 4. Promotion & Approval
*   **DEV**: Deployment to the `dev-target` happens automatically after a successful push to the `DEV` branch.
*   **TEST/PROD**: These targets are configured with `require_approval: true`.
    *   To promote: Navigate to the **Google Cloud Deploy** console.
    *   Select the `transaction-service-pipeline`.
    *   Click **Promote** on the current release to move it from `DEV` to `TEST`.
    *   A user with the appropriate IAM permissions must manually approve the rollout in the UI.

### 5. Local Testing with Skaffold
To verify the manifests locally before pushing:
```bash
cd BNKprojects/2
skaffold render --image transaction-service-image:local
```
This will output the rendered YAML that Cloud Deploy will use, allowing you to verify environment variables and annotations.

### Service Logic & Diagnostics

The deployed service implements the following orchestration logic:

2.  **Step 2: Transaction Request**
    *   User requests to transfer amount `$X`.
    *   **Logic:**
        *   IF `$X < $10,000`: Allow immediately.
        *   IF `$X >= $10,000`: Trigger **Step-Up Auth**.

3.  **Step 3: Step-Up Authentication (MFA)**
    *   System challenges user (simulated).
    *   **Action:** Log `mfa_challenge_issued`.
    *   **Outcome:**
        *   *Success:* Proceed to transfer.
        *   *Fail:* Log `mfa_failed` with error code.

#### Diagnostic Query
To investigate MFA failures (e.g., timeouts), run the following MongoDB query:

```javascript
db.journeys.find({
    "steps.step": "mfa_verification",
    "steps.status": "failed",
    "steps.error_code": "TIMEOUT"
}).sort({ timestamp: -1 })
```
