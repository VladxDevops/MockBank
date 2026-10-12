# Documentation Update: Keycloak Provider 403 Forbidden Error (July 3, 2026)

## Status: UNRESOLVED

The Keycloak provider 403 Forbidden error when running `terraform plan -target=module.project3` locally is an **architectural constraint**, not a bug. This error occurs because the Keycloak Cloud Run service is intentionally private (secure-by-default) and rejects unauthenticated Terraform provider initialization requests.

## Files Updated

### 1. ERROR_403_EXPLANATION.md
**New Section Added:** "Known Unsolved Issue: Persistent 403 Forbidden in Local Development"

**Purpose:** Explains why this error cannot be "fixed" and documents the required workaround.

**Key Points:**
- The 403 error is correct security behavior (private Cloud Run service, no public ingress).
- Workaround is required **every time** terraform plan/apply targets Keycloak provider resources locally.
- CI/CD workflows handle this automatically; local developers must manually start the proxy.
- Provides commands and debugging checklist.

**Location:** [ERROR_403_EXPLANATION.md](./ERROR_403_EXPLANATION.md#known-unsolved-issue-persistent-403-forbidden-in-local-development)

---

### 2. internalREADME.md (Project 3 Section)
**New Subsection Added:** "#REQUIRED: Local Terraform + Keycloak Provider (403 Forbidden Workaround)"

**Purpose:** Provides the exact step-by-step command sequence developers must follow every time they run terraform locally.

**Key Commands:**
```bash
# Step 1: Terminal 1 (Background)
gcloud run services proxy keycloak-service --region us-south1 --port 8080 &

# Step 2: Terminal 2 (Foreground)
export GOOGLE_APPLICATION_CREDENTIALS="..." && \
terraform plan \
  -var-file="dev.tfvars" \
  -var="keycloak_url=http://127.0.0.1:8080" \
  -var="bootstrap=false" \
  -target=module.project3
```

**Location:** [internalREADME.md Line 213+](./internalREADME.md#required-local-terraform--keycloak-provider-403-forbidden-workaround)

---

### 3. BNKprojects/1/TROUBLESHOOTING_SCRIPTS.md
**New Section Added:** "Section 13: Terraform Provider 403 Forbidden Error (Keycloak Service Unreachable)"

**Purpose:** Documents the error symptom, root cause, and workaround specific to test/troubleshooting context.

**Includes:**
- Symptom and root cause explanation
- Step-by-step workaround with exact commands
- Key parameters documentation
- Why CI/CD doesn't require the workaround
- Debugging checklist

**Location:** [TROUBLESHOOTING_SCRIPTS.md (Section 13)](./BNKprojects/1/TROUBLESHOOTING_SCRIPTS.md#13-terraform-provider-403-forbidden-error-keycloak-service-unreachable)

---

## Workaround Summary

**Every Local Terraform Run Against Keycloak Provider Requires:**

1. **Proxy Tunnel (Terminal 1):**
   ```bash
   gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
   ```

2. **Terraform With Local URL (Terminal 2):**
   ```bash
   terraform plan/apply \
     -var-file="dev.tfvars" \
     -var="keycloak_url=http://127.0.0.1:8080" \
     -var="bootstrap=false" \
     -target=module.project3
   ```

**CI/CD Behavior:** GitHub Actions workflow (`cd.yaml`) handles the proxy automatically in the `configure-identity` job.

---

## Root Cause (Not Fixable)

- Keycloak Cloud Run service is **intentionally private** (Zero Trust architecture).
- The mrparkers/keycloak Terraform provider initializes immediately and requires authentication.
- Without the local proxy, the provider attempts unauthenticated POST to the public URL.
- Cloud Run rejects unauthenticated requests with `403 Forbidden` (correct security behavior).
- Cannot be fixed without compromising security (making service public = bad).

---

## Documentation Cross-References

- [ERROR_403_EXPLANATION.md](./ERROR_403_EXPLANATION.md) - Comprehensive technical explanation
- [internalREADME.md](./internalREADME.md) - Developer setup instructions (Project 3 section)
- [TROUBLESHOOTING_SCRIPTS.md](./BNKprojects/1/TROUBLESHOOTING_SCRIPTS.md) - Test/troubleshooting context
- [Keycloak Troubleshooting Guide](./BNKprojects/1/container/TROUBLESHOOTING/TROUBLESHOOTING.md) - Scenario P: 403 Forbidden from Terraform
- [GitHub Actions Workflow](../.github/workflows/cd.yaml) - Reference implementation (configure-identity job)

---

## Verification

Error reproduced on July 3, 2026:
```
terraform plan -var-file="dev.tfvars" -target=module.project3

Error: error initializing keycloak provider
failed to perform initial login to Keycloak: error sending POST request to
https://keycloak-service-REMOVED-GCP-PROJECT-NUMBER.us-south1.run.app/realms/master/protocol/openid-connect/token: 403 Forbidden
```

**Status:** Error is persistent and expected. Workaround is required and working in CI/CD.

---

## Documenting Cloud Build keycloak configuration (July 9, 2026)

We have updated the [cloudbuild-keycloak.yaml](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/1/container/cloudbuild-keycloak.yaml) file to handle the authentication and wait sequence without building any Docker container. It initiates an authenticated proxy to private Cloud Run, loops until healthy (UP), and then triggers Terraform configuration for `module.project3`.

Related documentation files updated:
- [CHANGELOG.md](file: /Bank/CHANGELOG.md) — Added entry for `0.8.6` mapping the new Cloud Build setup.
- [internalREADME.md](file: /Bank/internalREADME.md) — Added instructions and execution command.
- [TROUBLESHOOTING_SCRIPTS.md](file: /Bank/BNKprojects/1/TROUBLESHOOTING_SCRIPTS.md) — Appended Section 15 detailing the workflow behavior.
- [IdentityConfig_TS.md](file: /Bank/terraform/modules/project3/IdentityConfig_TS.md) — Appended the Cloud Build method and behavior.


