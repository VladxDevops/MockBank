+++
title = "Project 7 (MuleSoft Integration Layer) Agent Protocols"
domain = "mulesoft"
topics = ["mulesoft", "integration", "agents", "project7", "runtime-fabric", "api-manager"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["../../Documentation/internal/AGENTS.md", "../../Documentation/internal/SECURITY.md", "PROJECT7_DETAILS.md", "SECURITY.md"]
updated_by = "AI Context Specialist"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Master Agent Protocols**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)  
> **Security Prime Directive**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)  
> **Project Security Policy**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)

---

# AGENTS.md - Project 7 (MuleSoft) Automation & Agent Protocols

Please: 
Read the internal .md files they are guidelines for multiple aspects like architecture, instructions, how tos, security, etc. 
Search if a file already exists before creating a new file to keep the directories organized. 
Document all changes in the CHANGELOG.md. Keep internal and external documentation up to date. 

**CLASSIFICATION: INTERNAL USE ONLY**

This document outlines specific protocols for Automated Agents (CI/CD runners, Monitoring bots, AI Assistants like Gemini, Gemma, Antigravity) interacting with Project 7 (MuleSoft Integration Layer).

---

## 0. Critical Security Constraint & Prime Directive
**SECURITY > PRIVACY > VELOCITY:** All services and APIs in Project 7 must adhere to zero-trust standards.
*   **ZERO UNAUTHENTICATED INGRESS:** Agents must NEVER suggest allowing unauthenticated traffic (`allUsers` / `allAuthenticatedUsers`) on any MuleSoft API endpoint or Cloud Run/GKE ingress.
*   **NO SECRETS IN CODE:** No passwords, keys, Anypoint client credentials, or tokens in git or Docker build contexts. All runtime secrets must be sourced from GCP Secret Manager.
*   **PATH ABSOLUTE ACCURACY:** All file references and diffs must use absolute paths: `/home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/...`
*   **DIFF MODE REQUIREMENT:** Each response providing code/manifest changes must include a unified diff preview with absolute paths.

---

## 1. Agent Roles

### A. Build Agent (Cloud Build / GitHub Actions)
*   **Responsibilities:** Run `mvn clean package -DskipTests`, execute MUnit test suites, build Docker images using parameterized build args, scan images (`trivy`), and push to Artifact Registry.
*   **Credentials:** Short-lived GCP service account via Workload Identity Federation (WIF) with scoped Artifact Registry writer and Secret Manager accessor roles.
*   **Expected Behavior:** Fail fast on test failures or Critical/High CVEs; publish commit-SHA-tagged images.

### B. Test Agent
*   **Responsibilities:** Execute MUnit unit and integration tests using test doubles and mocks (mocking Keycloak token introspection, Project 2 transaction responses, and Kafka publishers).
*   **Isolation:** Tests requiring external dependencies must run in isolated test containers (e.g., local docker-compose stack) with zero production secrets.

### C. Deploy Agent (Cloud Build / ArgoCD)
*   **Responsibilities:** Deploy and sync Kubernetes manifests for Runtime Fabric on GKE, or deploy runtime artifacts to Anypoint Platform (for CloudHub POCs).
*   **Approvals:** Enforce manual approval gates for all TEST → PROD promotions.
*   **Compliance:** Verify deployment specifications do not introduce unauthenticated invoker bindings.

---

## 2. Agent Safety Checks (Mandatory Gates)
*   **Secrets Scan:** Block builds if cleartext secrets are detected in `.properties`, XML flows, or RAML/OAS specs (via `detect-secrets` / `git-secrets`).
*   **CVE Scan:** Fail builds on Critical/High vulnerabilities in base images or Maven dependencies (`trivy`).
*   **Size Limits:** Flag image size spikes (> 1GB).
*   **PII Masking Audit:** Verify DataWeave transformations do not log cleartext card numbers, SSNs, or tokens.

---

## 3. Build-Time & Placeholder Protocols
*   **Placeholder Configs:** If a container requires a build-time configuration file (e.g., `realm-export.json` or stub `application.properties`) that is populated dynamically at runtime, generate a placeholder file during the CI build step (`echo '{}' > ...`) rather than committing sensitive files.
*   **Build Args:** Always parameterize tunables (`JAVA_MAX_HEAP`, `LOG_LEVEL`, `MULE_HTTP_PORT`) via `--build-arg` rather than hardcoding in Dockerfiles.

---

## 4. Operational Notes for Runtime Fabric on GKE
*   **Deployment Target:** Project 7 has selected **Runtime Fabric on GKE** for production deployments (per 2026-08-26 architectural decision) to satisfy private network, compliance, and GitOps requirements.
*   **GitOps Alignment:** Kubernetes manifests and Helm charts for Runtime Fabric workloads integrate with Project 6 (ArgoCD) and Project 0 (GKE provisioning).
*   **Cloud Run Note:** Cloud Run is a serverless platform for stateless HTTP containers and is **not** the runtime host for Runtime Fabric. Use Cloud Run for standard stateless microservices (e.g., Project 2) and GKE for Runtime Fabric.

---

## 5. Troubleshooting Protocols
*   **Container Inspection:** Use discovery before inspecting containers: `sudo docker ps --format "table {{.Names}}\t{{.Status}}"`.
*   **Context Verification:** Request the last 50 lines of logs (`gcloud run services log read` or `kubectl logs`) before proposing failure fixes.
*   **Transcript Ledger:** Record all significant architectural and troubleshooting sessions in `Documentation/internal/transcripts.md` and keep `CHANGELOG.md` updated.

---

## 6. References
*   [`Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md) — Deployment model comparison
*   [`BNKprojects/7/PROJECT7_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md) — Technical specifications
*   [`BNKprojects/7/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md) — Security and access control policy
*   [`BNKprojects/7/CHECKLIST.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CHECKLIST.md) — Phased implementation checklist

*Refer to `../../Documentation/internal/AGENTS.md` for global policies.*
