# Common Infrastructure (Shared)

We will be working in one single GCP project. Please keep in mind that this is a brand new GCP project, thus GCP services may need to be enabled. Most infrastructure will need to be build/deployed. 

## Terraform State Management
All Terraform state files are centrally managed in GCS buckets located within **Project 0**. This ensures that the state survives environment-specific lifecycle events and remains protected by centralized IAM policies. Each environment (DEV, TEST, PROD) will have its own prefix/folder within the foundation bucket.

### State Prefix Convention
To maintain clarity and prevent state collision, the following path structure is mandated:
`gs://[STATE_BUCKET_NAME]/[ENVIRONMENT]/[PROJECT_NAME]/default.tfstate`

### Cross-Project Initialization
When the target infrastructure project differs from the state project, use the following initialization pattern:

**Identity Requirement:** The credentials used for initialization (e.g., the DEV Service Account) must be granted the `roles/storage.objectAdmin` role on the specific GCS bucket within the remote state project.

**Local Authentication (Using DEV Project Credentials):**
```bash
terraform init \
  -backend-config="bucket=[REMOTE_STATE_BUCKET]" \
  -backend-config="credentials=[PATH_TO_DEV_PROJECT_SA_KEY]" \
  -backend-config="reconfigure"
```

**CI/CD (GitHub Actions):**
Authentication is handled via Workload Identity Federation (WIF). Terraform automatically uses the assumed identity (the DEV Service Account) to access the backend bucket.

```bash
terraform init \
  -backend-config="bucket=[REMOTE_STATE_BUCKET]" \
  -backend-config="reconfigure"
```

### Workspace Usage
Developers must use Terraform Workspaces to manage environment-specific states. 
*   **Project 0:** The primary terraform workspace is named `projectZERO`. Environment-specific variations should follow the `projectZERO-[env]` pattern.
*   **Project 2:** Workspaces should be named by project and environment (e.g., `project2-dev`) if shared prefixes are used.
Always verify your active workspace using `terraform workspace show` before running an `apply`.

*Example:*
`gs://altmtrk-foundation-tfstate/dev/project2/default.tfstate`

### Importing Existing Foundation Resources (Fixing "Already Exists" Errors)
If landing zone/foundation resources were deployed via a separate configuration or direct execution (e.g., Project 0B resources or pre-existing network configs), running a target plan or apply on `module.project0` may result in `"already exists"` conflicts.

To reconcile the active Terraform state in the `projectZERO` workspace with GCP, run the following import commands from the `terraform/` directory:

**CLASSIFICATION: INTERNAL**

This document lists the foundational Google Cloud Platform (GCP) infrastructure components required by all three banking simulation projects. These resources form the "Landing Zone" for the applications.

## 1. Core Foundation
*   **GCP Project**: A dedicated project to host the banking environment.
*   **Terraform State Bucket**: A private GCS bucket to store the Terraform state files (`.tfstate`) securely with object versioning enabled.
*   **VPC Network**: A custom Virtual Private Cloud to isolate traffic.
    *   **Serverless VPC Access Connector**: To allow Cloud Run services to communicate with private data services (Cloud SQL/MongoDB).
    *   **Private Service Access**: VPC Peering allocated range for Google Managed Services (Cloud SQL).
    *   **Cloud NAT**: Configured with `MANUAL_ONLY` IP allocation using **Standard Network Tier** for cost optimization on outbound traffic.

## 2. Security & Identity (Zero Trust)
*   **Secret Manager**: The centralized vault for all secrets.
    *   *Usage:* All application-layer secret placeholders are provisioned via Project 0. This includes Keycloak passwords, MongoDB URI, and Atlas API keys.
*   **Cloud IAM**:
    *   **Service Accounts**: Dedicated identities for each Cloud Run service (e.g., `sa-transaction-svc`, `sa-keycloak`).
    *   **Workload Identity Federation**: To allow GitHub Actions (Project 3) to deploy infrastructure without long-lived JSON keys.

## 3. Compute & Delivery (Zero Trust & Cost Optimized)
    *   *Note:* Provisioning of the regional Load balancer and its Static IP (`bank-platform-lb-ip`) on the **Standard Network Tier** is **DISABLED** for the `DEV` environment. Services must be accessed via authenticated developer proxies (`gcloud run services proxy`) to comply with the "No Unauthenticated Access" policy without the cost of a Load Balancer.

*   **Artifact Registry**: A central Docker repository to store container images for:
    *   Transaction Service (Project 2)
    *   Keycloak Custom Image (Project 1)
*   **Cloud Run**: The standard serverless compute platform for all stateless microservices.

## 3.1 DevOps Tools Infrastructure
*   **Google Cloud Deploy**: Managed CD service for Cloud Run; handles promotion targets and rollback automation.
*   **Cloud Build**: Primary CI engine for image creation and security scanning (SAST).
*   **Google Kubernetes Engine (GKE) Autopilot**: Cost-optimized Kubernetes cluster to host ArgoCD for future Kubernetes-native GitOps.

## 4. Observability
*   **Cloud Logging**: Centralized log aggregation.
    *   *Requirement:* Must capture structured JSON logs from Node.js apps for the "Audit Agents".
*   **Cloud Monitoring**: Metrics collection for system health and alerting.

## 4. Observability
*   **Cloud Logging**: Centralized log aggregation.
    *   *Requirement:* Must capture structured JSON logs from Node.js apps for the "Audit Agents".
*   **Cloud Monitoring**: Metrics collection for system health and alerting.
