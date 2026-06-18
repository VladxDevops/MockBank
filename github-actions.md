# GitHub Actions Infrastructure Planning & Logic

This document outlines the design and operational logic of the CI/CD pipelines for the Bank Platform, specifically focusing on the Project 0 (Foundation) workflows.

## 1. Workflow Architecture

We employ two primary workflows to manage our infrastructure:
- **CI (Foundation Validation):** Triggered on pushes to the `DEV` branch. It focuses on code quality, formatting, and impact analysis (Plan).
- **CD (Foundation Deployment):** Triggered on merges/pushes to the `DEV` branch. It handles the actual resource provisioning (Apply).

## 2. Key Job & Step Descriptions

### A. Auto-fix (Linting & Formatting)
Located in `ci.yaml`, this job ensures that HCL code remains clean and standard across the team.
- **Logic:** It runs `terraform fmt -recursive`.
- **Automation:** If changes are detected, it utilizes the `git-auto-commit-action` to push the formatted code back to the branch, preventing PRs from being blocked by simple syntax "noise."

### B. Authentication (Workload Identity Federation)
Following the **Prime Directive (Security > Efficiency)**, we do not store long-lived service account keys.
- **Logic:** The `google-github-actions/auth` step uses OIDC to exchange a GitHub token for a short-lived GCP access token via a Workload Identity Pool.

### C. Secret Materialization (The Heredoc Pattern)
To avoid committing sensitive `.tfvars` files, we reconstruct the environment configuration at runtime.
- **Logic:** We use a shell heredoc (`cat <<'EOF' > dev.tfvars`) to write the contents of the `TFVARS_DEV` GitHub Secret into a temporary file. 
- **Security:** The use of `'EOF'` (quoted) prevents the shell from attempting to expand variables inside the secret during the write process.

### D. Terraform Initialization (`init`)
This was a primary source of "Module not installed" and "Backend configuration" errors.
- **Order of Operations:** `init` must run before `validate` or `plan` to download providers and local modules.
- **Logic:** We use `terraform init -input=false -reconfigure -backend-config="bucket=..."`.
- **Fix:** We removed the `-backend-config="project=..."` argument because the GCS backend does not support project-level overrides at the CLI level when the bucket is already defined in HCL.

### E. Workspace Selection
- **Logic:** We use `terraform workspace select -or-create projectZERO`.
- **Purpose:** This ensures that foundational infrastructure state is isolated from application-level state, even if the workspace hasn't been initialized yet.

### F. Validation & Planning (`validate` & `plan`)
- **Validate:** Checks the HCL for internal consistency and syntax.
- **Plan:** Generates an execution plan. We use `-target=module.project0` to restrict the scope to foundational resources, preventing the runner from trying to plan application-layer resources (like Keycloak or MongoDB Atlas) before the foundation is ready.

### G. Infrastructure Application (`apply`)
Located in `cd.yaml`.
- **Logic:** Runs `terraform apply -auto-approve`.
- **Constraint:** Like the plan step, it targets the `project0` module to ensure a "Foundation First" deployment strategy.

### H. Release Orchestration (Cloud Deploy)
Triggered after a successful Infrastructure Apply and Container Build.
- **Logic:** Runs `gcloud deploy releases create`.
- **Role:** This separates infrastructure state from application versioning, allowing for safe rollbacks and promotion from DEV to PROD without touching Terraform code.

## 3. Resolved Issues Recap

| Issue | Resolution |
| :--- | :--- |
| **Module not installed** | Reordered `init` to occur immediately after setup and before any other command. |
| **Invalid backend argument** | Removed `project` from `-backend-config` as it conflicted with GCS backend defaults. |
| **Quote stripping in secrets** | Switched to `cat <<'EOF'` to preserve special characters in `tfvars`. |
| **409 Conflict (State Divergence)** | Implemented `-reconfigure` in `init` to force synchronization with the GCS bucket. |
| **State Lock Contention** | Implemented `concurrency` groups and `-lock-timeout=20m` to prevent CI/CD collisions. |

---
*Last Updated: 2024-05-24*