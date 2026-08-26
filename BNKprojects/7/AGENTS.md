# AGENTS.md - Project 7 (MuleSoft) Automation & Agent Protocols

Purpose
- Define conventions, automation agents, and safe-by-default rules for building, testing, and deploying MuleSoft artifacts for Project 7.
- Provide CI/CD bot and operator guidance so automation can act consistently with security and compliance requirements.

Principles
- No secrets in repos or build contexts. Agents must use GCP Secret Manager or Anypoint Secrets for runtime secrets.
- Zero unauthenticated ingress: do not create or suggest `allUsers` IAM bindings in automation scripts.
- Keep builds deterministic: use Maven lockfiles, pinned plugin versions, and reproducible build args.
- Avoid baking environment-specific secrets into images; use runtime env vars injected by CI/CD/Terraform.

Agent Roles

- Build Agent (Cloud Build / GitHub Actions)
  - Responsibilities: run `mvn clean package -DskipTests`, run MUnit tests in CI, build Docker image, scan image (Trivy) and push to Artifact Registry.
  - Credentials: uses a short-lived service account with limited scopes (Artifact Registry writer, Secret Manager accessor for build-time secrets if required).
  - Expected behavior: fail fast on test or SCA failures; publish build artifacts with commit-SHA tags; write metadata to build logs and artifact registry.

- Test Agent
  - Responsibilities: run MUnit and integration smoke tests using mocks; post results to CI; optionally create GitHub PR comments with test summaries.
  - Isolation: tests that need external services must be run in an isolated test environment or use mock stubs (local docker-compose or test doubles).

- Deploy Agent (Cloud Build / ArgoCD integration)
  - Responsibilities: promote images to environment-specific repositories, invoke Terraform `apply` for Runtime Fabric / GKE provisioning, or deploy runtime artifacts to Anypoint (when using CloudHub for POC).
  - Permissions: service-account with minimal required permissions and short-lived tokens; interactions with Project 0 must be approved and auditable.
  - Approvals: require manual approval for TEST→PROD promotions.

Agent Safety Checks (must be implemented)
- Secrets scan: block builds when secrets are detected in code or assets (use `detect-secrets` or `git-secrets`).
- CVE scan: fail builds on critical CVEs in base images or dependencies (use `trivy` / Snyk policy).
- Size limits: fail if produced image exceeds configured size threshold (to avoid unexpected cost/latency spikes).
- Policy checks: ensure Cloud Run / GKE deployment specs do not set public invoker (`allUsers`) unless explicitly approved.

Placeholder & Build-Time Practices
- Use placeholder files for runtime-managed configuration in CI (e.g., `realm-export.json`) and document in `AGENTS.md` how to generate them during CI with safe default values. Example:

  - CI step: `echo '{}' > src/main/resources/realm-export.json` (only for build to satisfy COPY). Real secrets injected at runtime.

- Build arguments: prefer `--build-arg` and environment variables for tunables (heap sizes, log level) rather than baking them into images.

CI/CD Examples (High-level)

- Cloud Build (recommended for GCP):
  1. `mvn -U clean package -DskipTests`
  2. `mvn test` (MUnit)
  3. `docker build --build-arg JAVA_MAX_HEAP=${_JAVA_MAX_HEAP} -t ${IMG}:${SHORT_SHA} .`
  4. `trivy image --severity CRITICAL,HIGH ${IMG}:${SHORT_SHA}`
  5. `gcloud auth configure-docker ${REGION}-docker.pkg.dev` then `docker push ${IMG}:${SHORT_SHA}`
  6. Tag/notify and (optionally) invoke Terraform to update Runtime Fabric manifests or ArgoCD to sync.

- GitHub Actions (alternative): mirror the Cloud Build steps but ensure Service Account keys are not stored in plaintext; prefer Workload Identity Federation.

Operational Notes for Runtime Fabric
- Runtime Fabric runs on Kubernetes (GKE) and requires coordination with Project 0 for cluster provisioning, VPC peering, secret storage and node hardening.
- Agents that deploy to Runtime Fabric should produce Kubernetes manifests / Helm charts and integrate with ArgoCD (Project 6) for GitOps-managed deployments.
- Use manifest templating with secrets fetched from Secret Manager at deploy-time, not committed to git.

Onboarding Checklist for Agents
- [ ] Ensure service account for CI has minimal scopes and is auditable
- [ ] Add pipeline step to fetch secrets via Secret Manager (never from repo)
- [ ] Add automated tests for MUnit and basic integration
- [ ] Add CVE and secret scanning to the pipeline
- [ ] Configure build artifact retention and cleanup policies in Artifact Registry

Troubleshooting & Telemetry
- Build agents must emit structured logs and upload artifacts to a known artifact bucket for debugging.
- For failed deployments, the deploy agent should create an incident ticket or open a PR with rollback instructions.

References
- `Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md` — deployment model guidance
- `BNKprojects/7/CONTAINER_STRUCTURE_PLAN.md` — containerization and build details
- `BNKprojects/7/CHECKLIST.md` — implementation checklist and phased plan


Last updated: 2026-08-26
