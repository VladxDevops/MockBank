# Keycloak Provider 403 Forbidden Error - Detailed Explanation

## Error Message

```
Error: error initializing keycloak provider

with provider["registry.terraform.io/mrparkers/keycloak"],
on terraform.tf line 33, in provider "keycloak":
33: provider "keycloak" {

failed to perform initial login to Keycloak: error sending POST request to
https://keycloak-service-799346288567.us-south1.run.app/realms/master/protocol/openid-connect/token: 403 Forbidden
```

## What This Error Means

### Symptom Interpretation

1. **Provider Initialization Failure**: The Terraform `keycloak` provider (mrparkers/keycloak v4.4.0+) is attempting to authenticate to the Keycloak admin API.
2. **Target URL**: The provider is trying to reach `https://keycloak-service-799346288567.us-south1.run.app/realms/master/protocol/openid-connect/token`.
3. **HTTP 403 Response**: Cloud Run rejected the request with `403 Forbidden`, meaning:
   - The request was **authenticated** or reached the service boundary.
   - The **caller lacks authorization** to invoke the Cloud Run service.

### Root Cause Analysis

The Keycloak Cloud Run service is intentionally **private** (secure-by-default):

- **No Public Ingress**: The Cloud Run service does not allow unauthenticated requests.
- **IAM-Based Access Control**: Only principals with `roles/run.invoker` permission can invoke the service.
- **Terraform Provider Constraint**: When the mrparkers/keycloak provider runs `terraform plan`, it tries to initialize a connection to the Keycloak admin API immediately. If the provider is configured with the public HTTPS URL and the caller lacks `roles/run.invoker`, Cloud Run returns `403 Forbidden`.

### Why This Happens in Practice

| Context | Reason |
|---------|--------|
| **Local Development** | Running `terraform plan -target=module.project3` without a local proxy uses the `keycloak_url` from `dev.tfvars` (the public URL in this case). The local identity (your user or service account) lacks `roles/run.invoker` on the Cloud Run service. |
| **GitHub Actions** | If the `configure-identity` job runs with `TF_VAR_keycloak_url=https://keycloak-service-*.us-south1.run.app` (from `dev.tfvars`), the GitHub Actions runner's authenticated identity tries to invoke the private Cloud Run service without `roles/run.invoker` permission. |
| **CI/CD Workflows** | Similar to GitHub Actions—the service account used by CI/CD (e.g., `sa-github-actions`) must have `roles/run.invoker` on the Keycloak Cloud Run service to successfully POST to the token endpoint. |

## Solution

### For CI/CD (GitHub Actions)

The `configure-identity` job must **always use a local proxy** to the Keycloak service, not the public URL:

1. **Proxy Tunnel**: The workflow's `Start GCloud Proxy` step creates `gcloud run services proxy keycloak-service --region us-south1 --port 8080`.
2. **Local URL**: The `Configure Identity (Terraform Apply)` step then overrides the URL:
   ```bash
   -var="keycloak_url=http://127.0.0.1:8080" \
   -var="bootstrap=false"
   ```
