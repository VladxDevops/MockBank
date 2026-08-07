# Project 3: Mosaic Migration (CI/CD & Release Safety) Checklist

## 1. Environment & Provider Setup - ACTIVE
- [x] **Keycloak Provider Init:** Configure the `mrparkers/keycloak` Terraform provider.
- [x] **Authentication:** Map admin credentials from Secret Manager and fetch URL from Cloud Run data source.

## 2. Configuration as Code (GitOps) - ACTIVE
- [x] **Keycloak Provider Init:** Already initialized in step 1.
- [x] **Realm Migration:** Core realm and Retail App OIDC client defined in HCL.
- [x] **Client Definition:** SAML `teller-portal` resource defined with automated TLS generation.
- [x] **Environment Parity:** Managed via branch-based logic in GitHub Actions.
- [x] **Scenario - Risk Scope:** New `risk` scope defined as an HCL resource.


## 3. CI/CD Pipeline (GitHub Actions) - COMPLETED
- [x] **Workflow Creation:** Integrated Project 3 plan/apply jobs into `.github/workflows/cd.yaml`.
- [x] **Pull Request Job:** Integrated `terraform-plan` job into the workflow.
- [x] **DEV Deployment:** Automate release creation via Cloud Deploy upon merging.
- [x] **Security Gate:** Implemented SAST scanning in the pipeline.

## 4. Release Safety & Validation - PENDING
- [ ] **Live Pipeline Execution & Verification:** Execute CD workflow or Cloud Build submit to verify identity apply against live Cloud Run.
- [ ] **Automated Smoke Test:** Implement `smoke-test-identity` step in GHA to fetch OIDC token via `retail-app` client.
- [ ] **Drift Detection:** Configure a scheduled job to detect manual changes made in the Keycloak UI that aren't in Git.
- [ ] **Rollback & Breaking Change Procedure:** Document and test the `git revert` flow and simulate a breaking change.
- [ ] **Phased Environment Promotion:** Promote and verify changes across `DEV`, `TEST`, and `PROD` realms.

## 5. Development Plan Status
Based on `BNKprojects/3/PROJECT3_DETAILS.md`, the following steps track the final release:

1. [x] **Separate Identity Deployment from Configuration:** Implemented two-stage pipeline with local authenticated proxy.
2. [x] **Create GitHub Actions workflow (`.github/workflows/cd.yaml`) & Cloud Build config (`cloudbuild-keycloak.yaml`).**
3. [ ] **Verify live execution via proxy in DEV environment.**
4. [ ] **Simulate a "breaking change" and fix it via pipeline.**

---
**Note:** This checklist is maintained by AI and Human review. Project 3 is currently in the IMPLEMENTATION phase.
**Classification: INTERNAL**

