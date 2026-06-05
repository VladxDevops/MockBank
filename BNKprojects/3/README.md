# Project 3: Global CI/CD (Release Safety)

## Overview
Project 3 provides the automation engine for the Altmtrk2026 Bank Platform. It focuses on transition from "human-in-the-loop" infrastructure to "declarative-only" automated deployments.

## Tech Stack
*   **GCP Cloud Build:** Primary CI/CD engine.
*   **Artifact Registry:** Secure storage for Docker images.
*   **Terraform:** Infrastructure automation.
*   **Workload Identity Federation:** Keyless GCP authentication.

## Getting Started
1.  **Foundation:** Ensure Project 0 (Foundation) is deployed. It provides the base VPC and WIF Pool.
    ```bash
    cd ../zero
    # Follow instructions in Project 0 README
    ```
2.  **Infrastructure:** Deploy the CI/CD pipelines via Terraform.
    ```bash
    cd ../../terraform
    terraform apply -target=module.project3
    ```
3.  **Identity Federation:** Configure the OIDC provider for GitHub Actions (now managed in Project 0).
3.  **Triggers:** Configure Cloud Build triggers for the `DEV` branch.

## Documentation
*   Project Details
*   Release Safety Policy
*   Changelog
# Project 3: Global CI/CD (Release Safety)

## Overview
Project 3 provides the automation engine for the Altmtrk2026 Bank Platform. It focuses on transition from "human-in-the-loop" infrastructure to "declarative-only" automated deployments.

## Tech Stack
*   **GCP Cloud Build:** Primary CI/CD engine.
*   **Artifact Registry:** Secure storage for Docker images.
*   **Google Cloud Deploy:** Managed Continuous Delivery for Cloud Run.
*   **ArgoCD:** GitOps engine for future GKE workloads (on GKE Autopilot).
*   **Terraform:** Infrastructure automation.
*   **Workload Identity Federation:** Keyless GCP authentication (Managed in Project 0).

## Getting Started
1.  **Foundation:** Ensure Project 0 (Foundation) is deployed. It provides the base VPC, WIF Pool, and the Shared GitHub Actions Service Account.
    ```bash
    cd ../zero
    # Follow instructions in Project 0 README
    ```
2.  **Infrastructure:** Deploy the CI/CD pipelines via Terraform.
    ```bash
    cd ../../terraform
    terraform apply -target=module.project3
    ```
3.  **Identity Federation:** Configure the OIDC provider for GitHub Actions (now managed in Project 0).
3.  **Triggers:** Configure Cloud Build triggers for the `DEV` branch.

## Documentation
*   Project Details
*   Release Safety Policy
*   Changelog

## Status: Infrastructure Ready
*   [x] Terraform Provisioning (WIF + Cloud Deploy)
*   [ ] GitHub Actions Workflow Integration (In Progress - Awaiting Verification)
*   [ ] Skaffold Configuration (In Progress - Awaiting Verification)

### Troubleshooting WIF
If the GitHub Action fails at the authentication step, verify the `WIF_PROVIDER` secret matches the output of:
```bash
gcloud iam workload-identity-pools providers describe "github-provider" \
  --workload-identity-pool="github-pool" \
  --location="global" \
  --format="value(name)"
```
iate
