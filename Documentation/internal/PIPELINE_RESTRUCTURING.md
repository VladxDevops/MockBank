# Pipeline Restructuring: Foundation-First Deployment

**CLASSIFICATION: INTERNAL**

## 1. Overview
This document defines the reorganized CI/CD flow for the Altmtrk Bank platform. The sequence is optimized to ensure infrastructure availability before artifact production.

## 2. Sequence of Operations
1.  **Foundation (Project 0):** Declarative provisioning of GCP APIs, VPC networking, Serverless VPC Connectors, and Artifact Registry Repositories. This stage establishes the "Landing Zone."
2.  **App Infrastructure (Projects 1 & 2):** Provisioning of Cloud Run services (using placeholder images), Cloud SQL instances, and MongoDB Atlas clusters. This stage relies on the networking and registry established in Step 1.
3.  **Artifact Production (Build):** Custom Docker images for Keycloak and the Transaction Service are built via Cloud Build and pushed to the pre-existing Artifact Registry.
4.  **Deployment (Release):**
    *   **Keycloak:** The Cloud Run service is updated from the placeholder to the specific versioned image.
    *   **Transaction Service:** A Cloud Deploy release is created to manage the rollout across environments.

## 3. Benefits
*   **Reliability:** Eliminates build failures caused by missing destination repositories.
*   **Separation of Concerns:** Clearly distinguishes between "Infrastructure as Code" (Foundation) and "Configuration as Code" (Releases).
*   **Safety:** Allows for infrastructure validation (networking/IAM) before application code is introduced.

## 4. Dependencies
*   **Project 0** must succeed before **App Infrastructure**.
*   **App Infrastructure** must succeed before **Artifact Production**.
*   `build-images` must succeed before `deploy-services` starts.
