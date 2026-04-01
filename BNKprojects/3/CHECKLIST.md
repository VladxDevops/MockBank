# Project 3: Mosaic Migration (CI/CD & Release Safety) Checklist

## 1. Environment & Provider Setup - PENDING
- [ ] **Keycloak Provider Init:** Configure the `mrparkers/keycloak` Terraform provider.
- [ ] **Authentication:** Securely map IdP admin credentials from Secret Manager to the Terraform runner.
- [ ] **Workspace Strategy:** Initialize Terraform workspaces for `DEV` and `PROD` environments.
- [ ] **Backend Sync:** Ensure remote state is configured in GCS to prevent state locks during concurrent pipeline runs.

## 2. Configuration as Code (GitOps) - PENDING
- [ ] **Realm Import:** Convert the existing `AltmtrkBank` JSON export into Terraform HCL resources (`keycloak_realm`).
- [ ] **Client Definition:** Define the `retail-app` (OIDC) and `teller-portal` (SAML) as Terraform resources.
- [ ] **Environment Parity:** Create `dev.tfvars` and `prod.tfvars` to manage environment-specific URLs and secrets.
- [ ] **Scenario - Risk Scope:** Define the new `risk` scope resource in HCL to satisfy the Fraud Team's requirement.

## 3. CI/CD Pipeline (GitHub Actions) - PENDING
- [ ] **Workflow Creation:** Define `.github/workflows/identity-ops.yml`.
- [ ] **GCP Authentication:** Set up Workload Identity Federation (WIF) to allow GitHub Actions to access GCP resources without long-lived keys.
- [ ] **Pull Request Job:** Implement `terraform plan` on every PR to verify syntax and security impact.
- [ ] **DEV Deployment:** Automate `terraform apply` upon merging to the `DEV` branch.
- [ ] **PROD Deployment:** Implement a manual approval gate and "Dry Run" plan for the `PROD` branch.

## 4. Release Safety & Validation - PENDING
- [ ] **Phased Deployment:** Verify changes in the `DEV` realm before promoting to `PROD`.
- [ ] **Automated Smoke Test:** Script a check to verify that the issued OIDC token actually contains the new `risk` scope after deployment.
- [ ] **Rollback Procedure:** Document and test the `git revert` flow to restore identity configuration in case of failure.
- [ ] **Drift Detection:** Configure a scheduled job to detect manual changes made in the Keycloak UI that aren't in Git.

## 5. Development Plan Status
Based on `BNKprojects/3/PROJECT_DETAILS.md`, the following steps track the final release:

1. [ ] **Export Keycloak Realm config to Terraform.**
2. [ ] **Create GitHub Actions workflow `.github/workflows/identity-ops.yml`.**
3. [ ] **Simulate a "breaking change" and fix it via pipeline.**

---
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the PLANNING phase.
**Classification: INTERNAL**
