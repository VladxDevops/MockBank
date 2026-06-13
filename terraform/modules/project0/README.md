# Project 0: Foundation Infrastructure Module

## Overview
This module serves as the foundational "Base Layer" for the Altmtrk2026 Bank Platform. It is responsible for provisioning the global infrastructure required by all application-specific projects (Project 1, 2, and 3). 

By centralizing networking, identity, and registry management here, we ensure compliance with the **Prime Directive (Security > Velocity)** and maintain a single source of truth for the environment's security posture.

## Core Components

### 1. API Management
Automates the enablement of 15+ Google Cloud APIs (Compute, Cloud Run, SQL Admin, Secret Manager, Cloud Build, etc.). It uses a "Bootstrap" logic to prevent race conditions during the initial project setup.

### 2. Zero-Trust Networking
*   **Global VPC:** A custom-mode VPC (`main-vpc`) with `auto_create_subnetworks = false`.
*   **Serverless VPC Access:** Shared connectors (`avechector`) used for private communication between Cloud Run and Cloud SQL/MongoDB.
*   **Cloud NAT:** Provides secure egress and static IPs for external API calls, ensuring the internal network remains private.
*   **VPC Peering:** Configured for Private Service Access to support Google-managed services.

### 3. Identity & Security (Migrated from Project 3)
*   **Workload Identity Federation (WIF):** Provisioning of the WIF Pool and Provider for GitHub Actions.
*   **Shared Service Account:** The `sa-github-actions` identity used by all CI/CD pipelines.
*   **Centralized IAM:** Explicit declaration of 10+ project-level IAM roles (Storage Admin, Cloud Build Editor, etc.) for the GitHub Actions identity to ensure least-privilege consistency.
*   **Cross-Project State Management:** Provisioning of `roles/storage.objectAdmin` and `roles/resourcemanager.projectIamAdmin` for the Deployer and GitHub SAs in the centralized state project.

### 4. Shared Resources
*   **Artifact Registry:** The centralized Docker repository for the entire platform.
*   **Secret Manager:** Placeholder definitions for cross-project secrets.

## Usage

### Workspace Requirement
Infrastructure managed by this module must reside in the `projectZERO` Terraform workspace to isolate foundational state from application-layer state.

```bash
terraform workspace select -or-create projectZERO
```

### Deployment Phases

#### Phase A: Bootstrapping (APIs Only)
Before networking or IAM can be provisioned, the APIs must be enabled. This requires a "Project Owner" or "Service Usage Admin" identity.

```bash
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.project0
```

#### Phase B: Full Foundation
Once APIs are active, run the full module to provision networking and identity.

```bash
terraform apply -var-file="dev.tfvars" -target=module.project0
```

## Security Standards

### 1. Lifecycle Protection
Critical resources like the **Workload Identity Pool**, **Artifact Registry**, and **Secret Manager** entries have `prevent_destroy = true` enabled. This protects the "Identity Root" from accidental deletion.

### 2. Explicit IAM
Following the standards in `AGENTS.md`, every IAM role assignment is declared as a unique `google_project_iam_member` resource. This ensures visibility during `terraform plan` and prevents accidental permission bloat.

### 3. Ephemeral Credentials
The WIF configuration allows GitHub Actions to authenticate via OIDC, eliminating the need for long-lived Service Account JSON keys in GitHub Secrets.

## Cost Optimization
*   **Regional Standard Tier:** The Load Balancer (when enabled) and static IPs use the **STANDARD** network tier.
*   **Environment Gating:** By default, external Load Balancing is **DISABLED** for non-PROD environments (DEV/TEST). In these environments, ingress is handled via `gcloud run services proxy`.

## Variables Summary
| Name | Description | Type |
| :--- | :--- | :--- |
| `compute_project_id` | Target GCP Project ID | `string` |
| `compute_region` | Primary region for networking/compute | `string` |
| `github_repository` | Format: `owner/repo` for WIF binding | `string` |
| `terraform_deployer_service_account` | Admin SA running the terraform | `string` |

## Outputs Summary
| Name | Description |
| :--- | :--- |
| `vpc_id` | ID of the centralized VPC |
| `connector_id` | ID of the Serverless VPC Connector |
| `github_actions_sa_email` | The email for the shared CI/CD identity |

## Troubleshooting
For detailed logs on failed deployments or state conflicts (e.g., 409 Secret Already Exists), refer to:
`terraform/modules/project0/TROUBLESHOOTING_PROJECT0.md`

---
**Note:** All changes to this module must be documented in the root `CHANGELOG.md`.
