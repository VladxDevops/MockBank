+++
title = "Container Structure and Build Planning for Project7 (MuleSoft)"
domain = "mulesoft-containers"
topics = ["containerization", "mulesoft", "docker", "cloud-run", "deployment"]
difficulty = "intermediate"
parent = "../README.md"
children = []
related = ["../ARCHITECTURE.md", "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md"]
updated_by = "Codex"
version = "1.0"
+++

> **Parent**: [`../README.md`](../README.md)
> **MuleSoft Plan**: [`../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)

---

# Container Structure and Build Planning - Project7 (MuleSoft Integration Layer)

## Overview

This document defines the Docker container structure, build process, and required files for deploying MuleSoft Mule applications in Project7. The container is optimized for GCP Cloud Run deployment with security, modularity, and operational best practices.

---

## 1. Directory Structure

```text
BNKprojects/7/
├── README.md                                 # Project overview and integration points
├── CONTAINER_STRUCTURE_PLAN.md              # This file - container build planning
├── ARCHITECTURE.md                          # Technical architecture and patterns
├── PROJECT7_DETAILS.md                      # Project scope and deliverables (TBD)
├── SECURITY.md                              # MuleSoft-specific security policies (TBD)
├── AGENTS.md                                # Deployment automation protocols (TBD)
├── container/
│   ├── Dockerfile                           # Multi-stage build for Mule applications
│   ├── .dockerignore                        # Exclude dev/test files from build context
│   ├── docker-compose.yml                   # Local development (optional, see Section 3.1)
│   ├── cloudbuild.yaml                      # GCP Cloud Build config (automated)
│   ├── entrypoint.sh                        # Custom startup script (optional)
│   ├── config/                              # Runtime configuration files
│   │   ├── application-dev.properties       # DEV environment properties
│   │   ├── application-test.properties      # TEST environment properties
│   │   ├── application-prod.properties      # PROD environment properties
│   │   └── log4j2.xml                       # Logging configuration
│   ├── policies/                            # MuleSoft API Manager policies (schemas only)
│   │   ├── rate-limiting-policy.yaml        # Rate limiting policy definition
│   │   └── oauth-policy.yaml                # OAuth token validation policy
│   ├── libs/                                # Additional JAR dependencies
│   │   └── custom-connectors.jar            # Custom MuleSoft connectors (if needed)
│   ├── README.md                            # Container build and deployment guide
│   ├── TROUBLESHOOTING.md                   # Common container issues and fixes (TBD)
│   └── TESTING.md                           # Unit and integration testing (TBD)
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── banking-api.xml              # Main Mule configuration
│   │   │   ├── flows/
│   │   │   │   ├── transaction-facade.xml   # Facade for Project 2 (Transaction Service)
│   │   │   │   ├── identity-sync.xml        # Integration with Project 1 (Keycloak)
│   │   │   │   ├── event-bridge.xml         # Bridge to Project 5 (Pub/Sub/Kafka)
│   │   │   │   └── partner-ingress.xml      # Partner API ingestion
│   │   │   ├── sub-flows/
│   │   │   │   ├── transform-request.xml    # DataWeave transformations
│   │   │   │   ├── error-handling.xml       # Centralized error handling
│   │   │   │   └── audit-logging.xml        # Audit trail logging
│   │   │   ├── global-config.xml            # Global configuration elements
│   │   │   └── api-specs/
│   │   │       ├── transaction-api.raml     # Transaction API specification
│   │   │       ├── fraud-api.raml           # Fraud event API specification
│   │   │       └── partner-api.raml         # Partner ingestion API
│   │   ├── resources/
│   │   │   ├── application.properties       # Default properties (DEV)
│   │   │   ├── dataweave/
│   │   │   │   ├── transaction-transform.dw # Transaction payload transformation
│   │   │   │   ├── event-normalize.dw       # Event normalization script
│   │   │   │   └── response-format.dw       # Response formatting
│   │   │   └── schemas/
│   │   │       ├── transaction-request.json # Transaction request schema
│   │   │       ├── transaction-response.json# Transaction response schema
│   │   │       └── event-canonical.json     # Canonical event schema
│   │   └── java/
│   │       ├── com/altmtrk/mule/
│   │       │   ├── connectors/              # Custom Java connectors
│   │       │   └── utils/                   # Utility classes
│   └── test/
│       ├── munit/
│       │   ├── transaction-facade-test.xml  # Unit tests for transaction flow
│       │   ├── identity-sync-test.xml       # Unit tests for identity integration
│       │   ├── event-bridge-test.xml        # Unit tests for event bridging
│       │   └── suites/                      # Test suites and smoke tests
│       └── resources/
│           ├── test-data/
│           │   ├── transaction-payload.json # Sample transaction data
│           │   └── event-samples.json       # Sample event payloads
│           └── mock-responses/
│               ├── keycloak-token.json      # Mock Keycloak token
│               └── transaction-service.json # Mock Project 2 response
├── pom.xml                                  # Maven project descriptor
├── settings.xml                             # Maven settings (optional, secrets excluded)
├── mule-artifacts.json                      # Mule project metadata
├── exchange-docs/                           # Exchange documentation (optional)
│   ├── api-guide.md                         # API user guide
│   └── connector-docs.md                    # Custom connector documentation
└── .muleconfig                              # Mule configuration metadata

```

---

## 2. File Descriptions and Purpose

### Core Container Files

| File | Purpose | Status |
|:---|:---|:---|
| **Dockerfile** | Multi-stage build using `mulesoft/mule:4.4-java11-alpine` base image. Compiles Mule app, packages JAR, and deploys to runtime. | ✅ Created |
| **.dockerignore** | Excludes ~100 file patterns (node_modules, .env, logs, IDE files, etc.) to minimize build context and improve security. | ✅ Created |

### Application Configuration

| File | Purpose | Need to Create |
|:---|:---|:---|
| **config/application.properties** | Default DEV configuration (ports, endpoints, datasource URLs). | ✅ Yes |
| **config/log4j2.xml** | Logging configuration (INFO/DEBUG levels, file/console appenders). | ✅ Yes |
| **config/application-prod.properties** | PROD-specific overrides (e.g., `server.port=${MULE_PORT:8081}`). | ✅ Yes |
| **mule-artifacts.json** | Mule project metadata (name, version, deployable type). | ✅ Yes (if using Maven) |

### Source Code Structure

| Directory | Purpose | Need to Create |
|:---|:---|:---|
| **src/main/mule/** | Primary Mule flow definitions (XML). | ✅ Yes |
| **src/main/resources/** | Application properties, schemas, and DataWeave scripts. | ✅ Yes |
| **src/test/munit/** | MUnit test flows for unit and integration testing. | ✅ Yes |

### Build and Deployment

| File | Purpose | Need to Create |
|:---|:---|:---|
| **pom.xml** | Maven build descriptor (compiler, Mule Maven plugin, dependencies). | ✅ Yes |
| **cloudbuild.yaml** | GCP Cloud Build configuration for automated image builds and pushes to Artifact Registry. | ✅ Yes |
| **docker-compose.yml** | Local development stack (Mule + PostgreSQL + Kafka emulator). Optional but recommended. | ⚠️ Optional |

### Documentation

| File | Purpose | Need to Create |
|:---|:---|:---|
| **container/README.md** | Container build, local testing, and Cloud Run deployment instructions. | ✅ Yes |
| **ARCHITECTURE.md** | Technical design: flow diagrams, patterns, security controls. | ✅ Yes (if not exists) |
| **SECURITY.md** | MuleSoft-specific security: authentication, encryption, compliance. | ✅ Yes |
| **AGENTS.md** | Automation protocols for CI/CD, testing, and deployment. | ✅ Yes |

---

## 3. Build and Deployment Workflow

### 3.1 Local Development Build

**Prerequisites:**
- Anypoint Studio (optional, but helpful for debugging)
- Maven 3.8+
- Java 11
- Docker Desktop

**Steps:**

```bash
cd /home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7

# 1. Compile and package (creates target/*.jar)
mvn clean package -DskipTests

# 2. Build Docker image locally
docker build -t mulesoft-integration:latest -f container/Dockerfile .

# 3. Run locally (with docker-compose for full stack)
cd container
docker-compose up -d

# 4. Verify health endpoint
curl http://localhost:8081/api/health

# 5. Stop
docker-compose down
```

### 3.2 Cloud Build (GCP CI/CD)

**Configuration:** `container/cloudbuild.yaml`

**Trigger:** On push to `main` branch in `/BNKprojects/7/`

**Steps:**

1. **Build Phase:** Runs Dockerfile multi-stage build
2. **Test Phase:** Runs MUnit tests (if `munit-maven-plugin` configured)
3. **Push Phase:** Tags and pushes image to Artifact Registry
4. **Deploy Phase:** Uses Terraform to update Cloud Run service

**Image URI Pattern:**
```
${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/mulesoft-integration:${BUILD_ID}
```

Example:
```
us-south1-docker.pkg.dev/dev-mockbank/dev-mongodb-atlas-container/mulesoft-integration:abc123def456
```

### 3.3 Cloud Run Deployment

**Managed by:** Terraform (e.g., `terraform/modules/project7/main.tf`)

**Configuration Overrides:**
- **Memory:** 2GB (Mule typically needs >1GB)
- **CPU:** 2 CPU
- **Timeout:** 600s (long-running operations)
- **Concurrency:** 80 (requests per container instance)
- **VPC Connector:** Required for private connectivity to Project 0 resources

**Environment Variables (via Secret Manager):**
```
MULE_ENV=cloud
ANYPOINT_ENVIRONMENT=production
ANYPOINT_ORGANIZATION_ID=${secret:anypoint-org-id}
DB_HOST=${secret:db-host}
DB_PASSWORD=${secret:db-password}
KAFKA_BROKERS=${secret:kafka-brokers}
PUBSUB_PROJECT_ID=dev-mockbank
```

---

## 4. Security Considerations

### 4.1 Build-Time Security

| Concern | Mitigation |
|:---|:---|
| **Secrets in build context** | Use `.dockerignore` to exclude `.env`, `*.properties` with secrets, `credentials.json`. |
| **Bare credentials in Dockerfile** | Use Docker build secrets (BuildKit) or inject via CI/CD pipeline. |
| **Package vulnerabilities** | Use `RUN mvn dependency:check` to scan for CVEs. Run `trivy` on final image. |
| **Base image integrity** | Use explicit image digest (not `:latest`): `mulesoft/mule:4.4-java11-alpine@sha256:...` |

### 4.2 Runtime Security

| Concern | Mitigation |
|:---|:---|
| **Non-root execution** | Base image runs as `mule` user (UID 1000), not root. |
| **Network isolation** | Cloud Run uses VPC connector; no direct public ingress. No IAM bindings to `allUsers`. |
| **Secret management** | Use GCP Secret Manager; inject at runtime (not baked in image). |
| **Logging & monitoring** | CloudLogging integration; audit all API calls; mask sensitive data. |
| **API authentication** | Enforce OAuth 2.0 / OIDC with Keycloak (Project 1) at API Manager level. |

---

## 5. Dependency Management

### 5.1 Mule Plugins (Maven POM)

```xml
<!-- pom.xml snippet -->
<plugins>
    <plugin>
        <groupId>org.mule.tools</groupId>
        <artifactId>mule-maven-plugin</artifactId>
        <version>3.8.3</version>
    </plugin>
</plugins>

<dependencies>
    <!-- Mule Core -->
    <dependency>
        <groupId>org.mule.runtime</groupId>
        <artifactId>mule-runtime-impl</artifactId>
        <version>4.4.0</version>
    </dependency>

    <!-- Connectors -->
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-http-connector</artifactId>
        <version>1.6.0</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-db-connector</artifactId>
        <version>1.14.0</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-kafka-connector</artifactId>
        <version>3.2.0</version>
    </dependency>

    <!-- Testing -->
    <dependency>
        <groupId>org.mule.tests</groupId>
        <artifactId>mule-tests-functional</artifactId>
        <version>4.4.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### 5.2 External Dependencies

These are managed **outside** this container:

- **Keycloak** (Project 1) — OAuth 2.0 token provider
- **Transaction Service** (Project 2) — Backend API for transactions
- **MongoDB** (Project 0) — Audit and operational data store
- **Kafka / Cloud Pub/Sub** (Project 5) — Event backbone
- **GCP Secret Manager** — Centralized secret management

---

## 6. Integration Points

### 6.1 Project 1 (Keycloak) Integration

**Flow:** `src/main/mule/flows/identity-sync.xml`

- **Purpose:** Validates incoming API calls against Keycloak tokens
- **Mechanism:** HTTP callout to Keycloak's introspection endpoint
- **Security:** Uses Keycloak client credentials (stored in Secret Manager)
- **Failure Handling:** Reject with 401 Unauthorized if token invalid

### 6.2 Project 2 (Transaction Service) Integration

**Flow:** `src/main/mule/flows/transaction-facade.xml`

- **Purpose:** Provides a managed API facade with transformation and policy enforcement
- **Mechanism:** HTTP callout to Project 2 Cloud Run service
- **Transformation:** DataWeave mapping (`src/main/resources/dataweave/transaction-transform.dw`)
- **Failure Handling:** Timeout = 30s; retry with exponential backoff

### 6.3 Project 5 (Kafka / Pub/Sub) Integration

**Flow:** `src/main/mule/flows/event-bridge.xml`

- **Purpose:** Bridges partner events and internal transformations to event backbone
- **Mechanism:** Kafka or Pub/Sub connector (configured in `global-config.xml`)
- **Schema Validation:** Validates payload against canonical schema (`src/main/resources/schemas/event-canonical.json`)
- **Failure Handling:** Dead-letter queue for invalid events

### 6.4 Project 0 (Foundation) Integration

**Provided by Terraform:** 
- VPC Connector for private network access
- Secret Manager bindings
- Artifact Registry repository
- IAM service account with scoped permissions
- DNS records (if applicable)

---

## 7. Environment-Specific Configuration

### 7.1 DEV Environment

**Configuration File:** `config/application-dev.properties`

```properties
# API endpoints
mule.http.listener.port=8081
transaction.service.url=http://transaction-service-dev:8080
keycloak.introspection.url=http://keycloak-dev:8080/auth/realms/bank/protocol/openid-connect/token/introspection
kafka.brokers=kafka-dev:9092

# Logging
logging.level.root=DEBUG
logging.level.com.altmtrk=DEBUG

# Security (relaxed for local testing)
api.authentication.enabled=false
```

### 7.2 TEST Environment

**Configuration File:** `config/application-test.properties`

```properties
# API endpoints
mule.http.listener.port=8081
transaction.service.url=https://transaction-service-test.run.app
keycloak.introspection.url=https://keycloak-test.run.app/auth/realms/bank/protocol/openid-connect/token/introspection
kafka.brokers=kafka-test:9092

# Logging
logging.level.root=INFO

# Security (strict)
api.authentication.enabled=true
```

### 7.3 PROD Environment

**Configuration File:** `config/application-prod.properties`

```properties
# API endpoints (from Secret Manager)
mule.http.listener.port=8081
transaction.service.url=${secret:transaction-service-prod-url}
keycloak.introspection.url=${secret:keycloak-prod-url}
kafka.brokers=${secret:kafka-prod-brokers}

# Logging
logging.level.root=WARN
logging.level.com.altmtrk=INFO

# Security (maximum strictness)
api.authentication.enabled=true
api.rate-limiting.enabled=true
api.tls.required=true
```

---

## 8. Testing Strategy

### 8.1 Unit Tests (MUnit)

**Location:** `src/test/munit/`

**Frameworks:** MUnit 2.x (bundled with Mule)

**Coverage:**
- Transaction flow transformations
- Error handling scenarios
- Policy enforcement
- Schema validation

**Execution:**
```bash
mvn test  # Runs all MUnit tests
```

### 8.2 Integration Tests (Local)

**Setup:** `docker-compose.yml`

**Scope:**
- End-to-end flow verification
- External service mocking (Keycloak, Transaction Service)
- Event publishing to Kafka

**Execution:**
```bash
cd container
docker-compose up
# Run custom test scripts or Postman collections
docker-compose down
```

### 8.3 Integration Tests (Cloud)

**Trigger:** Post-deployment validation in Cloud Run

**Endpoint:** `https://mulesoft-integration-${ENVIRONMENT}.run.app/api/health`

**Assertions:**
- HTTP 200 response
- Keycloak connectivity verified
- Kafka connectivity verified

---

## 9. Monitoring and Observability

### 9.1 Metrics

**Emitted to:** Google Cloud Monitoring

- Request rate (by endpoint, method)
- Latency (p50, p95, p99)
- Error rate (by error type)
- Mule JVM metrics (heap, threads, GC)

### 9.2 Logs

**Destination:** Cloud Logging

**Log Levels:**
- `DEBUG` — Development and troubleshooting
- `INFO` — Normal operations and API calls (with PII masking)
- `WARN` — Recoverable errors (e.g., retry-able failures)
- `ERROR` — Critical failures (service unavailability, security events)

**Example Log Entry:**
```json
{
  "timestamp": "2026-08-25T10:15:32Z",
  "level": "INFO",
  "message": "Transaction flow executed",
  "flowName": "transaction-facade",
  "transactionId": "txn-abc123",
  "duration": 145,
  "endpoint": "/api/transactions",
  "statusCode": 200,
  "userId": "[REDACTED]"
}
```

### 9.3 Health Checks

**Endpoint:** `/api/health`

**Response:**
```json
{
  "status": "UP",
  "checks": {
    "keycloak-connectivity": "UP",
    "kafka-connectivity": "UP",
    "database-connectivity": "UP"
  }
}
```

---

## 10. Checklist for Implementation

### Phase 1: Foundation (Week 1)

- [ ] Create `src/main/mule/` directory structure
- [ ] Define `global-config.xml` with connection factories
- [ ] Create `pom.xml` with Mule Maven plugin
- [ ] Create environment-specific `.properties` files
- [ ] Create `/config/log4j2.xml`

### Phase 2: Flows & Transformations (Week 2-3)

- [ ] Implement `transaction-facade.xml` flow
- [ ] Implement `identity-sync.xml` flow
- [ ] Implement `event-bridge.xml` flow
- [ ] Create DataWeave transformation scripts
- [ ] Define API specifications (RAML)

### Phase 3: Testing & Security (Week 4)

- [ ] Create MUnit tests
- [ ] Create docker-compose.yml for local testing
- [ ] Conduct security review (secrets, auth, TLS)
- [ ] Run CVE scans on dependencies

### Phase 4: CI/CD & Deployment (Week 5)

- [ ] Create `cloudbuild.yaml` for Cloud Build
- [ ] Create Terraform module for Cloud Run deployment
- [ ] Test local image build and push
- [ ] Deploy to DEV environment
- [ ] Verify end-to-end health checks

### Phase 5: Documentation (Week 6)

- [ ] Complete `container/README.md`
- [ ] Complete `ARCHITECTURE.md`
- [ ] Complete `SECURITY.md`
- [ ] Complete `AGENTS.md`
- [ ] Create runbooks for on-call support

---

## 11. Common Issues and Troubleshooting

| Issue | Cause | Solution |
|:---|:---|:---|
| **Failed to pull base image** | Network or registry auth issue | Run `docker login` and ensure Docker daemon is running. |
| **Mule application fails to deploy** | Invalid Mule configuration XML | Validate XML syntax in Anypoint Studio or with `xmllint`. |
| **Database connectivity timeout** | VPC Connector not configured | Ensure Cloud Run has correct VPC Connector ID in Terraform. |
| **Secrets not accessible at runtime** | IAM bindings missing | Verify service account has Secret Manager accessor role. |
| **High memory usage / OOM kills** | Heap size too small | Increase Cloud Run memory from 2GB to 4GB for high-volume flows. |

---

## 12. References

- [MuleSoft Mule Runtime on Docker](https://docs.mulesoft.com/mule-runtime/latest/mule-runtime-installation-task)
- [MuleSoft Deployment to Cloud Run](https://docs.mulesoft.com/cloud-run/)
- [MUnit Testing Framework](https://docs.mulesoft.com/munit/latest/)
- [DataWeave Language Reference](https://docs.mulesoft.com/dataweave/2.4/dataweave-language-intro)
- [Anypoint API Manager](https://docs.mulesoft.com/api-manager/2.x/)
- [GCP Cloud Run Best Practices](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)
- [Terraform GCP Provider (Cloud Run)](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service)

---

## 13. Approval and Sign-Off

| Role | Name | Date | Approval |
|:---|:---|:---|:---|
| Architecture Lead | — | — | ⏳ Pending |
| Security Lead | — | — | ⏳ Pending |
| DevOps Lead | — | — | ⏳ Pending |

---

**Document Version:** 1.0  
**Last Updated:** 2026-08-25  
**Status:** ✅ Container structure and files created; awaiting implementation
