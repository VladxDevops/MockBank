# Common Infrastructure (Shared)

We will be working in one single GCP project. Please keep in mind that this is a brand new GCP project, thus GCP services may need to be enabled. Most infrastructure will need to be build/deployed. 

Terraform state will be backup at a GCS bucket.

**CLASSIFICATION: INTERNAL**

This document lists the foundational Google Cloud Platform (GCP) infrastructure components required by all three banking simulation projects. These resources form the "Landing Zone" for the applications.

## 1. Core Foundation
*   **GCP Project**: A dedicated project to host the banking environment.
*   **Terraform State Bucket**: A private GCS bucket to store the Terraform state files (`.tfstate`) securely with object versioning enabled.
*   **VPC Network**: A custom Virtual Private Cloud to isolate traffic.
    *   **Serverless VPC Access Connector**: To allow Cloud Run services to communicate with private data services (Cloud SQL/MongoDB).

## 2. Security & Identity (Zero Trust)
*   **Secret Manager**: The centralized vault for all secrets.
    *   *Usage:* Stores DB credentials, OIDC signing keys, and API tokens.
*   **Cloud IAM**:
    *   **Service Accounts**: Dedicated identities for each Cloud Run service (e.g., `sa-transaction-svc`, `sa-keycloak`).
    *   **Workload Identity Federation**: To allow GitHub Actions (Project 3) to deploy infrastructure without long-lived JSON keys.

## 3. Compute & Delivery
*   **Artifact Registry**: A central Docker repository to store container images for:
    *   Transaction Service (Project 2)
    *   Keycloak Custom Image (Project 1)
*   **Cloud Run**: The standard serverless compute platform for all stateless microservices.

## 4. Observability
*   **Cloud Logging**: Centralized log aggregation.
    *   *Requirement:* Must capture structured JSON logs from Node.js apps for the "Audit Agents".
*   **Cloud Monitoring**: Metrics collection for system health and alerting.
