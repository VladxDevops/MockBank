# Architecture.md - System Design & Topology

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Executive Summary
This architecture describes a secure, cloud-native banking platform designed for high availability and zero-trust security.

## 2. Core Components

### Identity & Access Management (IAM)
*   **Primary IdP:** Centralized Identity Provider handling OIDC and SAML flows.
*   **Orchestration:** Logic layer to handle Step-Up Authentication (MFA) based on risk signals.
*   **Session Management:** Distributed session state stored in MongoDB (Audit/Logs) and Redis (Hot State).

### Application Layer
*   **API Gateway:** Entry point for all client traffic. Enforces rate limiting, TLS termination, and initial JWT validation.
*   **Microservices:** Containerized services (Node.js/Python) running on GCP.

## 3. Infrastructure & Operations
*   **Cloud Provider:** Google Cloud Platform (GCP).
*   **Infrastructure as Code:** Terraform is mandated for all infrastructure provisioning.
    *   **Configuration:** Use `variables.tf` for declarations.
    *   **Environments:** State must be managed via environment-specific variable files: `dev.tfvars`, `test.tfvars`, and `prod.tfvars`.
*   **Cost Optimization:** Select budget-friendly GCP services (e.g., Cloud Run) where possible, provided security is not compromised. 
*   **IAM Security:** Service Account names must never be hardcoded in Terraform modules. They must be passed as variables (e.g., `keycloak_serv_acc_account_id`) from `.tfvars` to allow flexibility and prevent information leakage.
Infrastructure and GCP services are listed under the infrastructure.md. 
*   Region and Zone: The region and/or zone will be specified at the .tfvars level/files.

## 4. Security Architecture
**Priority: Security is the primary driver for all architectural decisions.**

*   **Zero Trust Network:** Service-to-service communication is encrypted via mTLS.
*   **Data at Rest:** All databases (MongoDB, SQL) are encrypted using customer-managed keys.
*   **Secrets Management:** No passwords, keys, or sensitive information are hardcoded. All credentials are injected at runtime via GCP Secret Manager.

### Network Traffic & Isolation for project1: 
*   **Ingress (Incoming):** Services are exposed via public HTTPS endpoints (`*.run.app`). TLS is terminated at the Cloud Run edge (Google Front End). Traffic reaches the container via HTTP/8080.
*   **Egress (Outgoing):** All outbound traffic is routed through the **Serverless VPC Access Connector**.
    *   *Internal:* Database connections use Private IPs.
    *   *Internet:* Routed via Cloud NAT for static IP stability.

## 5. Data Flow
1.  User authenticates via IdP.
2.  IdP issues OIDC Token.
3.  Client sends Token to API Gateway.
4.  Gateway validates signature and forwards request to backend services.

## 6. Directory Structure & Organization
To maintain a clean and navigable codebase, the following directory standards apply to all services and infrastructure components:

*   **`Documentation/`**: Central repository for all project documentation.
    *   `internal/`: Policy and governance documents.
*   **`Infrastructure/`**: Terraform and cloud configuration.
*   **Service Directories (e.g., `Services/{name}` or Project folders):**
    *   `src/`: Application logic and source code.
    *   `container/`: Containerization assets (`Dockerfile`, `docker-compose.yml`, entrypoint scripts).
    *   `tests/`: Unit and integration tests.
    *   `config/`: Non-sensitive configuration files.
*   **`Infrastructure/`**: Terraform and cloud configuration.
*   **Service Directories (e.g., `Services/{name}` or Project folders):**
    *   `src/`: Application logic and source code.
    *   `container/`: Containerization assets (`Dockerfile`, `docker-compose.yml`, entrypoint scripts).
    *   `tests/`: Unit and integration tests.
    *   `config/`: Non-sensitive configuration files.
