# Project 1: Secure Bank Portal (Identity & Access Management)

## Overview
Project 1 establishes the **Identity Provider (IdP)** for the Altmtrk2026 Banking Platform. It deploys **Keycloak** on Google Cloud Run, backed by a **Cloud SQL (PostgreSQL)** database.

This project demonstrates:
*   **OIDC (OpenID Connect):** For modern retail banking applications.
*   **SAML 2.0:** For legacy internal teller portals.
*   **MFA (Multi-Factor Authentication):** Time-based One-Time Password (TOTP) enforcement.

## Architecture
*   **Compute:** Google Cloud Run (Serverless Container).
*   **Database:** Google Cloud SQL (PostgreSQL 15).
*   **Secrets:** GCP Secret Manager (DB Credentials, Admin Passwords).
*   **Connectivity:** Serverless VPC Access Connector (Private connection to DB).

## Getting Started

### 1. Infrastructure Deployment
Navigate to the `terraform` directory and apply the configuration for Project 1.

```bash
cd ../../terraform
terraform apply -target=module.project1
```

### 2. Accessing Keycloak
Once deployed, Terraform will output the `keycloak_url`.
1.  Navigate to the URL.
2.  Log in to the **Administration Console**.
3.  **Username:** `admin`
4.  **Password:** Retrieve from Secret Manager (`keycloak-admin-password`).

### 3. Configuration
Refer to `PROJECT1_DETAILS.md` for instructions on configuring the `AltmtrkBank` realm and clients.

## Directory Structure
*   `container/`: Dockerfile for the custom Keycloak image.
*   `AGENTS.md`: Bot protocols for this project.
*   `INFRASTRUCTURE.md`: List of cloud resources.
*   `SECURITY.md`: Security controls specific to Identity.
*   `TROUBLESHOOTING.md`: Solutions for common Cloud Run and IAM deployment errors.

## References
*   Internal Architecture
*   Project Details