3. **Authenticated Connection**: The proxy handles authentication on behalf of the caller (the GitHub Actions runner's identity).
4. **Job Dependencies**: Ensure the workflow sequence is:
   - `build-keycloak` → Builds and pushes the Keycloak image.
   - `deploy-identity` → Applies `module.project1` (Cloud Run service + IAM bindings).
   - `configure-identity` → Uses the proxy to initialize the Keycloak provider and configure realms/clients.

### For Local Development

When running Terraform locally (e.g., during development or debugging):

1. **Create a Local Proxy Tunnel**:
   ```bash
   gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
   ```
   This command requires **authenticated `gcloud` session** and **`roles/run.invoker` on the Cloud Run service** for your logged-in user.

2. **Run Terraform with Local URL**:
   ```bash
   terraform plan \
     -var-file="dev.tfvars" \
     -var="keycloak_url=http://127.0.0.1:8080" \
     -var="bootstrap=false" \
     -target=module.project3
   ```

3. **Critical**: Do **NOT** use the public HTTPS URL from `dev.tfvars` when running `terraform plan/apply` targeting Keycloak provider resources.

### Verify the IAM Binding Is Correct

#### In Terraform Code

Check that `terraform/modules/project1/main.tf` contains:

```hcl
resource "google_cloud_run_service_iam_member" "keycloak_invoker" {
  project  = var.compute_project_id
  location = google_cloud_run_service.keycloak.location
  service  = google_cloud_run_service.keycloak.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.terraform_deployer_service_account}"
}
```

**Critical Requirements**:
- `project = var.compute_project_id` must be explicitly specified.
- `member` must **NOT** be `"allUsers"` (that would be insecure).
- `member` should be a specific service account (e.g., the Terraform deployer or GitHub Actions service account).

#### In GCP

After `terraform apply -target=module.project1`, verify the binding was created:

```bash
gcloud run services get-iam-policy keycloak-service \
  --region us-south1 \
  --format=json | grep -A5 roles/run.invoker
```

**Expected Output**:
```json
"members": [
  "serviceAccount:dev-terraform-deployer-sa-mock@dev-mockbank.iam.gserviceaccount.com"
],
"role": "roles/run.invoker"
```

**Verify No `allUsers` Binding**:
```bash
gcloud run services get-iam-policy keycloak-service \
  --region us-south1 \
  --format=json | grep -i "allUsers"
```

This should return **nothing**. If it returns results, the insecure binding is still in place and must be removed.

## Prevention & Best Practices

1. **Local Proxy for Terraform Provider**:
   - Always use `http://127.0.0.1:XXXX` (local proxy) when the Keycloak Terraform provider needs to authenticate.
   - The public HTTPS URL is only for external clients (browsers, OIDC applications), not Terraform admin operations.

2. **Strict IAM Policy**:
   - Grant `roles/run.invoker` only to specific authenticated principals (e.g., the Terraform deployer service account or GitHub Actions service account).
   - Never use `allUsers` for the Keycloak identity service.

3. **Workflow Orchestration**:
   - In CI/CD, enforce the correct job dependency order so `configure-identity` only runs after `deploy-identity` has successfully applied IAM bindings.
   - This prevents the provider from attempting to authenticate before permissions are in place.

4. **Documentation**:
   - Terraform developers should document that `keycloak_url` in `dev.tfvars` is for **informational/external reference only**, not for direct Terraform provider use during identity configuration.
   - The Terraform provider always expects a local proxy URL in CI/CD and local development.

## Known Unsolved Issue: Persistent 403 Forbidden in Local Development

**Status:** `UNRESOLVED` - This is an architectural constraint, not a bug.

**Problem Definition**: 
When executing `terraform plan -target=module.project3` (or any Keycloak provider operation) **locally without the proxy**, the command fails with:
```
Error: error initializing keycloak provider
failed to perform initial login to Keycloak: error sending POST request to
https://keycloak-service-[PROJECT_ID].us-south1.run.app/realms/master/protocol/openid-connect/token: 403 Forbidden
```

**Why It Cannot Be "Fixed"**:
- The Keycloak Cloud Run service is intentionally **private** (secure-by-default, zero-trust architecture).
- No unauthenticated caller (including Terraform itself) can POST to `/realms/master/protocol/openid-connect/token` on a private Cloud Run service.
- This is **the correct security behavior**; attempting to make the service publicly invokable would weaken the platform's security posture.

**Workaround Required Every Time**:
Users must follow the proxy pattern **every single time** they run `terraform plan/apply` targeting Keycloak provider resources:

1. **Terminal 1 (Background)**: Start the authenticated proxy tunnel:
   ```bash
   gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
   ```

2. **Terminal 2 (Foreground)**: Run Terraform with local proxy URL override:
   ```bash
   cd terraform
   terraform plan \
     -var-file="dev.tfvars" \
     -var="keycloak_url=http://127.0.0.1:8080" \
     -var="bootstrap=false" \
     -target=module.project3
   ```

**Why This Workaround Is Necessary**:
- The proxy tunnel authenticates on behalf of the local caller using the active `gcloud` credentials.
- Cloud Run validates the request against the IAM policy and grants access because the identity has `roles/run.invoker`.
- The Keycloak provider can then successfully POST credentials to the localhost endpoint (which is not subject to Cloud Run's public ingress policies).

**CI/CD Behavior**:
GitHub Actions workflows (`cd.yaml`) handle this automatically because:
1. The GitHub Actions runner authenticates as the configured service account (e.g., `sa-github-actions`).
2. The workflow's `Start GCloud Proxy` step (in `configure-identity` job) creates the tunnel.
3. The `Configure Identity (Terraform Apply)` step uses `-var="keycloak_url=http://127.0.0.1:8080"`.
4. CI/CD users do **not** need to manually start a proxy.

**Do NOT Attempt These "Fixes"**:
- ❌ Make the Keycloak Cloud Run service publicly accessible (`--allow-unauthenticated` flag). This would expose the admin API to the internet.
- ❌ Add `allUsers` to the `roles/run.invoker` IAM binding. This violates the Zero Trust security model.
- ❌ Disable IAM-based access control on Cloud Run. Cloud Run's ingress policy is a core security boundary.
- ❌ Modify the Terraform provider configuration to avoid authentication checks. The mrparkers/keycloak provider always needs credentials; there is no "skip auth" mode for admin operations.

**Documentation & Tracking**:
- This constraint is documented in [Keycloak Troubleshooting Guide](./BNKprojects/1/container/TROUBLESHOOTING/TROUBLESHOOTING.md) (Scenario P).
- Local development setup instructions (with proxy examples) are in [internalREADME.md](./internalREADME.md).
- GitHub Actions setup is in [.github/workflows/cd.yaml](./.github/workflows/cd.yaml).

## Debugging Checklist

- [ ] Is `terraform/modules/project1/main.tf` containing the correct IAM binding (not `allUsers`)?
- [ ] Has `terraform apply -target=module.project1` been run successfully?
- [ ] Is the `configure-identity` job running **after** `deploy-identity` in the workflow?
- [ ] Is the GitHub Actions `Start GCloud Proxy` step outputting `Proxy is successfully tunnelled`?
- [ ] Is the `Configure Identity` step using `-var="keycloak_url=http://127.0.0.1:8080"`?
- [ ] For local development: Did you run `gcloud run services proxy` before `terraform plan`?
- [ ] Is `bootstrap=false` explicitly passed to Terraform to disable bootstrap mode?

## Related Documentation

- [Keycloak Troubleshooting Guide](./BNKprojects/1/container/TROUBLESHOOTING/TROUBLESHOOTING.md) - Scenario P: 403 Forbidden from Terraform Keycloak Provider
- [Identity Config Troubleshooting](./terraform/modules/project3/IdentityConfig_TS.md) - Detailed diagnostics for Project 3 configuration
- [Cloud Run Security Documentation](./Documentation/internal/SECURITY.md) - IAM and ingress policies for Cloud Run services
- [GitHub Actions Workflow](../.github/workflows/cd.yaml) - Reference workflow with correct proxy setup

