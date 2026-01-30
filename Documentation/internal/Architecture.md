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
*   **Cost Optimization:** Select budget-friendly GCP services (e.g., Cloud Run) where possible, provided security is not compromised.

## 4. Security Architecture
**Priority: Security is the primary driver for all architectural decisions.**

*   **Zero Trust Network:** Service-to-service communication is encrypted via mTLS.
*   **Data at Rest:** All databases (MongoDB, SQL) are encrypted using customer-managed keys.
*   **Secrets Management:** No passwords, keys, or sensitive information are hardcoded. All credentials are injected at runtime via GCP Secret Manager.

## 5. Data Flow
1.  User authenticates via IdP.
2.  IdP issues OIDC Token.
3.  Client sends Token to API Gateway.
4.  Gateway validates signature and forwards request to backend services.
