# Project 0: Foundation Infrastructure Planning

## 1. Root-Level Infrastructure (Global Configuration)
These components stay at the root of the `terraform/` directory to manage global state and provider context. **Note: A root-level `main.tf` is intentionally omitted** to favor a decoupled, multi-stack approach.

*   **`provider.tf`**: Centralized declarations for the `google`, `mongodbatlas`, and `keycloak` providers. This ensures a consistent authentication context across all modules.
*   **`backend.tf`**: Remote state configuration (GCS bucket) to maintain a single source of truth for the infrastructure state.
*   **`variables.tf`**: Global variable definitions (e.g., `project_id`, `region`, `environment`) that are passed down to child modules.
*   **Decoupled State**: Projects are managed as individual stacks (e.g., via `-target` or separate directory execution) rather than being wrapped in a single root module.
*   **`*.tfvars`**: Environment-specific configuration files (`dev.tfvars`, `prod.tfvars`) that prevent hardcoding and support environment isolation.
*   **Orchestration Logic**: Deployment is handled via CI/CD pipelines (Project 3) or manual execution within specific module directories to prevent a "Monolithic Apply."

## 2. Project 0 (Foundation) Module Infrastructure
These are shared services that provide the "base layer" for the banking platform. Moving these to `project0` ensures that networking and security are standardized before application-specific resources are deployed.

### A. API Management
*   **GCP Service APIs**: Centralized enablement of `compute.googleapis.com`, `run.googleapis.com`, `sqladmin.googleapis.com`, and `artifactregistry.googleapis.com`.

### B. Shared Networking (Zero Trust Foundation)
*   **Global VPC**: The `DEV-compute-vpc` that hosts all service communication.
*   **Private Subnets**: Regional subnets designed for Serverless VPC Access.
*   **Serverless VPC Access Connector**: Shared connectors (like `avechector`) used by Cloud Run services in Projects 1 and 2.
*   **Cloud NAT & Cloud Router**: Provides secure egress and static IPs for external API calls (e.g., to MongoDB Atlas).

### C. Shared Registry
*   **Artifact Registry**: A centralized Docker repository where images for the Identity Service (Project 1) and Transaction Service (Project 2) are stored. 

### D. Global IAM & Workload Identity Federation (WIF)
*   **Workload Identity Federation (WIF)**: The Pool and Provider configurations that allow GitHub Actions to authenticate without static secrets.
*   **Shared Service Accounts**: The primary GitHub Actions service account and foundational IAM bindings.

### E. Shared Secrets Management
*   **Secret Manager Placeholders**: Definition of secrets that are shared across projects, such as the `atlas_public_key` or `keycloak_administrator_password`.

## 3. Infrastructure Remaining in Project-Specific Modules
To maintain modularity, service-specific logic should **not** be moved to Project 0:

*   **Project 1**: Keycloak Cloud Run service and the Cloud SQL (Postgres) instance.
*   **Project 2**: Transaction Service Cloud Run definition and MongoDB Atlas cluster/user configurations.
*   **Project 3**: Google Cloud Deploy pipelines and specific delivery targets.

## 4. Implementation Rationale
*   **Security**: Centralizing WIF and Networking in Project 0 enforces the "Prime Directive" (Security > Velocity) by ensuring no application can bypass the VPC or IAM standards.
*   **Efficiency**: Consolidating API enablement prevents "Provider Proxy" issues and reduces the risk of race conditions during initial bootstrapping.
*   **Reduced Blast Radius**: By not using a central `main.tf`, we ensure that changes to the Transaction Service (Project 2) do not inadvertently trigger a refresh or modification of the Foundation (Project 0) unless explicitly targeted.
*   **Maintainability**: Root-level providers ensure that all modules share the same credentials and versioning, as documented in `CHANGELOG.md` version `[0.7.0]`.
