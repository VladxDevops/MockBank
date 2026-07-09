(The file `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/terraform/modules/project3/Identity Config_TS.md` exists, but is empty)
## Identity Config — Troubleshooting & Technical Support (TS)

Purpose
- Provide actionable diagnostics, debugging steps, and fixes for failures observed during the Identity configuration stage of Project 3 (CI/CD). This focuses on errors surfaced by GitHub Actions workflows (`.github/workflows/cd.yaml`), Terraform runs that configure Keycloak (project1/project3 flows), and local Keycloak container issues used for testing.

Quick summary of sources reviewed
- `.github/workflows/cd.yaml` and `.github/workflows/ci.yaml` (pipeline steps, auth expectations, proxy+terraform sequence)
- `README.md` (WIF, required GitHub secrets and variables, runbook commands)
- `BNKprojects/1/container/TROUBLESHOOTING/localTSkeycloakContainer.md` (local Keycloak container diagnostics)

Common symptoms and probable causes
- Symptom: `Google Auth` step in workflow fails early with authentication/permission errors.
	- Likely causes: incorrect `WIF_PROVIDER` value, `WIF_SERVICE_ACCOUNT` not matching created SA, missing Workload Identity binding (service account not allowed to be impersonated by provider), or missing `id-token` permission in workflow.

- Symptom: Workflow logs show `Error: Failed to create dev.tfvars from secrets.`
	- Likely causes: `TFVARS_DEV` secret missing or incorrectly formatted; GitHub secrets not set for the environment (DEV); workflow cannot read repository/organization secrets.

- Symptom: `terraform init` fails to find or access the backend; errors about buckets or permissions.
	- Likely causes: incorrect backend bucket name, insufficient SA permissions, or network egress rules blocking access to GCS.

- Symptom: `Start GCloud Proxy` step times out or health check against `http://127.0.0.1:8080/health/live` fails (timeout, 404, connection refused).
	- Likely causes: Keycloak image was built without health extension (`KC_HEALTH_ENABLED=false`), proxy command failed due to Cloud SDK missing components, port conflict in the runner, or Keycloak taking longer than expected to initialize.

- Symptom: Terraform apply (Identity) fails with Keycloak API errors (401/403/invalid redirect_uri/realm import failures).
	- Likely causes: wrong `TF_VAR_keycloak_url`, missing explicit `bootstrap=false`, health endpoint not ready, or Keycloak admin credentials mismatched (`KEYCLOAK_ADMIN_PASSWORD` secret incorrect).
	- **Special Case: 403 Forbidden from the Public Cloud Run URL (e.g., `https://keycloak-service-*.us-south1.run.app`):** 
		- This occurs when `terraform plan -target=module.project3` runs against the public Keycloak Cloud Run URL instead of the local proxy.
		- The Keycloak Cloud Run service is intentionally **private** (no public ingress).
		- The error `failed to perform initial login to Keycloak: error sending POST request to https://keycloak-service-*.us-south1.run.app/realms/master/protocol/openid-connect/token: 403 Forbidden` means the caller (Terraform identity) lacks `roles/run.invoker` permission on the Cloud Run service.
		- **Root Cause:** In CI/CD (GitHub Actions), the `configure-identity` job must use `TF_VAR_keycloak_url=http://127.0.0.1:8080` (the local Cloud Run proxy) instead of the public URL. For local development runs, either (a) use `gcloud run services proxy` to create a local proxy and pass the local URL, or (b) grant `roles/run.invoker` on the Keycloak Cloud Run service to your authenticated identity.
		- **Terraform IAM Fix:** Ensure `terraform/modules/project1/main.tf` contains a `google_cloud_run_service_iam_member` resource that grants `roles/run.invoker` only to authenticated principals (e.g., `serviceAccount:${var.terraform_deployer_service_account}`), NOT `allUsers`. Example:
			```hcl
			resource "google_cloud_run_service_iam_member" "keycloak_invoker" {
			  project  = var.compute_project_id
			  location = google_cloud_run_service.keycloak.location
			  service  = google_cloud_run_service.keycloak.name
			  role     = "roles/run.invoker"
			  member   = "serviceAccount:${var.terraform_deployer_service_account}"
			}
			```
		- **CI/CD Verification:** After `terraform apply -target=module.project1` succeeds, verify the IAM binding was created:
			```bash
			gcloud run services get-iam-policy keycloak-service --region us-south1 --format=json | grep roles/run.invoker
			```
		- **Local Development:** To reproduce locally, run:
			```bash
			gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
			terraform plan -var-file="dev.tfvars" \
			  -var="keycloak_url=http://127.0.0.1:8080" \
			  -var="bootstrap=false" \
			  -target=module.project3
			```
		- **Workflow Sequence:** The GitHub Actions workflow must enforce that `configure-identity` (which tests Keycloak provider connectivity) only runs **after** `deploy-identity` (which applies the Cloud Run service and IAM bindings) completes successfully. The current job dependency chain in `.github/workflows/cd.yaml` should reflect: `terraform-apply` → `deploy-identity` → `configure-identity`.

