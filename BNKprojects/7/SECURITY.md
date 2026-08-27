+++
title = "Project 7: MuleSoft Integration Layer Security & Access Control Policy"
domain = "security"
topics = ["mulesoft-security", "oidc", "keycloak", "api-manager", "dataweave", "pii-masking", "zero-trust", "secrets-management"]
difficulty = "advanced"
parent = "README.md"
children = []
related = ["PROJECT7_DETAILS.md", "AGENTS.md", "../../Documentation/internal/SECURITY.md", "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md"]
updated_by = "AI Security Auditor"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Prime Directive**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)  
> **Global Agent Protocols**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)

---

# Project 7: MuleSoft Integration Layer Security & Access Control Policy

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Prime Security Directive

Per the platform's global security policy ([`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)), **Security and Privacy strictly outrank velocity**.

Any configuration, API specification, or integration flow that compromises zero-trust isolation, exposes internal banking endpoints to unauthenticated access (`allUsers`), or hardcodes sensitive credentials into source code, repositories, or container images is strictly prohibited.

---

## 2. Ingress & API Governance

### Prohibition of Unauthenticated Ingress
- MuleSoft-managed APIs and Runtime Fabric ingress **must NEVER** allow unauthenticated public access to internal banking services.
- `allUsers` or `allAuthenticatedUsers` IAM bindings are strictly forbidden on Cloud Run, GKE ingress, or load balancers serving Project 7 workloads.
- Public traffic must be terminated at authenticated API gateways or Anypoint API Manager with mandatory OAuth 2.0 / OIDC policy enforcement.

### API Manager Policy Enforcement
All APIs published through Project 7 must enforce standard Anypoint API Manager policies in the following strict evaluation order:
1. **IP Allow-listing / Ingress Guardrails**: Block unauthorized network ranges.
2. **TLS 1.2+ Enforcement**: Reject unencrypted (HTTP) requests.
3. **Rate Limiting & Spike Control**: Mitigate DoS attacks per client ID / consumer application.
4. **OAuth 2.0 / JWT Token Validation**: Introspect and validate Keycloak-issued tokens before forwarding requests to backend microservices.
5. **Request Payload Validation**: Validate JSON schema and reject malformed or oversized payloads before processing.

---

## 3. Identity Federation & Keycloak Integration (Project 1)

### OIDC Token Validation
- Authentication for API consumers is federated exclusively via **Project 1 (Keycloak)**.
- MuleSoft flows must extract the Bearer JWT token from the `Authorization` header and validate:
  - Token signature and issuer (`iss`).
  - Expiration (`exp`) and not-before (`nbf`) timestamps.
  - Audience claim (`aud`).
  - Required client scopes and user roles.
- Invalid, expired, or missing tokens must immediately return `401 Unauthorized` or `403 Forbidden` without invoking downstream backend services.

---

## 4. Data Protection & Privacy Standards

### PII Sanitization & Masking
- In compliance with PCI-DSS, GDPR, and CCPA, MuleSoft applications must **NEVER** write raw Personally Identifiable Information (PII) or sensitive payment card data to logs, traces, or unencrypted storage.
- DataWeave transformations (`src/main/resources/dataweave/`) must explicitly mask or redact sensitive fields before emitting log entries:
  - Payment Card Numbers (PAN): Mask all except last 4 digits (e.g., `****-****-****-1234`).
  - Social Security Numbers (SSN) / Tax IDs: Redact completely (`[REDACTED]`).
  - Passwords, API Keys, and Secret Tokens: Never log under any circumstance.
- Log aggregation to Google Cloud Logging must enforce log-level filtering (INFO/WARN/ERROR in non-DEV environments).

### Encryption Standards
- **In Transit**: All communication between MuleSoft, API clients, Keycloak, backend services (Project 2), Actimize (Project 4), and Kafka/PubSub (Project 5) must use TLS 1.2 or TLS 1.3 with strong cipher suites.
- **At Rest**: Any state, cache, or dead-letter storage used by MuleSoft must use GCP customer-managed or default Google-managed encryption keys.

---

## 5. Declarative Secrets Management

### Prohibition of Plaintext Secrets
- Plaintext passwords, private keys, client secrets, and Anypoint credentials **must NEVER** be committed to git repositories or baked into Docker images.
- Local property files containing credentials (e.g., `.env.local`, `application-*.properties` with raw passwords) must remain excluded via `.gitignore` and `.dockerignore`.

### Secret Injection Architecture
- **GCP Secret Manager**: All database passwords, Keycloak client secrets, API keys, and TLS keystore passwords reside in GCP Secret Manager.
- **Runtime Injection**: Secrets are injected dynamically at runtime into Runtime Fabric / GKE pods or Cloud Build via Workload Identity Federation (WIF) and Kubernetes External Secrets / service account bindings.

---

## 6. Runtime & Container Security

- **Non-Root Execution**: Containerized Mule applications must execute as the unprivileged `mule` user (UID 1000), never as root.
- **Minimal Base Image**: Use minimal Alpine-based base images (`mulesoft/mule:4.4-java11-alpine`) with pinned version digests.
- **Vulnerability Scanning**: All build artifacts and base images must be scanned with `trivy` in CI/CD before promotion to Artifact Registry. Builds with Critical/High CVEs must fail closed.

---

## 7. AI Retrieval & Governance Guidance

### Why Retrieve This Document?
- To inspect security guardrails, authentication protocols, PII masking rules, and secrets handling for Project 7 (MuleSoft).
- To verify compliance with Level 1 Global Security Policies before creating or modifying Mule applications, DataWeave scripts, or deployment manifests.

### Related Documents
- [Documentation/internal/SECURITY.md](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md) — Platform Prime Directive.
- [BNKprojects/7/PROJECT7_DETAILS.md](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md) — Technical specifications & RACI matrix.
- [BNKprojects/7/AGENTS.md](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/AGENTS.md) — Agent automation rules.
