# Container Building & Deployment Guide - Project 7 (MuleSoft)


## Quick Start


### Local Build & Test

```bash
# 1. Navigate to project root
cd /Bank/BNKprojects/7

# 2. Compile and package Mule application
mvn clean package -DskipTests

# 3. Build Docker image
docker build -t mulesoft-integration:latest -f container/Dockerfile .

# 4. Run locally (full stack with docker-compose)
cd container
docker-compose up -d

# 5. Verify health
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


### Cloud Run Deployment

Deployment is managed via Terraform in `terraform/modules/project7/main.tf`:

```bash
# From terraform/ directory
terraform plan -var-file="dev.tfvars" -target=module.project7
terraform apply -var-file="dev.tfvars" -target=module.project7
```

---


## File Descriptions

### Dockerfile

**Purpose:** Multi-stage Docker build for Mule application

**Stages:**
1. **Builder Stage:** Compiles Maven project, creates JAR
2. **Runtime Stage:** Uses `mulesoft/mule:4.4-java11-alpine` base image

**Security Features:**
- Non-root user (`mule`)
- Minimal attack surface (Alpine Linux)
- Build-time compilation (no secrets in final image)

**Build Arguments:**
None required; all values are set at runtime via environment variables.

**Exposed Ports:**
- `8081` — Mule HTTP listener (default)
- `8888` — Mule management port (optional, commented out)

### .dockerignore

**Purpose:** Exclude unnecessary files from build context

**Key Exclusions:**
- Git metadata (`.git/`, `.gitignore`)
- Environment secrets (`.env`, credentials files)
- Development files (`node_modules/`, `.idea/`, `.vscode/`)
- Build artifacts (`target/`, `*.log`)
- CI/CD scripts (`cloudbuild.yaml`, `docker-compose.yml`)

**Effect:** Reduces build context size by ~95%, speeds up builds.

### Configuration Files (config/)

**application-dev.properties:**
```properties
mule.http.listener.port=8081
logging.level.root=DEBUG
api.authentication.enabled=false
```

**application-prod.properties:**
```properties
mule.http.listener.port=8081
logging.level.root=WARN
api.authentication.enabled=true
```

**log4j2.xml:**
Configures logging appenders (console, file) and levels per module.

### docker-compose.yml (Optional)

**Purpose:** Local full-stack testing (Mule + dependencies)

**Services:**
- `mule` — Mule application (built from Dockerfile)
- `postgres` — PostgreSQL database (for local testing)
- `kafka` — Apache Kafka (for event testing)

**Usage:**
```bash
cd container
docker-compose up -d       # Start all services
docker-compose logs -f     # Follow logs
docker-compose down -v     # Tear down and remove volumes
```

---

## Environment Variables

### Runtime Configuration

Set these at Cloud Run deployment time (via Terraform or `gcloud run deploy`):

| Variable | Purpose | Example |
|:---|:---|:---|
| `MULE_ENV` | Environment identifier | `cloud`, `dev`, `prod` |
| `ANYPOINT_ENVIRONMENT` | Anypoint Platform environment | `development`, `production` |
| `ANYPOINT_ORGANIZATION_ID` | Anypoint org UUID | `12345678-abcd-ef01-2345-6789abcdef01` |
| `DB_HOST` | Database hostname | `cloudsql-postgres.c.dev-mockbank.internal` |
| `DB_PASSWORD` | Database password (via Secret Manager) | `${secret:db-password}` |
| `KAFKA_BROKERS` | Kafka broker addresses | `kafka-broker-1:9092,kafka-broker-2:9092` |
| `PUBSUB_PROJECT_ID` | GCP project for Pub/Sub | `dev-mockbank` |
| `KEYCLOAK_URL` | Keycloak base URL | `https://keycloak-prod.run.app` |
| `TRANSACTION_SERVICE_URL` | Project 2 service URL | `https://transaction-service-prod.run.app` |

### Java Runtime Tuning

```bash
# In Dockerfile (already set):
ENV JAVA_OPTS="-server -Xmx1024m -Xms1024m -XX:+UseG1GC -XX:+UseStringDeduplication"
```

---

## Image Naming Convention

### Docker Image URI

```
${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}
```

### Example

```
us-south1-docker.pkg.dev/dev-mockbank/dev-mongodb-atlas-container/mulesoft-integration:v1.0.0
```

### Tag Strategies