-- Symptom: Cloud Run proxy or service errors (connection refused, 404 on `/health/live`, or logs showing startup failures).
	- Likely causes: Cloud Run service not deployed or in wrong project/region, deployed image missing health extension (`KC_HEALTH_ENABLED=false`), incorrect `TF_VAR_keycloak_url`, service ingress/permissions preventing proxy access, or Keycloak startup errors (DB connectivity, realm import failures).

Diagnostic checklist (quick to run)
- Verify GitHub secrets and variables for the `DEV` environment via `gh` CLI (runs locally):

	gh repo view --json nameWithOwner
	gh secret list --env DEV
	gh secret get WIF_PROVIDER --env DEV

- Validate Workload Identity Provider and Service Account in GCP:

	gcloud iam workload-identity-pools list --location=global
	gcloud iam workload-identity-pools providers list --location=global --workload-identity-pool="YOUR_POOL_NAME" --format="value(name)"
	gcloud iam service-accounts list --filter="name:github-actions" --format="value(email)"

- Confirm the WIF binding (service account trust) is present:

	# Replace PROJECT_NUMBER, POOL, PROVIDER, and SA_EMAIL appropriately
	gcloud iam service-accounts get-iam-policy github-actions-sa@PROJECT_ID.iam.gserviceaccount.com

	# IAM binding needed (example principal):
	# principal://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL/providers/PROVIDER

- Check workflow-level permissions in the run logs: ensure `id-token: write` is present and `google-github-actions/auth@v2` step output shows a successful token exchange.

- Inspect `dev.tfvars` materialization in workflow logs: confirm the heredoc contains expected variables and no shell quoting issues.

- Validate Keycloak health endpoint via proxy (used in `cd.yaml`):

	# On the runner (workflow) the job does this; replicate locally when debugging:
	gcloud run services proxy keycloak-service --region us-south1 --port 8080 --quiet &
	curl -i http://127.0.0.1:8080/health/live

	# Expect: HTTP/1.1 200 and body containing UP (or Keycloak health JSON)

Detailed troubleshooting & fixes
1) GitHub Actions -- `google-github-actions/auth@v2` failures
- Diagnose:
	- Inspect the exact workflow log for the `Google Auth` step. Look for messages like `unable to exchange token` or `invalid provider`.
	- Verify the secret `WIF_PROVIDER` exactly matches the provider resource name in GCP. It must be the full resource name used by the workflow.

- Common fix:
	- Ensure the Workload Identity Pool and Provider exist and haven't been deleted/renamed.
		gcloud iam workload-identity-pools list --location=global
	- Confirm the service account email exists and has the correct IAM binding allowing the provider to impersonate:
		gcloud iam service-accounts get-iam-policy github-actions-sa@PROJECT_ID.iam.gserviceaccount.com
	- If missing, add the binding:

		gcloud iam service-accounts add-iam-policy-binding github-actions-sa@PROJECT_ID.iam.gserviceaccount.com \
			--role roles/iam.workloadIdentityUser \
			--member "principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL/providers/PROVIDER"

2) Missing or malformed `TFVARS_DEV` secret
- Diagnose:
	- In the workflow logs, `cat <<'EOF' > dev.tfvars` followed by `if [ ! -f "dev.tfvars" ]; then` indicates the secret is read. If it fails, it means the heredoc evaluated empty or had quoting issues.
	- Locally, test the secret content by printing (careful: do not share secrets):

		gh secret get TFVARS_DEV --env DEV

