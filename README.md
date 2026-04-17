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
3.  **Python:** v3.10+ (Mandatory for application layer).
4.  **pip-tools:** Required for dependency management (`pip install pip-tools`).

### Local Development
```bash
# 1. Clone the repo
git clone <repo_url>

# 2. Sync Python Environment (installs from requirements.txt)
pip-sync BNKprojects/1/requirements.txt

# 3. Run Service (Example)
python app.py
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
        compute_project_number = "your-gcp-project-number"
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

5.  **Import Existing Atlas Project (Optional):**
    *   If you want Terraform to use the project you created manually in the UI instead of creating a new one, you must import it into the Terraform state.
    *   Identify the resource name in your Terraform code (e.g., `mongodbatlas_project.atlas_project`) and get the Project ID from the Atlas UI.
    *   Run: `terraform import mongodbatlas_project.atlas_project <your-atlas-project-id>`
    *   **Note:** Ensure the project name in your Terraform configuration matches the existing project name to avoid renaming.

6.  **Deploy the Infrastructure:**
    *   Navigate to the `terraform` directory and run the following commands:
        ```bash
        terraform init
        terraform workspace select project2 || terraform workspace new project2
        terraform apply
        ```
    *   **Note on Atlas Deployment:** The `apply` command will create projects and clusters in your MongoDB Atlas organization. It will also automatically store the generated MongoDB connection string in Secret Manager. If you encounter an `IP_ADDRESS_NOT_ON_ACCESS_LIST` error, it means the IP of the machine running Terraform is not allowed to make API calls. Please see the detailed instructions in `terraform/mongodb_TROUBLESHOOTING.md` to resolve this.
    *   **Note on Cloud Run:** Terraform deploys a placeholder "Hello World" image initially. This ensures the infrastructure is healthy before you deploy your actual application code. You will see this running service in the console.
    *   **Network Note:** The configuration creates a VPC (`main-vpc`) and a subnet (`main-subnet`). The subnet's `/28` CIDR block is required for the Serverless VPC Access Connector. This connector allows Cloud Run to route traffic through your VPC. To provide a static IP for services on the public internet (like MongoDB Atlas), a **Cloud NAT** gateway must also be deployed in the VPC. This static IP can then be added to external service allow-lists.

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
PROJECT_ID=$(gcloud config get-value project) && gcloud run deploy transaction-service \
    --image "us-south1-docker.pkg.dev/${PROJECT_ID}/main-repository/transaction-service:v1" \
    --region us-south1 \
    --no-allow-unauthenticated \
    --set-secrets MONGO_URI=transaction-service-db-connection-string:latest \
    --vpc-connector avechector \
    --vpc-egress all
```

*Note: Ensure you configure the `MONGO_URI` environment variable (refer to Project Details) so the service can connect to the database.*

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
