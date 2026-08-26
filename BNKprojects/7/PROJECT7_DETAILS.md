+++
title = "Project 7: MuleSoft Integration Layer - Project Details"
domain = "mulesoft"
topics = ["mulesoft", "integration", "project-details", "architecture", "banking"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["CHECKLIST.md", "CONTAINER_STRUCTURE_PLAN.md", "ARCHITECTURE.md", "README.md", "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md"]
updated_by = "Codex"
version = "1.0"
+++

> **Parent**: [`README.md`](README.md)  
> **Checklist**: [`CHECKLIST.md`](CHECKLIST.md)  
> **Container Plan**: [`CONTAINER_STRUCTURE_PLAN.md`](CONTAINER_STRUCTURE_PLAN.md)  
> **Strategic Plan**: [`Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)

---

# Project 7: MuleSoft Integration Layer - Project Details

**Project Status:** Planning / Initial Implementation (Phase 0-1)  
**Start Date:** Q3 2026  
**Expected MVP:** Q4 2026  
**Last Updated:** 2026-08-25

---

## 1. Executive Summary

Project 7 is the MuleSoft Anypoint Platform integration layer for the Altmtrk2026 Bank Platform. It provides:

- **API Facades** — Managed, policy-controlled APIs that wrap backend services (Projects 1, 2, 4)
- **API-Level Mediation** — Request/response transformation, validation, normalization
- **Partner Ingress** — Controlled ingestion of external events (transactions, KYC, fraud alerts)
- **Event Bridging** — Transformation and publication to event backbone (Project 5: Kafka / Pub/Sub)
- **Centralized Policies** — Rate limiting, OAuth token validation, CORS, throttling
- **Audit & Compliance** — PII-safe logging, transaction trails, audit records

Project 7 does **not** replace Project 0 infrastructure or Project 5 event backbone; it **augments** them with integration governance.

---

## 2. Business Drivers

### Why MuleSoft?

| Driver | Benefit |
|:---|:---|
| **API Governance** | Centralized policy enforcement (rate limiting, auth, versioning) across all integrations. |
| **Partner Connectivity** | Pre-built connectors for SaaS vendors (e.g., Actimize, payment processors). |
| **Rapid Mediation** | DataWeave transformations reduce custom coding for request/response mapping. |
| **Scalability** | CloudHub hosting or Runtime Fabric scales horizontally without GCP infrastructure changes. |
| **Operational Visibility** | Anypoint monitoring dashboards for API metrics, flow execution times, payload inspection. |
| **Time-to-Market** | Faster integration delivery vs. building custom middleware. |

### Alignment with Bank Platform Architecture

- **Project 0**: Provides networking, IAM, secrets, and shared infrastructure (MuleSoft depends on this)
- **Project 1**: Keycloak identity provider; MuleSoft validates tokens via introspection
- **Project 2**: Transaction Service backend; MuleSoft provides API facade and mediation
- **Project 4**: Actimize vendor integration; MuleSoft calls via REST/SOAP adapters
- **Project 5**: Event backbone (Kafka/Pub/Sub); MuleSoft publishes events and respects topic schemas
- **Project 6**: ArgoCD GitOps; if Runtime Fabric chosen, MuleSoft becomes Kubernetes workload

---

## 3. Scope & Ownership

### What Project 7 Owns

✅ **In Scope:**
- Mule application source code (flows, transformations, connectors)
- API specifications (RAML/OpenAPI)
- DataWeave transformation scripts
- MUnit test suites
- Anypoint Platform configuration (policies, environments, Exchange assets)
- Container build (Dockerfile, docker-compose, .dockerignore)
- CI/CD definitions for Docker image build and push
- API Manager policies and versions
- Documentation and runbooks

❌ **Out of Scope (Owned by Project 0 / Terraform):**
- VPC and network isolation
- Secret Manager and secret rotation
- Artifact Registry repositories
- Cloud Run resource provisioning
- IAM service accounts and role bindings
- DNS records
- TLS certificates
- Monitoring infrastructure (Cloud Logging, Cloud Monitoring)
- Load balancer and public IP management
- Database provisioning (PostgreSQL, MongoDB)
- Kafka or Pub/Sub topic creation

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
| Cloud Run deployment | Terraform (Project 0) | Project 7 (provides image) |
| Health checks / probes | Project 7 | Project 0 (Terraform) |
| Monitoring dashboards | Project 7 + Project 0 | — |
| On-call support | Project 7 | Project 0 (infrastructure) |

---

## 4. Architectural Decisions

### 4.1 Deployment Target (TBD - Phase 0)

| Option | Decision Status | Rationale |
|:---|:---|:---|
| **CloudHub 2.0** | ⏳ Pending | Fast managed service; easiest for multi-cloud; requires VPN to GCP services. |
| **CloudHub 1.0** | ⏳ Pending | Legacy option; only if organizational constraints require. |
| **Runtime Fabric on GKE** | ⏳ Pending | Maximum control; aligns with Project 6 GitOps; higher operational overhead. |
| **Hybrid Standalone** | ⏳ Pending | Only for legacy/on-premise constraints. |

**Owner:** MuleSoft admin + Architecture team  
**Target Decision Date:** 2026-09-01

### 4.2 Event Backbone Strategy (TBD - Phase 1)

| Option | Decision Status | Rationale |
|:---|:---|:---|
| **Kafka (Project 5)** | ⏳ Pending | Existing project 5 infrastructure; well-known for bank event streaming. |
| **Cloud Pub/Sub (GCP)** | ⏳ Pending | Native GCP service; simpler operations; less event replay capability. |
| **Both (hybrid)** | ⏳ Pending | MuleSoft bridges between Kafka and Pub/Sub; highest complexity. |

**Owner:** Platform architect + Project 5 team  
**Target Decision Date:** 2026-09-15

### 4.3 API Authentication Strategy (TBD - Phase 2)

| Option | Decision Status | Rationale |
|:---|:---|:---|
| **Direct Keycloak Introspection** | ⏳ Pending | MuleSoft calls `/token/introspection` endpoint; fast; requires Keycloak synchronization. |
| **Connected Client Provider** | ⏳ Pending | Use Anypoint's OAuth connected app model; most secure; adds Anypoint config. |
| **Backend Delegation** | ⏳ Pending | Backend APIs validate tokens; MuleSoft just passes headers; adds latency. |

**Owner:** Project 1 (Keycloak) + Project 7  
**Target Decision Date:** 2026-10-01

### 4.4 Secret Management (TBD - Implementation Specific)

**Current Plan:**
- Use GCP Secret Manager for all sensitive data
- Bind MuleSoft service account to Secret Manager via IAM
- No secrets in git, `.env`, or Dockerfile
- Injected at runtime via Cloud Run environment variables

**Alternative:** Use Anypoint Secrets Manager for MuleSoft-specific secrets (additional licensing may apply)

---

## 5. Technical Specifications

### 5.1 Container & Deployment

| Aspect | Specification |
|:---|:---|
| **Base Image** | `mulesoft/mule:4.4-java11-alpine` (Alpine for minimal footprint) |
| **Build Type** | Multi-stage (Maven builder + runtime) |
| **Java Version** | Java 11 (bundled in base image) |
| **Mule Version** | Mule 4.4 |
| **Runtime Memory** | 2GB default; tunable via `JAVA_MAX_HEAP` |
| **HTTP Port** | 8081 (configurable) |
| **Health Check** | GET `/api/health` (30s interval, 40s startup delay) |

### 5.2 Runtime Environment (Cloud Run)

| Aspect | Specification |
|:---|:---|
| **Platform** | GCP Cloud Run (managed service) |
| **Memory** | 2GB (increase to 4GB for high-volume) |
| **CPU** | 2 CPU (sufficient for I/O-bound operations) |
| **Concurrency** | 80 requests/container (configurable) |
| **Timeout** | 600 seconds (Cloud Run limit) |
| **Startup CPU Boost** | Enabled (reduces cold-start latency) |
| **Min Instances** | 0 (scale to zero when idle) |
| **Max Instances** | TBD (determine based on load testing) |
| **Region** | us-south1 (primary); europe-west1 (secondary, if applicable) |
| **VPC Connector** | Required for private access to Project 0 resources (networking, databases) |

### 5.3 API Endpoints

#### Pre-MVP Health Check API

| Endpoint | Method | Purpose | Authentication |
|:---|:---|:---|:---|
| `/api/health` | GET | System health status | None (public) |
| `/api/health/dependencies` | GET | Dependency connectivity | None (public) |
| `/api/health/readiness` | GET | Readiness for Cloud Run | None (public) |

#### Phase 3: Transaction API (Facade)

| Endpoint | Method | Purpose | Authentication |
|:---|:---|:---|:---|
| `/api/transactions` | POST | Create transaction | OAuth 2.0 (Keycloak) |
| `/api/transactions/{id}` | GET | Retrieve transaction | OAuth 2.0 (Keycloak) |
| `/api/transactions` | GET | List transactions (paginated) | OAuth 2.0 (Keycloak) |

#### Phase 4: Partner Event Ingress

| Endpoint | Method | Purpose | Authentication |
|:---|:---|:---|:---|
| `/api/partner/events/transactions` | POST | Ingest transaction events | API key + TLS certificate |
| `/api/partner/events/kyc` | POST | Ingest KYC events | API key + TLS certificate |
| `/api/partner/events/fraud` | POST | Ingest fraud alerts | API key + TLS certificate |

---

## 6. Dependencies & Integrations

### 6.1 Internal Dependencies

| Project | Component | Purpose | Integration Type |
|:---|:---|:---|:---|
| **Project 0** | VPC Connector | Private network access to Cloud Run services | Network |
| **Project 0** | Secret Manager | Centralized secret storage | IAM + API |
| **Project 0** | Artifact Registry | Docker image repository | Docker push/pull |
| **Project 0** | Terraform | Infrastructure automation | IaC |
| **Project 1** | Keycloak | Identity provider (token validation) | HTTP REST |
| **Project 2** | Transaction Service | Backend for transaction facade | HTTP REST |
| **Project 4** | Actimize | Fraud detection vendor | REST/SOAP connectors |
| **Project 5** | Kafka / Pub/Sub | Event backbone for publishing | Kafka producer or Pub/Sub client |
| **Project 6** | ArgoCD | GitOps (if Runtime Fabric chosen) | Kubernetes |

### 6.2 External Dependencies

| External Service | Purpose | Access Method |
|:---|:---|:---|
| **MuleSoft Anypoint Platform** | Mule application deployment, API Manager | Cloud-hosted SaaS |
| **CloudHub** (if chosen) | Managed Mule runtime | SaaS, region-specific |
| **Google Cloud (GCP)** | Cloud Run, Networking, Secrets, Logging | API |
| **Docker Hub / Container Registry** | Base image access (`mulesoft/mule:4.4-java11-alpine`) | Registry pull |

### 6.3 External Partner APIs (Phase 4+)

| Partner | Integration Type | Purpose |
|:---|:---|:---|
| **Bank Partner 1** | REST/SOAP | Ingest transaction events |
| **Bank Partner 2** | REST API | Ingest KYC events |
| **Bank Partner 3** | Webhooks | Ingest fraud alerts |

(Details TBD)

---

## 7. Security Model

### 7.1 Authentication & Authorization

| Layer | Mechanism | Owner |
|:---|:---|:---|
| **API Consumer Authentication** | OAuth 2.0 via Keycloak (Project 1) | Keycloak / Project 7 |
| **Partner Authentication** | Mutual TLS (mTLS) + API key | Project 7 |
| **Backend Service Auth** | Service account credentials (JSON key) | Project 0 IAM |
| **Secret Storage** | GCP Secret Manager | Project 0 |

### 7.2 Network Security

| Control | Specification | Owner |
|:---|:---|:---|
| **Ingress** | Cloud Run IAM (authenticated requests only) | Terraform (Project 0) |
| **Egress** | VPC Connector with Cloud NAT (monitored outbound traffic) | Terraform (Project 0) |
| **TLS** | Enforced for all external communication (1.2+ minimum) | MuleSoft config + Terraform |
| **VPC Isolation** | Private subnetwork; no public IP | Terraform (Project 0) |

### 7.3 Data Protection

| Control | Specification | Owner |
|:---|:---|:---|
| **Encryption in Transit** | TLS 1.2+ for all connections | MuleSoft + Terraform |
| **Encryption at Rest** | GCP default (GCS buckets, databases) | Terraform (Project 0) |
| **PII Masking** | Applied in logs (e.g., card numbers, SSN) | Project 7 (DataWeave) |
| **Audit Logging** | All transactions logged to Cloud Logging | Project 7 + Terraform |
| **Data Retention** | TBD (compliance-driven) | Compliance team |

### 7.4 Secrets Management

| Secret Type | Storage | Rotation | Owner |
|:---|:---|:---|:---|
| **DB credentials** | GCP Secret Manager | Every 90 days | Project 0 DBA |
| **Keycloak client secret** | GCP Secret Manager | Every 90 days | Project 1 admin |
| **API keys (partners)** | GCP Secret Manager | As needed | Project 7 / Partner |
| **TLS certificates** | GCP Secret Manager | Before expiry | Project 0 SRE |
| **MuleSoft application properties** | `.properties` files (not in git) | Per deployment | Project 7 developer |

---

## 8. Implementation Roadmap

### Phase 0: Learning & Access (Aug 25 - Sep 15, 2026)

**Objective:** Gain access, understand MuleSoft, make key architectural decisions

**Deliverables:**
- Anypoint Platform access confirmed
- Deployment target decision (CloudHub vs. Runtime Fabric)
- Local Anypoint Studio setup
- Team onboarded on MuleSoft fundamentals

**Dependencies:** Anypoint account provisioning (may take 1-2 weeks)

### Phase 1: Non-Sensitive POC (Sep 16 - Oct 15, 2026)

**Objective:** Build health API proof of concept

**Deliverables:**
- Health API specification (RAML)
- Mule app with health check flows
- Docker container building locally
- MUnit tests (>80% coverage)
- Initial CI/CD pipeline (Maven + Docker build)

**Acceptance Criteria:**
- Local build: `mvn clean package && docker build && docker-compose up`
- Health endpoint responds: `curl http://localhost:8081/api/health` → 200 OK

### Phase 2: Identity & Policy Proto (Oct 16 - Nov 15, 2026)

**Objective:** Integrate Keycloak, implement token validation

**Deliverables:**
- Keycloak OAuth 2.0 client configured
- Token introspection flow in MuleSoft
- API Manager policies drafted
- Security testing complete

**Acceptance Criteria:**
- Valid token: 200 OK response
- Expired token: 401 Unauthorized
- Missing token: 401 Unauthorized

### Phase 3: Project 2 Facade (Nov 16 - Dec 15, 2026)

**Objective:** Build transaction API facade

**Deliverables:**
- Transaction API specification (RAML)
- Request/response transformation (DataWeave)
- Audit logging implemented
- Integration tests with mock Project 2

**Acceptance Criteria:**
- API validates incoming schema
- Transforms to Project 2 contract
- Handles Project 2 errors gracefully (retry + circuit breaker)

### Phase 4: Event Ingress (Dec 16, 2026 - Jan 15, 2027)

**Objective:** Partner event ingestion and normalization

**Deliverables:**
- Partner API specification
- Event normalization flow (DataWeave)
- Kafka/Pub/Sub publishing
- Dead-letter queue for invalid events

**Acceptance Criteria:**
- Partner event received and transformed
- Published to Kafka/Pub/Sub topic
- Invalid events routed to DLQ

### Phase 5: Production Hardening (Jan 16 - Feb 28, 2027)

**Objective:** Ready for production deployment

**Deliverables:**
- Full CI/CD automation (Cloud Build → Cloud Run)
- Terraform integration complete
- Security audit passed
- Monitoring dashboards live
- Production runbooks documented

**Acceptance Criteria:**
- Automated deployment from git push to Cloud Run
- 99.5% uptime SLA
- < 100ms p95 latency
- Zero security findings from audit

---

## 9. Success Metrics (KPIs)

### Performance

| Metric | Target | Measurement |
|:---|:---|:---|
| **API Latency (p95)** | < 100ms | Cloud Monitoring dashboard |
| **API Latency (p99)** | < 500ms | Cloud Monitoring dashboard |
| **Error Rate** | < 0.5% | Error rate (4xx + 5xx) / total requests |
| **Availability** | 99.5% | Uptime monitoring (Cloud Run health checks) |
| **Throughput** | > 1000 req/s | Load testing + production metrics |

### Operational

| Metric | Target | Measurement |
|:---|:---|:---|
| **MTTR (Mean Time to Recovery)** | < 15 min | Incident logs |
| **Deployment Frequency** | > 1x/week | Release notes / git tag frequency |
| **Code Coverage** | > 80% | MUnit test reports |
| **Documentation Completeness** | 100% | Checklist completion |

### Business

| Metric | Target | Measurement |
|:---|:---|:---|
| **Time-to-Integration** | Reduce by 50% | Comparison with previous integrations |
| **API Violations** | 0 unauthenticated calls | API Manager policy reports |
| **Partner Satisfaction** | > 4.0/5 | Feedback survey |

---

## 10. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|:---|:---|:---|:---|
| **Anypoint account provisioning delay** | Medium | High | Request access early; use trial account as backup |
| **MuleSoft learning curve** | Medium | Medium | Invest in formal training; hire experienced contractor if needed |
| **Keycloak token validation performance** | Low | High | Design caching strategy; benchmark early; consider JWT validation locally |
| **VPC Connector latency (GCP)** | Low | Medium | Test connectivity early; use connection pooling |
| **Partner schema changes** | Medium | Medium | Version APIs; validate early; require partner notification 30 days prior |
| **Event ordering issues (Kafka/Pub/Sub)** | Low | High | Document exactly-once vs. at-least-once semantics; design idempotent processors |
| **Secrets exposure in logs** | Low | Critical | Implement PII masking; use automated secret scanning; rotate compromised secrets |

---

## 11. Assumptions

1. **Anypoint Platform is available** in the organization or can be procured
2. **Keycloak (Project 1) is stable** and accessible from MuleSoft
3. **Kafka or Pub/Sub (Project 5) is available** for event publishing
4. **GCP VPC Connector is configured** between MuleSoft and internal services
5. **Team has MuleSoft expertise** or can hire/train quickly
6. **CloudHub or Runtime Fabric is supported** in the organization
7. **No restriction on Anypoint Platform cost** (managed service pricing)

---

## 12. Out-of-Scope Considerations

- **Actimize (Project 4) integration:** Scheduled for Phase 4; requires stable fraud decision contracts first
- **API versioning management:** Defer to Anypoint API Manager; document strategy in Phase 1
- **Multi-region deployment:** Consider for PROD; Phase 5 task
- **Disaster recovery / backup:** Coordinate with Project 0 disaster recovery plan
- **Change management / approval boards:** Follow bank's change advisory board (CAB) process

---

## 13. Sign-Off

| Role | Name | Date | Approval |
|:---|:---|:---|:---|
| **Project Manager** | — | — | ⏳ Pending |
| **Architecture Lead** | — | — | ⏳ Pending |
| **Security Lead** | — | — | ⏳ Pending |
| **DevOps Lead** | — | — | ⏳ Pending |

---

## 14. Appendices

### A. Glossary

| Term | Definition |
|:---|:---|
| **Anypoint** | MuleSoft's integration platform (public SaaS) |
| **CloudHub** | MuleSoft's managed Mule runtime (SaaS hosting) |
| **Runtime Fabric** | Self-managed Mule runtime on Kubernetes |
| **Mule** | MuleSoft's lightweight integration runtime |
| **DataWeave** | MuleSoft's data transformation language |
| **Connector** | Reusable component for integrating external systems (Kafka, HTTP, SOAP, etc.) |
| **Flow** | Execution pipeline in Mule (source → transport → processors → sink) |
| **Policy** | API-level enforcement rule (rate limiting, auth, encryption) |
| **Exchange** | MuleSoft's artifact repository (like Maven Central) |

### B. References

- [MuleSoft Documentation](https://docs.mulesoft.com/)
- [Mule Runtime Installation](https://docs.mulesoft.com/mule-runtime/latest/mule-runtime-installation-task)
- [Anypoint Platform](https://anypoint.mulesoft.com/)
- [MuleSoft on Docker Hub](https://hub.docker.com/r/mulesoft/mule)
- [GCP Cloud Run Best Practices](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)

### C. Document History

| Version | Date | Author | Changes |
|:---|:---|:---|:---|
| 1.0 | 2026-08-25 | Codex | Initial version; all phases defined; decisions TBD |

---

**Document Version:** 1.0  
**Status:** ✅ Planning Phase  
**Next Review:** 2026-09-30