- Fix:
	- Recreate the secret in the GitHub repo with the exact content expected by Terraform (HCL variables). Use `gh secret set TFVARS_DEV --env DEV --body "$(cat dev.tfvars.example)"`.
	- Ensure there are no surrounding extra quotes that might be preserved by the heredoc.

3) Terraform backend / init problems
- Diagnose:
	- Workflow logs will show `Error: Error checking for existing state` or `403 Forbidden`.
	- Confirm the `terraform init` backend-config bucket exists and the service account has `roles/storage.objectAdmin` or appropriate roles.

- Fix:
	- Verify the workflow's SA and WIF-mapped identity have the required GCS permissions.
	- Ensure the bucket name in the workflow (`terraform_state_bckup_bnk-project`) matches the real bucket; if changed, update the workflow or create the expected bucket.

4) Keycloak Proxy & Health check failures (most frequent in `configure-identity`)
- Diagnose:
	- Look at the `Start GCloud Proxy` step logs. If curl returns `000` or `CONN_FAILED`, proxy didn't bind or Keycloak failed to start.
	- If curl returns 404 for `/health/live`, Keycloak's health extension may be disabled.

- Fixes & checks:
	- Ensure Keycloak image includes the health extension: `KC_HEALTH_ENABLED=true` at build time.
	- Verify `gcloud components install cloud-run-proxy` completes successfully in the workflow environment.
	- If port 8080 is used by another process in the runner environment, change the proxy `--port` to an available port and update `TF_VAR_keycloak_url` accordingly.
	- Increase the wait loop timeout in the workflow if Keycloak takes longer than 120s to initialize.

5) Keycloak API / Terraform apply errors (401/403/invalid params)
- Diagnose:
	- Inspect terraform plan/apply output for API response codes and error bodies.
	- Validate `TF_VAR_keycloak_url` passed to terraform matches the actual base URL served by the proxy (e.g., `http://127.0.0.1:8080`).

- Fix:
	- Confirm `KEYCLOAK_ADMIN_PASSWORD` secret matches the admin password the image expects. When using an exported realm baked into the image, confirm the admin user exists and password set.
	- Retry steps after the proxy health check returns `200`.

6) Cloud Run Keycloak issues (primary)
- Use these Cloud Run checks when the Keycloak instance is deployed to Cloud Run (the `configure-identity` job proxies the service into the runner):
	- Confirm the service exists and is in the expected project/region:

		gcloud run services describe keycloak-service --region us-south1 --project ${DEV_GCP_PROJECT_ID} --format="value(status.url)"

	- Verify the deployed image includes health endpoints (`KC_HEALTH_ENABLED=true`) and the revision has completed startup:

		# List revisions and latest status
		gcloud run revisions list --service keycloak-service --region us-south1 --project ${DEV_GCP_PROJECT_ID}

	- Read recent service logs to find startup or realm-import errors:

		gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=keycloak-service" --project=${DEV_GCP_PROJECT_ID} --limit=50 --format="json"

	- Confirm the proxy command targets the correct service name, region, and project in the workflow step:

		gcloud run services proxy keycloak-service --region us-south1 --project ${DEV_GCP_PROJECT_ID} --port 8080 --quiet &

	- If the proxy health check returns 404, ensure the image was built with the Keycloak health extension and the running revision is using that image (check the `image` field on the revision).

	- If the proxy returns connection refused, confirm the service has accessible ingress for the proxy (proxy uses Cloud Run API to forward; verify IAM and service existence) and that `gcloud` in the runner is configured to the same project as the service.

+- Networking & IAM notes:
	- If the service is deployed as internal-only or uses VPC egress with serverless VPC connectors, ensure the proxy approach is allowed and the runner's `gcloud` can reach the service via the Cloud Run admin API.
	- Ensure the workflow's WIF-mapped identity has `roles/run.viewer` (or appropriate) on the service for proxying and `roles/iam.serviceAccountUser` if the service account needs to be impersonated.

