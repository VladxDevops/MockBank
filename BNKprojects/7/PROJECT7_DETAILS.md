+++
title = "Project 7: MuleSoft Integration Layer - Project Details"
domain = "mulesoft"
topics = ["mulesoft", "integration", "project-details", "architecture", "banking", "runtime-fabric"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "CHECKLIST.md",
    "CONTAINER_STRUCTURE_PLAN.md",
    "SECURITY.md",
    "AGENTS.md",
    "README.md",
    "../../Documentation/internal/Architecture.md",
    "../../Documentation/internal/SECURITY.md",
    "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md",
    "../../Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Security Policy**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)  
> **Checklist**: [`CHECKLIST.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CHECKLIST.md)  
> **Container Plan**: [`CONTAINER_STRUCTURE_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CONTAINER_STRUCTURE_PLAN.md)  
> **Strategic Plan**: [`Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)

---

# Project 7: MuleSoft Integration Layer - Project Details

**Project Status:** Planning / Initial Implementation (Phase 0-1)  
**Start Date:** Q3 2026  
**Expected MVP:** Q4 2026  
**Last Updated:** 2026-08-26  
**Deployment Target:** Runtime Fabric on GKE (Selected for Production; CloudHub trial for POC)

---

## 1. Executive Summary

Project 7 is the MuleSoft Anypoint Platform integration layer for the Altmtrk2026 Bank Platform. It provides:

- **API Facades** — Managed, policy-controlled APIs that wrap backend microservices (Projects 1, 2, 4)
- **API-Level Mediation** — Request/response transformation, validation, and contract normalization
- **Partner Ingress** — Controlled ingestion of external events (transactions, KYC, fraud alerts)
- **Event Bridging** — Transformation and publication to the platform event backbone (Project 5: Kafka / Pub/Sub)
- **Centralized Policies** — Rate limiting, OAuth token validation, CORS, spike control
- **Audit & Compliance** — PII-safe logging, transaction correlation IDs, and compliance records

Project 7 does **not** replace Project 0 foundation infrastructure or Project 5 event backbone; it **augments** them with integration governance.

---

## 2. Business Drivers

### Why MuleSoft?

| Driver | Benefit |
|:---|:---|
| **API Governance** | Centralized policy enforcement (rate limiting, auth, versioning) across all integrations. |
| **Partner Connectivity** | Pre-built connectors for SaaS vendors (e.g., Actimize, payment processors). |
| **Rapid Mediation** | DataWeave transformations reduce custom coding for request/response mapping. |
| **Scalability & Locality** | Runtime Fabric on GKE scales horizontally within the bank's private VPC boundary. |
| **Operational Visibility** | Anypoint monitoring dashboards and OpenTelemetry integration for API metrics and flow diagnostics. |
| **Time-to-Market** | Faster integration delivery vs. building custom middleware. |

### Alignment with Bank Platform Architecture

- **Project 0**: Provides networking, IAM, secrets, and shared infrastructure (MuleSoft depends on this).
- **Project 1**: Keycloak identity provider; MuleSoft validates tokens via introspection and JWT claims.
- **Project 2**: Transaction Service backend; MuleSoft provides API facade, rate limiting, and mediation.
- **Project 4**: Actimize vendor integration; MuleSoft calls via REST/SOAP adapters once event schemas are stable.
- **Project 5**: Event backbone (Kafka / Pub/Sub); MuleSoft publishes events and respects topic schemas.
- **Project 6**: ArgoCD GitOps; Runtime Fabric workloads on GKE are managed declaratively via GitOps sync.

---

## 3. Scope & Ownership

### What Project 7 Owns

✅ **In Scope:**
- Mule application source code (flows, sub-flows, transformations, connectors)
- API specifications (RAML / OpenAPI)
- DataWeave transformation scripts
- MUnit test suites
- Anypoint Platform configuration (policies, environments, Exchange assets)
- Container build artifacts (Dockerfile, docker-compose, .dockerignore)
- CI/CD definitions for Docker image build and push
- API Manager policies, rate limits, and versions
- Documentation and runbooks

❌ **Out of Scope (Owned by Project 0 / Terraform):**
- VPC and network isolation
- Secret Manager secret provisioning and rotation
- Artifact Registry repositories
- GKE cluster and node pool provisioning
- IAM service accounts and role bindings
- DNS records and TLS certificates
- Monitoring infrastructure (Cloud Logging, Cloud Monitoring backends)
- Database provisioning (PostgreSQL, MongoDB)
- Kafka or Pub/Sub topic infrastructure

### Responsibility Matrix

| Task | Owner | Collaborators |
|:---|:---|:---|
| Mule application development | Project 7 | — |
| API specifications | Project 7 | Architecture team |
| DataWeave transformations | Project 7 | Backend team (Projects 1, 2) |
| Keycloak token validation | Project 7 | Project 1 (Keycloak) |
| Transaction API facade | Project 7 | Project 2 (Transaction Service) |
| Event schema and publishing | Project 7 | Project 5 (Event backbone) |
| Docker build & push | Project 7 (CI/CD) | Project 0 (Artifact Registry) |
| GKE Runtime Fabric deployment | Project 6 (ArgoCD) / Project 0 | Project 7 (provides manifests) |
| Health checks / probes | Project 7 | Project 0 (Terraform) |
| Monitoring dashboards | Project 7 + Project 0 | — |
| On-call support | Project 7 | Project 0 (infrastructure) |

---

## 4. Architectural Decisions

### 4.1 Deployment Target (Decided 2026-08-26)

| Option | Decision Status | Rationale |
|:---|:---|:---|
| **Runtime Fabric on GKE** | ✅ Selected for Production | Chosen for Project 7 to meet private-network, compliance, data sovereignty, and GitOps requirements. Aligns with Project 6 (ArgoCD) and Project 0 (GKE provisioning). |
| **CloudHub 2.0 / Sandbox** | ⏳ Available for POC | Fast managed service for Phase 1 proof-of-concept; evaluation accounts used for short-term testing. Note: CloudHub has no perpetual free production tier. |
| **CloudHub 1.0** | ⏳ Legacy | Not recommended for new workloads. |
| **Hybrid Standalone** | ⏳ Optional | Only for legacy/on-premise constraints. |

**Owner:** MuleSoft Admin + Architecture Team  
**Decision:** Runtime Fabric selected for Project 7 Production  
**Decision Date:** 2026-08-26  
**Reference:** [`Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md)

**Notes on Cloud Run compatibility:** Runtime Fabric is a Kubernetes-hosted Mule runtime (GKE, on-prem). It does *not* run on GCP Cloud Run. Cloud Run is a serverless container platform optimized for stateless HTTP microservices and does not provide the underlying long-running process and OS-level controls that Mule's Runtime Fabric requires. Mule runtime is deployed to GKE (Runtime Fabric), while Cloud Run is reserved for other stateless backend microservices (e.g., Project 2 Transaction Service).

### 4.2 Event Backbone Strategy

| Option | Decision Status | Rationale |
|:---|:---|:---|
| **Kafka (Project 5)** | ✅ Primary for Persistence | Core durable event log for bank event sourcing, replay, and compliance records. |
| **Cloud Pub/Sub (GCP)** | ✅ Edge / Serverless Ingress | Native GCP messaging for serverless fan-out and edge triggers. |

### 4.3 API Authentication Strategy

| Option | Decision Status | Rationale |
|:---|:---|:---|
| **Keycloak Token Validation (Project 1)** | ✅ Selected | MuleSoft introspects / validates Keycloak-issued JWTs with PKCE (S256). |

### 4.4 Secret Management

- GCP Secret Manager is the authoritative source for all credentials.
- Runtime Fabric pods retrieve secrets via Workload Identity Federation (WIF) or Kubernetes External Secrets Operator (ESO).
- No secrets in git, `.env`, or Dockerfiles.

---

## 5. Technical Specifications

### 5.1 Container & Runtime Build

| Aspect | Specification |
|:---|:---|
| **Base Image** | `mulesoft/mule:4.4-java11-alpine` (Alpine for minimal footprint) |
| **Build Type** | Multi-stage (Maven builder + runtime) |
| **Java Version** | Java 11 (bundled in base image) |
| **Mule Version** | Mule 4.4 |
| **Runtime Memory** | 2GB default; tunable via `JAVA_MAX_HEAP` |
| **HTTP Port** | 8081 (configurable) |
| **Health Check** | GET `/api/health` (30s interval, 40s startup delay) |

### 5.2 Deployment Target (Runtime Fabric on GKE)

| Aspect | Specification |
|:---|:---|
| **Platform** | Google Kubernetes Engine (GKE Autopilot / Standard) |
| **Orchestration** | ArgoCD (Project 6) GitOps engine |
| **Memory Request** | 2Gi (burstable to 4Gi) |
| **CPU Request** | 1000m (burstable to 2000m) |
| **Network Locality** | Private VPC subnetwork with Cloud NAT egress |
| **Ingress** | Internal Load Balancer / Ingress Controller with TLS 1.2+ |

### 5.3 API Endpoints

#### Pre-MVP Health Check API
| Endpoint | Method | Purpose | Authentication |
|:---|:---|:---|:---|
| `/api/health` | GET | System health status | None (public internal) |
| `/api/health/dependencies` | GET | Dependency connectivity | None (public internal) |
| `/api/health/readiness` | GET | Readiness probe | None (public internal) |

#### Phase 3: Transaction API (Facade)
| Endpoint | Method | Purpose | Authentication |
|:---|:---|:---|:---|
| `/api/transactions` | POST | Create transaction | OAuth 2.0 (Keycloak) |
| `/api/transactions/{id}` | GET | Retrieve transaction | OAuth 2.0 (Keycloak) |
| `/api/transactions` | GET | List transactions (paginated) | OAuth 2.0 (Keycloak) |

#### Phase 4: Partner Event Ingress
| Endpoint | Method | Purpose | Authentication |
|:---|:---|:---|:---|
| `/api/partner/events/transactions` | POST | Ingest transaction events | Mutual TLS (mTLS) + API key |
| `/api/partner/events/kyc` | POST | Ingest KYC events | Mutual TLS (mTLS) + API key |
| `/api/partner/events/fraud` | POST | Ingest fraud alerts | Mutual TLS (mTLS) + API key |

---

## 6. Implementation Roadmap

- **Phase 0: Learning & Access (Aug 25 - Sep 15, 2026)**: Onboarding, Anypoint access, Runtime Fabric decision finalized.
- **Phase 1: Non-Sensitive POC (Sep 16 - Oct 15, 2026)**: Health API, MUnit tests, local container validation.
- **Phase 2: Identity & Policy Proto (Oct 16 - Nov 15, 2026)**: Keycloak OIDC validation, rate limiting policies.
- **Phase 3: Project 2 Facade (Nov 16 - Dec 15, 2026)**: Transaction mediation, DataWeave mapping, PII masking.
- **Phase 4: Event Ingress (Dec 16, 2026 - Jan 15, 2027)**: Partner event ingestion, normalization, Kafka/PubSub publishing.
- **Phase 5: Production Hardening (Jan 16 - Feb 28, 2027)**: CI/CD automation, ArgoCD sync, security audit, monitoring dashboards.

---

## 7. Related Documents

- [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md) — Security and access control policies
- [`AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/AGENTS.md) — Agent automation rules and protocols
- [`CHECKLIST.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CHECKLIST.md) — Implementation checklist
- [`CONTAINER_STRUCTURE_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CONTAINER_STRUCTURE_PLAN.md) — Container structure plan
- [`Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md) — Comparative guide
