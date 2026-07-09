# Identity Migration Plan

## Context

The current failure is not a simple Keycloak provider bug. It is caused by the intended secure architecture:

- Keycloak runs on a private Cloud Run service.
- The mrparkers/keycloak Terraform provider must log in to Keycloak during initialization.
- Terraform is currently configured to target the public Cloud Run URL.
- The public URL responds with `403 Forbidden` because the service is private and denies unauthenticated access.

This means the error is expected in the current design, and the actual remediation is architectural: 
change how identity configuration is performed so the provider can reach Keycloak after the service is live and authenticated.

## Proposed Architecture Redesign

### 1. Separate identity deployment from identity configuration

Split the identity workflow into two discrete phases:

1. Deploy Keycloak runtime and supporting infrastructure.
   - Cloud Run service for Keycloak.
   - Cloud Run service account with least privilege.
   - `google_cloud_run_service_iam_member` granting invoker rights to the CI/CD identity.
   - Secrets and database connectivity.

2. Configure Keycloak realm/client settings using Terraform only after Keycloak is confirmed running.
   - Use a local proxy or authenticated Cloud Build execution to access the private Cloud Run service.
   - Pass `keycloak_url=http://127.0.0.1:8080` or equivalent local endpoint to the Keycloak provider.
   - Use `bootstrap=false` after initial runtime deployment.

### 2. Use Cloud Build / CI job to stage the Keycloak bootstrap access

Make Cloud Build the orchestrator for the identity configuration step, with these traits:

- Cloud Build runs in the same GCP project and has permission to proxy or access Cloud Run.
- The build step starts `gcloud run services proxy` against `keycloak-service`.
- The build step validates `/health/live` before running Terraform against Keycloak.
- The build step then executes `terraform apply` for Project 3 identity configuration.

This keeps the Keycloak service private while still allowing automated bootstrapping.

### 3. Preserve a secure private Keycloak posture

Avoid making Keycloak public just to satisfy Terraform. Instead:

- Retain private Cloud Run ingress.
- Grant only the CI/CD and Cloud Build (in this case it is using the compute service account) service accounts `roles/run.invoker` on the Keycloak service.
- Do not use `allUsers` or broad public ingress.
- Use local proxying in CI/CD for Keycloak provider initialization.

### 4. Enforce job ordering in GitHub Actions / Cloud Build

The workflow must enforce a strict ordering:

- `deploy-identity` (deploy Keycloak runtime + IAM binding)
- `configure-identity` (proxy, health-check, Terraform provider init, Keycloak config)

If `configure-identity` runs first, the provider will attempt the public URL and fail with 403.

## Recommended Implementation Steps

1. Add a dedicated Cloud Build job / GitHub Actions job for identity configuration. Status: Pending. 
2. Ensure the identity configuration job receives the runtime service URL only from the proxy, not the public URL. Status: Pending. 
3. Confirm the Keycloak Cloud Run service account has: 
   - `roles/secretmanager.secretAccessor`
   - `roles/cloudsql.client`
   - `roles/artifactregistry.reader`
4. Confirm the CI/CD user/service account is granted `roles/run.invoker` on the Keycloak Cloud Run service. Status: Done. 
5. Add a workflow-level health check to block configuration until `/health/live` responds 200.
6. Document the exact local dev workflow and CI/CD sequence.

## Local Developer Workflow

Since the same 403 occurs in local runs, document this as the required local pattern:

1. Start a Cloud Run proxy:

```bash
gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
```

2. Run Terraform against the proxy:

```bash
terraform plan -var-file="dev.tfvars" \
  -var="keycloak_url=http://127.0.0.1:8080" \
  -var="bootstrap=false" \
  -target=module.project3
```

This must be the documented developer experience for any local Keycloak identity plan/apply.

## Documentation Updates Needed

This migration should be reflected clearly in the repo documentation. At minimum:

- `terraform/modules/project3/DOCUMENTATION_UPDATE_SUMMARY.md`
  - Add the architectural explanation and the new Cloud Build staging approach.
- `terraform/modules/project3/IdentityConfig_TS.md`
  - Add troubleshooting guidance showing that the 403 is expected for public runtime URLs and that proxy/local access is required.
- `BNKprojects/1/TROUBLESHOOTING_SCRIPTS.md`
  - Add Section on `terraform plan`/`terraform apply` 403 from Keycloak provider and the Cloud Build proxy workaround. 
- `README.md`
  - Add a brief callout in the setup section that this error is an architecture constraint and the correct bootstrap path is via proxy/Cloud Build.
- `CHANGELOG.md`
  - Record the architecture change and the fact that the previous 403 issue is now documented as expected behavior, not a bug.

## Conclusion

The `403 Forbidden` from `https://keycloak-service-.../realms/master/protocol/openid-connect/token` is the symptom of the current architecture attempting to initialize the Keycloak provider against a private service.

The fix is to change the identity provisioning architecture so Cloud Build (or GitHub Actions) deploys Keycloak first, then configures it through an authenticated proxy path.

This preserves security and allows automated identity configuration without exposing the Keycloak service publicly.
