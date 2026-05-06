# Project 3: Global CI/CD (Release Safety)

## Overview
Project 3 provides the automation engine for the Altmtrk2026 Bank Platform. It focuses on transition from "human-in-the-loop" infrastructure to "declarative-only" automated deployments.

## Tech Stack
*   **GCP Cloud Build:** Primary CI/CD engine.
*   **Artifact Registry:** Secure storage for Docker images.
*   **Terraform:** Infrastructure automation.
*   **Workload Identity Federation:** Keyless GCP authentication.

## Getting Started
1.  **Infrastructure:** Deploy the CI/CD base via Terraform.
    ```bash
    cd ../../terraform
    terraform apply -target=module.project3
    ```
2.  **Identity Federation:** Configure the OIDC provider for GitHub Actions (see `PROJECT3_DETAILS.md`).
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
*   **Workload Identity Federation:** Keyless GCP authentication.

## Getting Started
1.  **Infrastructure:** Deploy the CI/CD base via Terraform.
    ```bash
    cd ../../terraform
    terraform apply -target=module.project3
    ```
2.  **Identity Federation:** Configure the OIDC provider for GitHub Actions (see `PROJECT3_DETAILS.md`).
3.  **Triggers:** Configure Cloud Build triggers for the `DEV` branch.

## Documentation
*   Project Details
*   Release Safety Policy
*   Changelog
