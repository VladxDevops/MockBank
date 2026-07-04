# Project 3: Identity Configuration & Release Safety

## Overview
Project 3 manages identity and authorization configuration for the Altmtrk2026 Bank Platform. It provides:
1. **Identity Configuration:** Keycloak realms, clients, and authentication policies (declarative via Terraform).
2. **Release Safety:** Policy documentation and deployment gates for secure, staggered releases.

**Note:** Core CI/CD infrastructure (GitHub Actions, Workload Identity Federation, Artifact Registry) has been **migrated to Project 0 (Foundation)** for centralization and reusability across all services.

## Tech Stack
*   **Keycloak:** Identity and Access Management (IAM/AuthN/AuthZ).
*   **Terraform:** Infrastructure-as-Code for identity configuration.
*   **Google Cloud Deploy:** Managed Continuous Delivery for Cloud Run services (orchestrated from GitHub Actions via Project 0).
*   **GitHub Actions:** Primary CI/CD engine (WIF and credentials managed in Project 0).
*   **Artifact Registry:** Secure storage for Docker images (provisioned in Project 0).

## Getting Started
1.  **Prerequisites:** Ensure Project 0 (Foundation) is deployed. It provides:
    *   Workload Identity Federation (WIF) Pool and Provider
    *   Shared GitHub Actions Service Account
    *   Artifact Registry
    ```bash
    cd ../zero
    # Follow instructions in Project 0 README
    ```

2.  **Deploy Identity Infrastructure:**
    ```bash
    cd ../../terraform
    terraform apply -target=module.project3
    ```
    This creates Keycloak realms, clients, and secret configurations.

3.  **Verify Identity Service:** Ensure Project 1 (Identity Service) is running:
    ```bash
    cd ../1
    # Review TEST-KEYCLOAK/README.md for testing procedures
    ```

## Documentation
*   [PROJECT3_DETAILS.md](./PROJECT3_DETAILS.md) — Release Safety policy and deployment strategy
*   [SAML_INTERVIEW_QA.md](./SAML_INTERVIEW_QA.md) — SAML/OIDC authentication Q&A
*   [CHECKLIST.md](./CHECKLIST.md) — Deployment checklist

## Architecture
```
Project 0 (Foundation)
├── GitHub Actions Service Account (WIF-enabled)
├── Workload Identity Federation Pool & Provider
├── Artifact Registry
└── CI/CD Infrastructure

Project 3 (Identity Configuration)
├── Keycloak Realm Configuration
├── OAuth2/SAML Clients
├── Release Safety Policy
└── Deployment Orchestration
```

## Status: Identity-First Delivery
*   [x] Terraform Provisioning (Project 0 Foundation)
*   [x] GitHub Actions Workflow Integration (WIF authentication via Project 0)
*   [x] Cloud Deploy configuration for Cloud Run services
*   [x] Keycloak identity configuration (via Terraform)
*   [ ] ArgoCD for GitOps (Planned after Cloud Run pipelines stabilize)

## CI/CD Pipeline Flow
1. **Push to `dev` branch** → GitHub Action triggered
2. **WIF Authentication** → Keyless login to GCP (via Project 0 WIF)
3. **SAST/Tests** → Security scanning and unit tests
4. **Terraform Plan** → Preview identity and infrastructure changes
5. **Cloud Deploy Release** → Managed rollout to Cloud Run services
6. **Post-Deployment Tests** → Health checks via `test-*.sh` scripts

## Troubleshooting

### GitHub Actions WIF Issues
If GitHub Actions fails at the GCP authentication step:
```bash
# Verify WIF Provider resource name (configured in Project 0)
gcloud iam workload-identity-pools providers describe "github-provider" \
  --workload-identity-pool="github-pool" \
  --location="global" \
  --format="value(name)"

# Verify GitHub Actions Service Account impersonation role
gcloud iam service-accounts get-iam-policy \
  projects/PROJECT_NUMBER/serviceAccounts/GITHUB_SA_EMAIL
```

### Identity Configuration Issues
If Keycloak configuration fails during `terraform apply`:
1. Ensure Project 1 (Identity Service/Keycloak) is fully deployed and accessible
2. Verify `keycloak_url` and `keycloak_client_id` in [`terraform/dev.tfvars`](../../terraform/dev.tfvars)
3. Check logs: `kubectl logs -n keycloak deployment/keycloak` (if using GKE)

For detailed troubleshooting, refer to [Documentation/internal/RELEASE_SAFETY.md](../../Documentation/internal/RELEASE_SAFETY.md).


