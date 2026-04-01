# Project 1: Keycloak Identity Service Checklist

## 1. Infrastructure Provisioning (Terraform) - COMPLETED
- [x] **Cloud SQL Setup:** Provisioned PostgreSQL 15 with Private IP only (Zero-trust).
- [x] **VPC Integration:** Serverless VPC Access Connector deployed with `egress = "all-traffic"`.
- [x] **Networking:** Cloud NAT gateway active for external OIDC provider reachability.
- [x] **IAM Least Privilege:** `keycloak-sa` created with `cloudsql.client`, `secretmanager.secretAccessor`, and `artifactregistry.reader`.
- [x] **Secret Management:** DB and Admin passwords mapped from Secret Manager to Cloud Run environment variables.

## 2. Containerization & Optimization - COMPLETED
- [x] **Dockerfile Hardening:** Image runs as non-root (`USER keycloak`).
- [x] **Build Optimization:** `kc.sh build` used to pre-configure Quarkus runtime.
- [x] **Health Checks:** `KC_HEALTH_ENABLED=true` set during build to expose `/health/live`.
- [x] **Performance:** "Startup CPU Boost" enabled in Cloud Run.
- [x] **Probes:** `startup_probe` configured with 60s initial delay and 20 failure threshold.

## 3. Protocol & Realm Configuration - IN PROGRESS
- [x] **Realm Creation:** `AltmtrkBank` realm initialized (verified in `CHANGELOG [1.5.6]`).
- [ ] **OIDC Configuration (Retail App):** 
    - [ ] Finalize `retail-app` client settings.
    - [ ] Enable Authorization Code Flow with PKCE.
    - [ ] Set Access Token lifespan < 15 mins.
- [ ] **SAML 2.0 Configuration (Teller Portal):**
    - [ ] Finalize `teller-portal` client settings.
    - [ ] Ensure signed and encrypted assertions.
- [ ] **MFA Enforcement:** Mandatory TOTP for all users in `AltmtrkBank`.

## 4. Security & Verification - PARTIALLY COMPLETED
- [x] **Proxy Settings:** `KC_PROXY=edge` configured for TLS termination.
- [x] **Hostname Strictness:** `KC_HOSTNAME_STRICT=false` set for dynamic Cloud Run URLs.
- [x] **Health Verification:** `/health/live` returns `200 OK` (verified in `CHANGELOG [1.6.6]`).
- [ ] **Admin Hardening:** Enable MFA on the Keycloak admin account.
- [ ] **Audit Logging:** Verify no PII is exposed in Cloud Logging.

## 5. Development Plan Status
Based on `PROJECT1_DETAILS.md`, the following steps track the final integration:

1. [x] Write Terraform for GCP Cloud Run + SQL.
2. [x] Deploy Keycloak.
3. [ ] **Create "Retail App" and capture the OIDC Token.**
4. [ ] **Create "Teller App" and capture the SAML Assertion.**

---
**Note:** This checklist is maintained by AI and Human review. Last updated based on Changelog v1.6.6.
**Classification: INTERNAL**
