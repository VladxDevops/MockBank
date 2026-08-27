+++
title = "Project 7: Internal Container Building & Deployment Guide"
domain = "mulesoft-containers"
topics = ["containers", "docker", "mulesoft", "cloudbuild", "runtime-fabric", "internal"]
difficulty = "intermediate"
parent = "../README.md"
children = []
related = ["README.md", "../PROJECT7_DETAILS.md", "../SECURITY.md", "../CONTAINER_STRUCTURE_PLAN.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`../README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Security Policy**: [`../SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)  
> **Container Plan**: [`../CONTAINER_STRUCTURE_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CONTAINER_STRUCTURE_PLAN.md)

---

# Container Building & Deployment Guide - Project 7 (MuleSoft)

## Quick Start

### Local Build & Test

```bash
# 1. Navigate to project root
cd /home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7

# 2. Compile and package Mule application
mvn clean package -DskipTests

# 3. Build Docker image locally
docker build -t mulesoft-integration:latest -f container/Dockerfile .

# 4. Run locally (full stack with docker-compose)
cd container
docker-compose up -d

# 5. Verify health endpoint
curl http://localhost:8081/api/health

# 6. View logs
docker-compose logs -f mule

# 7. Stop
docker-compose down -v
```

### Cloud Build (GCP CI/CD)

```bash
# Submit build to Cloud Build (from BNKprojects/7 root)
gcloud builds submit --config container/cloudbuild.yaml .

# Monitor build in console
gcloud builds log --stream <BUILD_ID>
```

---

## File Descriptions

### Dockerfile

**Purpose:** Multi-stage Docker build for Mule application

**Stages:**
1. **Builder Stage:** Compiles Maven project, creates JAR
2. **Runtime Stage:** Uses `mulesoft/mule:4.4-java11-alpine` base image

**Security Features:**
- Non-root user (`USER mule`)
- Minimal attack surface (Alpine Linux)
- Build-time compilation (no secrets in final image)

**Exposed Ports:**
- `8081` — Mule HTTP listener (default)
- `8888` — Mule management port (optional)

### .dockerignore

**Purpose:** Exclude unnecessary files from build context

**Key Exclusions:**
- Git metadata (`.git/`, `.gitignore`)
- Environment secrets (`.env`, credentials files)
- Development files (`node_modules/`, `.idea/`, `.vscode/`)
- Build artifacts (`target/`, `*.log`)
- CI/CD scripts (`cloudbuild.yaml`, `docker-compose.yml`)

---

## Environment Variables

### Runtime Configuration

Set these dynamically at runtime via GCP Secret Manager or Kubernetes ConfigMaps:

| Variable | Purpose | Example |
|:---|:---|:---|
| `MULE_ENV` | Environment identifier | `cloud`, `dev`, `prod` |
| `ANYPOINT_ENVIRONMENT` | Anypoint Platform environment | `development`, `production` |
| `ANYPOINT_ORGANIZATION_ID` | Anypoint org UUID | `12345678-abcd-ef01-2345-6789abcdef01` |
| `DB_HOST` | Database hostname | `cloudsql-postgres.internal` |
| `DB_PASSWORD` | Database password (via Secret Manager) | `${secret:db-password}` |
| `KAFKA_BROKERS` | Kafka broker addresses | `kafka-broker-1:9092,kafka-broker-2:9092` |
| `PUBSUB_PROJECT_ID` | GCP project for Pub/Sub | `dev-mockbank` |
| `KEYCLOAK_URL` | Keycloak base URL | `https://keycloak-prod.run.app` |
| `TRANSACTION_SERVICE_URL` | Project 2 service URL | `https://transaction-service-prod.run.app` |

---

## Security Checklist

- [x] No secrets (`.env`, `*.key`, `credentials.json`) in Docker build context
- [x] `.dockerignore` excludes all sensitive files
- [x] Dockerfile uses non-root user (`USER mule`)
- [ ] Base image is scanned for CVEs: `trivy image mulesoft/mule:4.4-java11-alpine`
- [ ] Final image is scanned: `trivy image <IMAGE_URI>`
- [ ] Secrets are injected at runtime from GCP Secret Manager
- [ ] Runtime Fabric has VPC isolation configured (private network access)
- [ ] Ingress has no `allUsers` IAM binding (requires authentication)
- [ ] Health checks are configured with appropriate initial delay (40-60s)

---

## Related Documentation

- [`../CONTAINER_STRUCTURE_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CONTAINER_STRUCTURE_PLAN.md) — Detailed file structure and planning
- [`../PROJECT7_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md) — Technical specifications
- [`../SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md) — Security policies
- [`../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md) — MuleSoft strategic plan
