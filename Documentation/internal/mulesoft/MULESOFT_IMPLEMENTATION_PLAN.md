+++
title = "MuleSoft Implementation Plan"
domain = "mulesoft"
topics = ["implementation-plan", "mulesoft", "integration", "architecture", "banking", "runtime-fabric"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "MULESOFT_LEARNING_PATH.md",
    "CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md",
    "../../../BNKprojects/7/README.md",
    "../../../BNKprojects/7/SECURITY.md",
    "../../../BNKprojects/7/PROJECT7_DETAILS.md",
    "../Architecture.md",
    "../SECURITY.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/README.md)  
> **Implementation Project**: [`BNKprojects/7/README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Security Policy**: [`BNKprojects/7/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)  
> **Comparative Guide**: [`CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md)

---

# MuleSoft Implementation Plan

## 1. Architecture Decision

MuleSoft is implemented as **Project 7: MuleSoft Integration Layer** under `BNKprojects/7/`.

It is not merged into Project 0 foundation infrastructure because MuleSoft owns integration behavior: API facades, mediation, transformations, routing, partner ingress, SaaS connectors, and API policy enforcement. Project 0 remains responsible for shared cloud infrastructure (networking, IAM, GKE, Secret Manager) that MuleSoft depends on.

## 2. Responsibility Split

| Responsibility | Owner |
| :--- | :--- |
| GCP APIs, VPC, Cloud NAT, Secret Manager, Artifact Registry, WIF, GKE cluster provisioning, IAM | Project 0 / Terraform |
| MuleSoft organization setup, environments, API Manager policies, Exchange assets | Project 7 / MuleSoft admin process |
| Mule app source, API specs, DataWeave mappings, MUnit tests | Project 7 |
| GitOps continuous delivery & drift detection | Project 6 (ArgoCD) |
| Cloud Run app deployments (stateless microservices) | Existing Cloud Deploy pipeline |
| Kafka and Pub/Sub event backbone | Project 5 |
| Identity provider and token issuance | Project 1 / Keycloak |

## 3. Deployment Target Decision (Decided 2026-08-26)

| Option | Evaluation | Decision Status |
| :--- | :--- | :--- |
| **Runtime Fabric on GKE** | Strongest control over network locality, private VPC ingress, data sovereignty, and Kubernetes GitOps alignment (Project 6). | ✅ **Selected for Production** |
| **CloudHub 2.0 / Sandbox** | Fastest managed MuleSoft start for initial Phase 1 proof of concept; requires evaluation/trial accounts. | ⏳ **Selected for POC** |
| **CloudHub 1.0** | Legacy model; not recommended. | ❌ Deprecated |
| **Hybrid Standalone** | Only for legacy/on-premise servers. | ⏳ Optional |

See the detailed comparative guide: [`CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md).

## 4. Bank Integration Patterns

### Pattern A: System API Facade for Project 2
Expose a MuleSoft-managed API facade that calls the core banking transaction service.
1. Client calls MuleSoft API endpoint with Keycloak bearer token.
2. MuleSoft validates token and applies rate limiting policies.
3. MuleSoft transforms request into Project 2 service contract via DataWeave.
4. Project 2 processes request and writes audit records to MongoDB.
5. MuleSoft normalizes response and emits PII-safe operational logs with correlation IDs.

### Pattern B: Identity-Aware API Policy with Project 1
Use Keycloak as the centralized identity provider and enforce OAuth 2.0 / OIDC claims validation in MuleSoft API Manager.

### Pattern C: Partner Event Ingress to Project 5
Use MuleSoft as a controlled partner-facing ingestion layer:
1. Partner posts transaction, KYC, or fraud event over TLS 1.2+ with mTLS / API key.
2. MuleSoft validates schema against canonical event definitions.
3. MuleSoft transforms payload to canonical format.
4. MuleSoft publishes to Kafka or Pub/Sub event backbone.
5. Downstream consumers (e.g., Actimize) process events from Project 5.

### Pattern D: Actimize Integration for Project 4
Mediate vendor APIs and webhooks for Actimize AML / Fraud alerts once event schemas are stable.

## 5. Security Guardrails

1. **Zero Unauthenticated Access**: No public unauthenticated access to internal banking services (`allUsers` strictly forbidden).
2. **No Secrets in Repositories**: All secrets managed via GCP Secret Manager and injected at runtime.
3. **Environment Isolation**: Separate configurations for DEV, TEST, and PROD.
4. **PII Sanitization**: Mandatory DataWeave log masking for PAN card numbers, SSNs, and credentials.
5. **Least Privilege**: Scoped Anypoint roles and GCP service accounts.

## 6. Implementation Phases

- **Phase 0 - Learning and Access**: Onboarding, Anypoint access, Runtime Fabric decision finalized.
- **Phase 1 - Non-Sensitive POC**: Health API specification (`bank-integration-health-api`), local Mule flow, MUnit tests.
- **Phase 2 - Identity and Policy Prototype**: Keycloak token validation, API Manager policy chains.
- **Phase 3 - Project 2 Facade**: Transaction service mediation and response normalization.
- **Phase 4 - Event Ingress Prototype**: Partner event validation and Kafka/PubSub publishing.
- **Phase 5 - Production Hardening**: CI/CD automation, ArgoCD GitOps sync, security audit, monitoring dashboards.

## 7. First Deliverable (Phase 1 POC)

Create `bank-integration-health-api` proof of concept with no sensitive backend dependencies.

Acceptance criteria:
1. API spec committed under `BNKprojects/7/src/main/mule/api-specs/`.
2. Mule app source committed under `BNKprojects/7/src/main/mule/`.
3. MUnit test suite passes with >= 80% coverage.
4. Local secrets remain excluded via `.gitignore` and `.dockerignore`.
5. No production credentials or real customer data used.
