+++
title = "Project 7: MuleSoft Integration Layer - Implementation Checklist"
domain = "mulesoft"
topics = ["mulesoft", "implementation", "checklist", "project7", "development", "runtime-fabric"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "PROJECT7_DETAILS.md",
    "SECURITY.md",
    "AGENTS.md",
    "CONTAINER_STRUCTURE_PLAN.md",
    "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md",
    "../../Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Technical Specs**: [`PROJECT7_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md)  
> **Security Policy**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)  
> **Strategic Plan**: [`Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)

---

# Project 7: MuleSoft Implementation Checklist

**Project Status:** Planning / Initial Implementation (Phase 0-1)  
**Last Updated:** 2026-08-26  
**Deployment Decision:** Runtime Fabric on GKE (Selected for Production; CloudHub trial for POC)

---

## Phase 0: Learning and Access

### Anypoint Platform Setup
- [ ] Confirm Anypoint Platform account access and permissions
- [ ] Verify business group assignment and organizational hierarchy
- [ ] Obtain Anypoint organization ID (UUID) and document in `PROJECT7_DETAILS.md`
- [ ] Confirm available environments (DEV, TEST, PROD)
- [ ] Review Anypoint roles and least-privilege access model

### MuleSoft Deployment Target Decision
- [x] Review deployment options (CloudHub 2.0, CloudHub 1.0, Runtime Fabric, Hybrid) — *Completed 2026-08-26: Runtime Fabric on GKE selected for production, CloudHub trial for POC*
- [x] Document selected deployment target in `PROJECT7_DETAILS.md` and `Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`
- [ ] Coordinate with Project 6 (ArgoCD) and Project 0 (GKE setup) for Runtime Fabric provisioning
- [ ] Define private connectivity approach (VPC peering, GKE private cluster, internal load balancing)

### Team and Access Control
- [ ] Assign MuleSoft admin(s) for Anypoint Platform management
- [ ] Assign Mule application developer(s)
- [ ] Assign API Manager policy owner
- [ ] Grant IAM roles in GCP for Artifact Registry, Secret Manager, GKE
- [ ] Configure Workload Identity Federation (WIF) for GitHub Actions CI/CD

### Learning Path
- [ ] Complete MuleSoft Mule 4 Fundamentals training
- [ ] Review `Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md` documentation
- [ ] Set up local Anypoint Studio environment
- [ ] Complete hello-world Mule application locally
- [ ] Review DataWeave transformation basics
- [ ] Review MUnit testing framework

---

## Phase 1: Non-Sensitive Proof of Concept

### Project Structure & Initialization
- [ ] Initialize Maven project structure under `BNKprojects/7/`
- [ ] Create `pom.xml` with Mule Maven plugin version 4.x
- [ ] Create `mule-artifacts.json` with project metadata
- [x] Create `.gitignore` to exclude local secrets, `target/`, `.mule/` directories
- [x] Create `container/.dockerignore` for lean and secure build contexts
- [x] Create `.env.example` and `.env.local.example` templates

### Health API Specification (Bank Integration Health API)
- [ ] Define Health API RAML/OpenAPI specification (`src/main/mule/api-specs/health-api.raml`)
- [ ] Document endpoints:
  - `GET /api/health` — System health status
  - `GET /api/health/dependencies` — Dependency connectivity check
  - `GET /api/health/readiness` — Readiness probe
- [ ] Review API spec with architecture team

### Core Mule Application
- [ ] Create `src/main/mule/health-api.xml` (main Mule configuration)
- [ ] Create global configuration elements:
  - [ ] HTTP listener configuration (port 8081)
  - [ ] Logger configuration (log4j2)
  - [ ] Error handling strategies
- [ ] Implement health check flow:
  - [ ] Request validation
  - [ ] Simple response transformation
  - [ ] Error handling (500 on failure)
- [ ] Create startup flow (runs on container initialization)

### Configuration Management
- [ ] Create `src/main/resources/application.properties` (default DEV)
- [ ] Create `config/log4j2.xml` (logging configuration)
- [x] Create `.env.example` with all environment variables
- [x] Document configuration hierarchy (environment-specific overrides)

### Unit Testing (MUnit)
- [ ] Create `src/test/munit/health-api-test.xml`
- [ ] Test cases:
  - [ ] Test successful health check response
  - [ ] Test error response on internal failure
  - [ ] Test request validation (invalid input)
  - [ ] Test logging output (verify no secrets/PII exposed)
- [ ] Configure MUnit Maven plugin in `pom.xml`
- [ ] Ensure test coverage >= 80%

### Local Development & Testing
- [ ] Create `container/docker-compose.yml` for local stack (Mule + PostgreSQL + Kafka emulator)
- [x] Create `container/Dockerfile` with parameterized build args
- [ ] Build Docker image locally: `docker build -f container/Dockerfile .`
- [ ] Verify health endpoint: `curl http://localhost:8081/api/health`
- [ ] Test with Postman or curl (save collection to `tests/postman/`)

### Documentation
- [x] Create `container/README.md` with build and deployment instructions
- [x] Create `README.md` with project overview
- [x] Create `SECURITY.md` with security & access control policies
- [x] Create `AGENTS.md` with automation and bot guidelines
- [x] Create `CONTAINER_STRUCTURE_PLAN.md` with container structure
- [x] Create `IMPLEMENTATION_STATUS.md` with status summary

### CI/CD Foundation
- [ ] Create CI/CD workflow (Cloud Build / GitHub Actions)
- [ ] Build step: `mvn clean package -DskipTests`
- [ ] Test step: `mvn test` (MUnit)
- [ ] Security scanning step: `trivy` vulnerability and secret scan
- [ ] Image build step: Docker build and push to Artifact Registry (DEV only)

---

## Phase 2: Identity and Policy Prototype

### Keycloak Integration (Project 1)
- [ ] Define OIDC/OAuth 2.0 client in Keycloak for MuleSoft
  - [ ] Client ID: `mulesoft-client`
  - [ ] Client credentials / PKCE flow
  - [ ] Scopes: Minimum required (`openid`, `profile`)
- [ ] Create Keycloak token introspection endpoint configuration
- [ ] Implement Mule flow: `src/main/mule/flows/identity-sync.xml`
  - [ ] Extract JWT from Authorization header
  - [ ] Call Keycloak introspection endpoint
  - [ ] Validate token claims (aud, exp, iss, scopes)
  - [ ] Reject invalid or expired tokens (return 401/403)

### API Manager Policies
- [ ] Document API Manager policy requirements
- [ ] Define rate limiting policy (e.g., 1000 requests/minute per client ID)
- [ ] Define OAuth token validation policy
- [ ] Define CORS policy (if applicable)
- [ ] Test policy evaluation order

### Test Cases (Token Scenarios)
- [ ] Test case: Valid token with correct claims → 200 OK
- [ ] Test case: Expired token → 401 Unauthorized
- [ ] Test case: Invalid signature → 401 Unauthorized
- [ ] Test case: Missing Authorization header → 401 Unauthorized
- [ ] Test case: Wrong audience (`aud` claim) → 401 Unauthorized
- [ ] Test case: Insufficient scopes → 403 Forbidden

### Security Review (Identity Layer)
- [x] Create `SECURITY.md` with authentication/authorization controls
- [ ] Verify no tokens/secrets logged in MuleSoft logs
- [ ] Verify token validation happens before backend calls
- [ ] Verify error responses don't leak token details
- [ ] Test with OWASP ZAP or similar security scanner

---

## Phase 3: Project 2 Facade (Transaction Service)

### Transaction API Specification
- [ ] Define Transaction API RAML/OpenAPI (`src/main/mule/api-specs/transaction-api.raml`)
- [ ] Endpoints:
  - [ ] `POST /api/transactions` — Create transaction
  - [ ] `GET /api/transactions/{id}` — Retrieve transaction
  - [ ] `GET /api/transactions?limit=10` — List transactions (paginated)
- [ ] Define request/response schemas (JSON Schema)
- [ ] Coordinate with Project 2 service contract

### MuleSoft Facade Flow
- [ ] Create `src/main/mule/flows/transaction-facade.xml`
- [ ] Request validation:
  - [ ] Validate schema against `src/main/resources/schemas/transaction-request.json`
  - [ ] Enforce required fields (amount, currency, recipient)
  - [ ] Validate numeric ranges (amount > 0)
- [ ] DataWeave transformation:
  - [ ] Create `src/main/resources/dataweave/transaction-transform.dw`
  - [ ] Transform incoming request to Project 2 contract
  - [ ] Add audit metadata (timestamp, requestId, userId)
- [ ] HTTP callout to Project 2:
  - [ ] Timeout: 30 seconds
  - [ ] Retry logic: exponential backoff (3 retries)
  - [ ] Handle connection errors (503 Service Unavailable)
- [ ] Response normalization:
  - [ ] Create `src/main/resources/dataweave/response-format.dw`
  - [ ] Transform Project 2 response to MuleSoft API format
  - [ ] Mask sensitive data (passwords, full PAN card numbers)

### Audit and Logging
- [ ] Create `src/main/mule/flows/audit-logging.xml`
- [ ] Log transaction events to Cloud Logging:
  - [ ] transactionId, userId, amount, status
  - [ ] Timestamp, latency, backend response code
- [ ] Verify PII masking in logs (no full card numbers, SSN, tokens)
- [ ] Configure Cloud Logging sink (GCP integration)

### Testing
- [ ] MUnit: Test successful transaction flow
- [ ] MUnit: Test validation errors (401, 400, 403)
- [ ] MUnit: Test Project 2 timeout (retry logic)
- [ ] MUnit: Test Project 2 error response (5xx)
- [ ] Integration test: End-to-end with mock Project 2

---

## Phase 4: Event Ingress Prototype (Project 5 Integration)

### Partner Event API Specification
- [ ] Define Partner API RAML/OpenAPI (`src/main/mule/api-specs/partner-api.raml`)
- [ ] Endpoints:
  - [ ] `POST /api/partner/events/transactions` — Ingest transaction events
  - [ ] `POST /api/partner/events/kyc` — Ingest KYC events
  - [ ] `POST /api/partner/events/fraud` — Ingest fraud alerts
- [ ] Define event schemas

### Event Schema Validation
- [ ] Create canonical event schema (`src/main/resources/schemas/event-canonical.json`)
  - [ ] eventId (UUID)
  - [ ] eventType (transaction, kyc, fraud_alert)
  - [ ] timestamp (ISO 8601)
  - [ ] payload (event-specific data)
- [ ] Validate incoming partner payloads against schema

### Event Bridge Flow
- [ ] Create `src/main/mule/flows/event-bridge.xml`
- [ ] Partner authentication:
  - [ ] Validate API key or mutual TLS (mTLS) certificate
  - [ ] Enforce TLS 1.2+ (no plaintext HTTP)
- [ ] Event transformation:
  - [ ] Create `src/main/resources/dataweave/event-normalize.dw`
  - [ ] Transform partner payload to canonical schema
  - [ ] Add enrichment data if needed
- [ ] Event publishing:
  - [ ] Kafka connector: Publish to `bank.events` topic (if using Kafka)
  - [ ] Pub/Sub connector: Publish to `bank-events` topic (if using Pub/Sub)
  - [ ] Handle publish errors (dead-letter queue or retry)

### Dead-Letter Queue
- [ ] Create error flow for invalid events
- [ ] Store invalid payloads in GCS or database for audit review
- [ ] Alert operations team on repeated failures

### Testing & Observability
- [ ] MUnit: Test valid event transformation
- [ ] MUnit: Test schema validation failure (400 Bad Request)
- [ ] MUnit: Test authentication failure (401 Unauthorized)
- [ ] MUnit: Test Kafka/Pub/Sub publish success and retry
- [ ] Cloud Monitoring dashboard for ingestion rate, processing latency, and error rate

---

## Phase 5: Production Hardening

### CI/CD Automation
- [ ] Build stage (Cloud Build / GitHub Actions):
  - [ ] Compile: `mvn clean package`
  - [ ] Test: `mvn test`
  - [ ] SAST (static analysis) and dependency scan
- [ ] Image build & push stage:
  - [ ] Build Docker image with build args (`JAVA_MAX_HEAP`, `LOG_LEVEL`, etc.)
  - [ ] Scan image for vulnerabilities: `trivy`
  - [ ] Push to Artifact Registry (tag: git commit SHA)
- [ ] Deployment stage (GitOps via Project 6 ArgoCD):
  - [ ] Deploy to DEV automatically on merge to `main`
  - [ ] Manual approval required for TEST → PROD promotion
  - [ ] Verify health probes pass before marking deployment complete

### Secrets Management
- [ ] Migrate all secrets to GCP Secret Manager:
  - [ ] Database credentials
  - [ ] Keycloak client secrets
  - [ ] Partner API keys
  - [ ] TLS certificates/keystores
- [ ] Configure Workload Identity Binding (service account → Secret Manager)
- [ ] Verify no secrets in git history (`git-secrets` hook)

### Observability & Monitoring
- [ ] Stream MuleSoft logs to Cloud Logging with PII masking
- [ ] Cloud Monitoring dashboard for request rate, latency (p50/p95/p99), JVM heap, error rate
- [ ] Distributed tracing (OpenTelemetry / Cloud Trace) with correlation IDs

### Health & Readiness Probes
- [ ] Implement startup probe (60s threshold, 3 retries)
- [ ] Implement liveness probe (30s interval, 3 retries)
- [ ] Implement readiness probe (checks dependency health)

---

## Decision Log

### Decision: Deployment Target
- **Decision:** **Runtime Fabric on GKE** (Selected for Production; CloudHub sandbox/trial for Phase 1 POC)
- **Rationale:** Runtime Fabric satisfies banking requirements for private network locality, VPC-native access, data sovereignty, and GitOps integration via ArgoCD (Project 6). CloudHub evaluation accounts serve for fast early POC verification.
- **Date:** 2026-08-26
- **Owner:** MuleSoft Admin + Architecture Team
- **Reference:** [`Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md)

### Decision: Event Backbone Strategy
- **Decision:** Kafka (Project 5) primary for audit stream event persistence; GCP Pub/Sub for serverless event routing.
- **Rationale:** Kafka provides replayable event sourcing for transaction logs and compliance; Pub/Sub provides low-latency cloud ingress.
- **Date:** 2026-08-26
- **Owner:** Platform Architect + Project 5 Team

### Decision: API Management & Token Validation
- **Decision:** Project 1 Keycloak OIDC JWT token validation with PKCE (S256).
- **Rationale:** Single source of truth for bank user and service identities across all microservices.
- **Date:** 2026-08-26
- **Owner:** Project 1 (Keycloak) + Project 7 (MuleSoft)

---

**Checklist Version:** 1.1  
**Last Updated:** 2026-08-26  
**Next Review:** 2026-09-30