+- Common Cloud Run fixes:
	- Redeploy the Keycloak image with `KC_HEALTH_ENABLED=true` and tag the revision used by Terraform.
	- Verify `KEYCLOAK_ADMIN_PASSWORD` in Secret Manager or GitHub secret matches what Terraform expects for admin operations.
	- If the service is in a different project, update `DEV_GCP_PROJECT_ID` in GitHub Variables/Secrets and the workflow steps.

+- Local development note:
	- For purely local development, `BNKprojects/1/container/TROUBLESHOOTING/localTSkeycloakContainer.md` is still useful. For CI/CD runs the Cloud Run checks above are primary.

Checklist to validate before re-running workflow (ordered)
1. GitHub: `WIF_PROVIDER`, `WIF_SERVICE_ACCOUNT`, `TFVARS_DEV`, `DEV_GCP_PROJECT_ID`, `PROJECT1_REPOSITORY`, `ARTIFACT_REGISTRY_REPOSITORY_ID`, `KEYCLOAK_ADMIN_PASSWORD` exist and are correct for the `DEV` environment.
2. GCP: Workload Identity Pool & Provider exist; `github-actions-sa` service account exists and has IAM binding to allow pool impersonation.
3. GCP: Service account has required roles: `roles/storage.objectAdmin` (or narrower), `roles/cloudbuild.builds.builder` (if using Cloud Build), and Terraform-related roles required by the modules.
4. Terraform backend bucket exists and is reachable from the runner/service account.
5. Keycloak image used by the workflow contains health endpoint (build step sets `KC_HEALTH_ENABLED=true`) and admin credentials align with `KEYCLOAK_ADMIN_PASSWORD`.
6. Confirm `gcloud` components invoked in the workflow are available (`cloud-run-proxy`, etc.).

Where to look in logs (helpful pointers)
- `Google Auth` step: look for token exchange success and the generated `access_token` or `id_token` lines in the auth action output.
- `Terraform Init` step: look for backend init success and workspace selection logs.
- `Start GCloud Proxy`: the health check loop prints status codes; copy the last curl verbose output included in the logs when the step fails.
- `Terraform Plan/Apply`: full tfplan or API error messages are emitted; copy-paste the API response body when filing issues.

Example quick fixes (commands)
- Add workload-identity binding (example):

	gcloud iam service-accounts add-iam-policy-binding github-actions-sa@PROJECT_ID.iam.gserviceaccount.com \
		--role roles/iam.workloadIdentityUser \
		--member "principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/GITHUB_POOL/providers/GITHUB_PROVIDER"

- Recreate `TFVARS_DEV` using `gh` CLI (locally):

	gh secret set TFVARS_DEV --env DEV --body "$(cat terraform/dev.tfvars.example)"

### Keycloak Identity Configuration via Cloud Build

If local execution encounters authentication or networking errors, you can run the bootstrap process securely within the GCP environment using Cloud Build. This runs `terraform apply -target=module.project3` through an authenticated proxy and does not build any container.

**Execution Command:**
```bash
gcloud builds submit --config=BNKprojects/1/container/cloudbuild-keycloak.yaml \
  --substitutions=_SERVICE_NAME="keycloak-service",_REGION="us-south1",_STATE_BUCKET="terraform_state_bckup_bnk-project",_TERRAFORM_VERSION="1.5.7" \
  .
```

**What it does:**
1. Spins up a temporary Google Cloud SDK container.
2. Installs system dependencies and the specified Terraform CLI version.
3. Authenticates to Cloud Run, spawning `gcloud run services proxy`.
4. Polls `/health/live` on port `8080` until HTTP 200 containing `"UP"` is returned.
5. Performs `terraform init` and applies `module.project3` targeting the local proxy URL.
6. Terminates and cleans up the proxy process upon completion/error.

Next steps (recommended)
- I will populate this file in the repo (done). If you'd like, I can also:
	- Add a short shell script `scripts/validate-wif.sh` to run the WIF & SA checks, or
	- Add example `dev.tfvars.example` and a GitHub Actions step that verifies `dev.tfvars` before `terraform init`.


Created: 2026-07-02 — Consolidated from repository README, workflow definitions, and Keycloak troubleshooting notes.
Updated: 2026-07-09 — Appended Google Cloud Build method.


