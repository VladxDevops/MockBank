+++
title = "Common Infrastructure & Shared GCP Resources"
domain = "infrastructure"
topics = ["gcp", "terraform-state", "networking", "vpc", "artifact-registry", "cloud-nat", "redis", "memorystore", "pubsub", "kafka", "mulesoft", "opentelemetry"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["Architecture.md", "TERRAFORM_VS_CLOUD_DEPLOY.md", "../../terraform/README.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **System Architecture**: [`Architecture.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/Architecture.md)  
> **Terraform IaC**: [`terraform/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/terraform/README.md)

<!-- AI RETRIEVAL HINTS
- Purpose: Details shared GCP infrastructure including centralized GCS Terraform state buckets, VPC layout, NAT, and Artifact Registry.
- Questions Answered:
  1. How is Terraform state structured and initialized across GCP projects?
  2. What is the GCS state bucket path naming convention?
  3. How are shared networking and Artifact Registry resources managed?
- When to Retrieve: Querying GCP shared infrastructure, Terraform state management, or network topologies.
- When NOT to Retrieve: Querying specific microservice application code or local container setup.
- Prerequisites: [Architecture.md]
- Follow-up Reading: [../../terraform/README.md]
-->

---

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

## 4. Observability(Current:)
*   **Cloud Logging**: Centralized log aggregation.
    *   *Requirement:* Must capture structured JSON logs from Node.js apps for the "Audit Agents".
*   **Cloud Monitoring**: Metrics collection for system health and alerting.

## 4.01 Event Streaming & Messaging *(Status: Planning / Not Started / Pending)*
*   **Google Cloud Pub/Sub**: Serverless event ingestion and fan-out. Serves as the primary GCP-native messaging backbone for real-time banking pipelines (transaction notifications, fraud alerts).
    *   *Terraform:* Provisioned via Project 0 foundation module.
*   **Apache Kafka (Project 5)**: Durable, high-throughput event streaming log for cross-service event sourcing, audit replay, and compliance-grade data retention.
    *   *Terraform:* Infrastructure managed separately under Project 5.
    *   *Reference:* [`BNKprojects/5/PUBSUB.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/5/PUBSUB.md)

## 5. Caching & Session Store *(Status: Planning / Not Started / Pending)*
*   **GCP Memorystore for Redis**: Managed in-memory cache deployed inside the private VPC with no public IP.
    *   *Use Cases:* Session state management, rate-limiting counters, hot-path query acceleration (Cache-Aside pattern).
    *   *Terraform:* Provisioned via Project 0 foundation module (`terraform/modules/project0/`).
    *   *Client Configuration:* See [`Documentation/redis_integration.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/redis_integration.md) for environment variables and connection pooling standards.

## 6. Integration Platform *(Status: Planning / Not Started / Pending)*
*   **MuleSoft Anypoint Platform (Project 7)**: Enterprise integration layer for API-led connectivity between internal microservices and external banking partners.
    *   *Boundary:* MuleSoft operates as a separate integration domain. GCP-side prerequisites (network, IAM, DNS, secrets) remain under Project 0/Terraform.
    *   *Reference:* [`Documentation/internal/mulesoft/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/mulesoft/README.md)

## 7. Observability *(Status: Planning / Not Started / Pending)*
*   **OpenTelemetry (OTel)**: Vendor-neutral observability framework for instrumenting distributed traces, metrics, and logs across all microservices.
    *   *GCP Mapping:* OTel Collector → Cloud Trace (traces), Cloud Monitoring (metrics), Cloud Logging (logs).
    *   *Reference:* [`Documentation/INFRASTRUCTURE/MONITORING/OPEN_TELEMETRY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/INFRASTRUCTURE/MONITORING/OPEN_TELEMETRY.md)
*   **Cloud Logging**: Centralized log aggregation.
    *   *Requirement:* Must capture structured JSON logs from Node.js apps for the "Audit Agents".
*   **Cloud Monitoring**: Metrics collection for system health and alerting.
