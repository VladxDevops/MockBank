+++
title = "Project 1: Secure Bank Portal (Identity & Access Management)"
domain = "identity"
topics = ["project1", "keycloak", "cloud-run", "cloud-sql", "oidc", "saml"]
difficulty = "intermediate"
parent = "../README.md"
children = ["PROJECT1_DETAILS.md", "SECURITY.md", "ARCHITECTURE.md", "AGENTS.md"]
related = ["../../Documentation/internal/keycloak.md", "../../terraform/modules/project3/README.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`BNKprojects/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/README.md)  
> **Technical Details**: [`PROJECT1_DETAILS.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/1/PROJECT1_DETAILS.md)  
> **Keycloak Global Overview**: [`Documentation/internal/keycloak.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/keycloak.md)

<!-- AI RETRIEVAL HINTS
- Purpose: Primary documentation for Project 1 (Keycloak Identity Provider on Cloud Run with Cloud SQL PostgreSQL).
- Questions Answered:
  1. What is the architecture of Project 1 Identity Service?
  2. How to run Keycloak and the Python app locally or via Docker?
  3. How are OIDC, SAML, and MFA configured for Project 1?
- When to Retrieve: Querying Project 1 setup, Keycloak local container execution, or Python identity app.
- When NOT to Retrieve: Querying Project 2 Node.js transactions or Project 4 Actimize AML rules.
- Prerequisites: [../README.md]
- Follow-up Reading: [PROJECT1_DETAILS.md]
-->

---

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
*   **Connectivity:** **Zero-Trust** via Cloud SQL Python Connector (IAM-based auth).
*   **Secrets:** GCP Secret Manager (DB Credentials, Admin Passwords).
*   **Connectivity:** Serverless VPC Access Connector (Private connection to DB).

## Tech Stack
*   **Language:** Python 3.10+
*   **Libraries:** Authlib (OIDC), python3-saml (SAML), Flask.

## Getting Started

### 1. Infrastructure Deployment
**Prerequisite**: Project 0 (Foundation) must be deployed to establish the VPC and networking.

Navigate to the `terraform` directory and apply the configuration for Project 1.

```bash
cd ../../terraform
terraform apply -target=module.project1
```

### 2. Accessing Keycloak
Once deployed, Terraform will output the `keycloak_url`.
1.  **Get URL:** `gcloud run services describe keycloak-service --region us-south1 --format 'value(status.url)'` Paste the Key cloak url to the DEV or environment TFvars file as the value for the keycloak_url variable. Then update the TFvars file in the github actions secrets with the new value and run the github actions workflow or terraform apply again to update the keycloak_url in the environment. 
2.  **Get Password:** `gcloud secrets versions access latest --secret="keycloak-admin-password"`
3.  **Login:** Navigate to the URL, click **Administration Console**, and use `admin` with the retrieved password.
4.  **Switch Realm:** Select **Mockbankrealm** from the dropdown menu in the top-left corner.

### 3. Configuration
Refer to `PROJECT1_DETAILS.md` for instructions on configuring the `Mockbankrealm` realm and clients.

### 4. Dependency Management
This project uses `pip-tools` for deterministic builds.
1.  **Declare:** Edit `requirements.in` to add/remove top-level libraries.
2.  **Compile:** Generate the pinned `requirements.txt` (the lockfile):
    ```bash
    pip-compile requirements.in --output-file=requirements.txt
    ```
3.  **Install:** Sync your local environment to the lockfile:
    ```bash
    pip-sync requirements.txt
    ```

## Verification & Testing
An automated verification script `test-keycloak.sh` is available in this directory. 
**Status:** Initial execution is currently pending. 
Use this script to validate realm configuration, client policies (PKCE/S256), and container health.

## Directory Structure
*   `container/`: Dockerfile for the custom Keycloak image.
*   `AGENTS.md`: Bot protocols for this project.
*   `INFRASTRUCTURE.md`: List of cloud resources.
*   `SECURITY.md`: Security controls specific to Identity.
*   `TROUBLESHOOTING.md`: Solutions for common Cloud Run and IAM deployment errors.

## References
*   Internal Architecture
*   Project Detailsements.txt
    ```

## Verification & Testing
An automated verification script `test-keycloak.sh` is available in this directory. 
**Status:** Initial execution is currently pending. 
Use this script to validate realm configuration, client policies (PKCE/S256), and container health.

## Directory Structure
*   `container/`: Dockerfile for the custom Keycloak image.
*   `AGENTS.md`: Bot protocols for this project.
*   `INFRASTRUCTURE.md`: List of cloud resources.
*   `SECURITY.md`: Security controls specific to Identity.
*   `TROUBLESHOOTING.md`: Solutions for common Cloud Run and IAM deployment errors.

## References
*   Internal Architecture
*   Project Details