| Strategy | Example | Use Case |
|:---|:---|:---|
| Semantic Versioning | `v1.0.0`, `v1.0.1-rc1` | Release builds |
| Git Commit SHA | `abc123def456` | Development builds |
| Build ID | `20260825-001` | CI/CD automation |
| `latest` | `latest` | Development only (never for production) |

---

## Security Checklist

- [ ] No secrets (`.env`, `*.key`, `credentials.json`) in Docker build context
- [ ] `.dockerignore` excludes all sensitive files
- [ ] Dockerfile uses non-root user (`USER mule`)
- [ ] Base image is scanned for CVEs: `trivy image mulesoft/mule:4.4-java11-alpine`
- [ ] Final image is scanned: `trivy image <IMAGE_URI>`
- [ ] Secrets are injected at runtime from GCP Secret Manager
- [ ] Cloud Run has VPC Connector configured (private network access)
- [ ] Cloud Run has no `allUsers` IAM binding (requires authentication)
- [ ] Health checks are configured with appropriate initial delay (40-60s)

---

## Troubleshooting

### Build Failures

**Error: "Cannot find mule-maven-plugin"**
```bash
# Solution: Ensure Maven can access Mule repositories
# Add to settings.xml or run with -U flag
mvn clean package -DskipTests -U
```

**Error: "Failed to pull image 'mulesoft/mule:4.4-java11-alpine'"**
```bash
# Solution: Check Docker Hub credentials
docker login
# Or use private registry with auth
```

### Runtime Issues

**Logs show "Connection refused" to Keycloak**
```bash
# Verify VPC Connector is attached to Cloud Run
gcloud run services describe mulesoft-integration \
    --format='value(status.template.spec.vpcAccess.connector)'

# Verify Secret Manager secret is accessible
gcloud secrets versions access latest --secret="keycloak-url"
```

**Health check fails with 500 error**
```bash
# Check Cloud Run logs
gcloud run services log read mulesoft-integration --limit 50

# Verify environment variables are set
gcloud run services describe mulesoft-integration \
    --format='value(spec.template.spec.containers[0].env)'
```

**OutOfMemory errors**
```bash
# Increase Cloud Run memory allocation in Terraform
resource "google_cloud_run_service" "mule" {
  # Change from 2GB to 4GB
  template {
    spec {
      containers {
        memory = "4Gi"
      }
    }
  }
}
```

---

## Performance Optimization Tips

### 1. Multi-Stage Build Optimization
- Builder stage caches dependencies (Maven)
- Runtime stage uses minimal base image (Alpine)
- Total image size: ~500-700 MB (vs 1.5-2GB with full JDK)

### 2. Layer Caching
```dockerfile
# Good: Dependencies change less frequently than source
COPY pom.xml ./
RUN mvn dependency:resolve  # Cache layer
COPY src/ ./src/
RUN mvn package             # Rebuilds only if src/ changes
```

### 3. Cloud Run Configuration
- **Memory:** 2GB (minimum for Mule); increase for high-volume
- **CPU:** 2 CPU (sufficient for I/O-bound operations)
- **Concurrency:** 80 (default; tune based on latency)
- **Startup CPU Boost:** Enabled (reduces cold-start time)

### 4. Container Registry Optimization
- Use regional repositories (`us-south1-docker.pkg.dev`) for faster pulls
- Enable **Vulnerability Scanning** in Artifact Registry
- Set image retention policy (e.g., delete untagged images after 30 days)

---

## Deployment Matrix

| Environment | Base URL | Region | Memory | Concurrency | Deployment |
|:---|:---|:---|:---|:---|:---|
| **DEV** | `mulesoft-dev.run.app` | us-south1 | 2GB | 50 | Manual / On-commit |
| **TEST** | `mulesoft-test.run.app` | us-south1 | 2GB | 80 | Automated on tag |
| **PROD** | `mulesoft-prod.run.app` | us-south1, europe-west1 | 4GB | 100 | Manual approval |

---

## Related Documentation

- [CONTAINER_STRUCTURE_PLAN.md](../CONTAINER_STRUCTURE_PLAN.md) — Detailed file structure and planning
- [../ARCHITECTURE.md](../ARCHITECTURE.md) — Technical architecture and integration patterns
- [../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md](../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md) — MuleSoft strategic plan
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [MuleSoft Documentation](https://docs.mulesoft.com/)

---

**Version:** 1.0  
**Last Updated:** 2026-08-25  
**Status:** ✅ Container files generated; ready for application implementation
