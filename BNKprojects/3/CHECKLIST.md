# Project 3: Mosaic Migration (CI/CD & Release Safety) Checklist

## 1. Environment & Provider Setup - ACTIVE
- [x] **Keycloak Provider Init:** Configure the `mrparkers/keycloak` Terraform provider.
- [x] **Authentication:** Map admin credentials from Secret Manager and fetch URL from Cloud Run data source.
- [ ] **Workspace Strategy:** Initialize Terraform workspaces for `DEV` and `PROD` environments.
- [ ] **Backend Sync:** Ensure remote state is configured in GCS to prevent state locks during concurrent pipeline runs.

## 2. Configuration as Code (GitOps) - ACTIVE
- [x] **Keycloak Provider Init:** Already initialized in step 1.
- [x] **Realm Migration:** Core realm and Retail App OIDC client defined in HCL.
- [x] **Client Definition:** SAML `teller-portal` resource defined with automated TLS generation.
- [x] **Environment Parity:** Managed via branch-based logic in GitHub Actions.
- [x] **Scenario - Risk Scope:** New `risk` scope defined as an HCL resource.


## 3. CI/CD Pipeline (GitHub Actions) - IN PROGRESS (Awaiting Verification)
- [x] **Workflow Creation:** Defined `.github/workflows/deploy.yml` for automated releases.
- [x] **GCP Authentication:** Linked jobs to 'DEV' environment and resolved IAM permissions.
- [x] **Pull Request Job:** Integrated `terraform-plan` job into the workflow.
- [ ] **DEV Deployment:** Automate release creation via Cloud Deploy upon merging.
- [x] **Security Gate:** Implemented SAST scanning in the pipeline.

## 4. Release Safety & Validation - PENDING
- [ ] **Phased Deployment:** Verify changes in the `DEV` realm before promoting to `PROD`.
- [ ] **Automated Smoke Test:** Implemented `smoke-test-identity` job in GHA.
- [ ] **Rollback Procedure:** Document and test the `git revert` flow to restore identity configuration in case of failure.
- [ ] **Drift Detection:** Configure a scheduled job to detect manual changes made in the Keycloak UI that aren't in Git.

## 5. Development Plan Status
Based on `BNKprojects/3/PROJECT_DETAILS.md`, the following steps track the final release:

1. [ ] **Export Keycloak Realm config to Terraform.**
2. [ ] **Create GitHub Actions workflow `.github/workflows/deploy.yml`. (In Progress)**
3. [ ] **Simulate a "breaking change" and fix it via pipeline.**

---
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the IMPLEMENTATION phase.
**Classification: INTERNAL**
2. [x] **Create GitHub Actions workflow `.github/workflows/deploy.yml`.**
3. [ ] **Simulate a "breaking change" and fix it via pipeline.**

---
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the IMPLEMENTATION phase.
**Classification: INTERNAL**
2. [x] **Create GitHub Actions workflow `.github/workflows/deploy.yml`.**
3. [ ] **Simulate a "breaking change" and fix it via pipeline.**

---
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the IMPLEMENTATION phase.
**Classification: INTERNAL**
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the IMPLEMENTATION phase.
**Classification: INTERNAL**
2. [x] **Create GitHub Actions workflow `.github/workflows/deploy.yml`.**
3. [ ] **Simulate a "breaking change" and fix it via pipeline.**

---
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the IMPLEMENTATION phase.
**Classification: INTERNAL**
