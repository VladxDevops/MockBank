# Project 3: Mosaic Migration (CI/CD & Release Safety)

**CLASSIFICATION: INTERNAL**

## 1. Objective
Build a CI/CD pipeline that manages Identity Configuration as Code. This simulates the "Mosaic (Scale-Up)" and "DevOps/Release" requirements, focusing on safe deployments and config promotion.

## 2. Architecture
*   **Tooling:** GitHub Actions, Terraform (Keycloak Provider).
*   **Strategy:** GitOps.
*   **Environments:**
    *   `DEV`: Auto-apply on merge.
    *   `PROD`: Plan (Dry Run) -> Manual Approval -> Apply.

## 3. The Scenario (Bank Context)
**Task:** The Fraud Team requires a new "Risk Scope" added to the OIDC token for the Retail App.
**Constraint:** You cannot break existing logins during deployment.

## 4. Pipeline Logic (GitHub Actions)
1.  **Feature Branch:**
    *   Developer adds scope in Terraform.
    *   CI runs `terraform plan`.
2.  **Merge to DEV:**
    *   CI runs `terraform apply -var-file=dev.tfvars`.
    *   Automated smoke test: Verify token contains new scope.
3.  **PR to PROD:**
    *   CI runs `terraform plan -var-file=prod.tfvars`.
    *   **Gate:** Human approval required.
    *   CD runs `terraform apply`.

## 5. Interview Prep: Release Safety
**Question:** "How do you ensure a config change doesn't lock out users?"
**Answer:**
*   **Phased Deployment:** I use Terraform to apply changes to a `staging` realm first.
*   **Backward Compatibility:** When adding scopes, I ensure the application code handles the *absence* of the scope gracefully before enforcing it.
*   **Rollback:** Since config is code, I can `git revert` and re-apply the previous state immediately.

## 6. Development Plan
1.  Export Keycloak Realm config to Terraform.
2.  Create GitHub Actions workflow `.github/workflows/identity-ops.yml`.
3.  Simulate a "breaking change" and fix it via pipeline.
