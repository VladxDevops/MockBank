+++
title = "Container Structure and Build Planning for Project 7 (MuleSoft)"
domain = "mulesoft-containers"
topics = ["containerization", "mulesoft", "docker", "runtime-fabric", "deployment"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "README.md",
    "PROJECT7_DETAILS.md",
    "SECURITY.md",
    "AGENTS.md",
    "CHECKLIST.md",
    "../../Documentation/internal/Architecture.md",
    "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Security Policy**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)  
> **MuleSoft Plan**: [`../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)

---

# Container Structure and Build Planning - Project 7 (MuleSoft Integration Layer)

## Overview

This document defines the Docker container structure, build process, and required files for deploying MuleSoft Mule applications in Project 7. The container is optimized for local development verification, automated CI/CD packaging via Cloud Build, and deployment to Runtime Fabric on GKE with zero-trust security and operational best practices.

---

## 1. Directory Structure

```text
BNKprojects/7/
├── README.md                                 # Project overview and integration points
├── CONTAINER_STRUCTURE_PLAN.md              # This file - container build planning
├── PROJECT7_DETAILS.md                      # Project scope, RACI, and deliverables
├── SECURITY.md                              # MuleSoft-specific security policies (Created)
├── AGENTS.md                                # Deployment automation protocols (Created)
├── CHECKLIST.md                             # Phased implementation checklist
├── IMPLEMENTATION_STATUS.md                 # Status tracker and environment variables
├── .env.example                             # Environment variables template (Created)
├── .env.local.example                       # Local development env template (Created)
├── container/
│   ├── Dockerfile                           # Multi-stage build for Mule applications
│   ├── .dockerignore                        # Exclude dev/test files from build context
│   ├── .gitignore                           # Git ignore for container directory
│   ├── README.md                            # Container build and deployment guide
│   ├── README-internal.md                   # Internal container guide
│   ├── config/                              # Runtime configuration files
│   │   ├── application-dev.properties       # DEV environment properties
│   │   ├── application-test.properties      # TEST environment properties
│   │   ├── application-prod.properties      # PROD environment properties
│   │   └── log4j2.xml                       # Logging configuration
│   └── policies/                            # MuleSoft API Manager policies
│       ├── rate-limiting-policy.yaml        # Rate limiting policy definition
│       └── oauth-policy.yaml                # OAuth token validation policy
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── health-api.xml               # Health check flow
│   │   │   ├── flows/
│   │   │   │   ├── transaction-facade.xml   # Facade for Project 2 (Transaction Service)
│   │   │   │   ├── identity-sync.xml        # Integration with Project 1 (Keycloak)
│   │   │   │   └── event-bridge.xml         # Bridge to Project 5 (Pub/Sub/Kafka)
│   │   │   └── global-config.xml            # Global configuration elements
│   │   └── resources/
│   │       ├── application.properties       # Default properties
│   │       ├── dataweave/                   # DataWeave transformation scripts
│   │       └── schemas/                     # JSON Schemas
│   └── test/
│       └── munit/                           # MUnit test flows
└── pom.xml                                  # Maven project descriptor
```

---

## 2. File Descriptions and Status

### Core Container Files

| File | Purpose | Status |
|:---|:---|:---|
| **Dockerfile** | Multi-stage build using `mulesoft/mule:4.4-java11-alpine` base image. Compiles Mule app, packages JAR, and deploys to runtime. | ✅ Created |
| **.dockerignore** | Excludes 100+ file patterns (secrets, `.env`, logs, IDE files, build artifacts) to minimize build context. | ✅ Created |
| **.env.example** | Master environment variable template. | ✅ Created |
| **.env.local.example** | Local developer template. | ✅ Created |

### Project Governance & Protocols

| File | Purpose | Status |
|:---|:---|:---|
| **README.md** | Subdomain overview, architecture alignment, and navigation map. | ✅ Created |
| **PROJECT7_DETAILS.md** | Comprehensive technical details, RACI matrix, and roadmap. | ✅ Created |
| **SECURITY.md** | Level 3 security policies: token validation, PII masking, secrets handling. | ✅ Created |
| **AGENTS.md** | AI assistant and CI/CD bot guidelines. | ✅ Created |
| **CHECKLIST.md** | Phased milestone tracker and decision log. | ✅ Created |
| **IMPLEMENTATION_STATUS.md** | Configuration tracking and implementation status. | ✅ Created |

---

## 3. Build & Deployment Architecture

### 3.1 Local Development Build

```bash
cd /home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7

# 1. Compile and package (creates target/*.jar)
mvn clean package -DskipTests

# 2. Build Docker image locally
docker build -t mulesoft-integration:latest -f container/Dockerfile .

# 3. Verify health endpoint
curl http://localhost:8081/api/health
```

### 3.2 Cloud Build CI/CD Packaging

- **Trigger:** Push to `main` branch in `/BNKprojects/7/`
- **Steps:**
  1. Compile & test: `mvn test` (MUnit)
  2. Security scan: `trivy` container scanning
  3. Artifact Registry push: Tagged with commit SHA
  4. GitOps Sync: ArgoCD (Project 6) synchronizes Runtime Fabric on GKE deployment manifests

### 3.3 Runtime Deployment Strategy

- **Production:** **Runtime Fabric on GKE** (Kubernetes-hosted Mule runtime) managed via Project 6 (ArgoCD) and Project 0 (GKE cluster provisioning).
- **POC Verification:** CloudHub 2.0 evaluation account or local Docker container.
- **Serverless Microservices:** GCP Cloud Run is reserved for standard stateless backend microservices (e.g., Project 2), not Runtime Fabric.

---

## 4. Security Considerations

- **Non-Root Execution:** Container runs under unprivileged `mule` user (UID 1000).
- **Zero Unauthenticated Access:** No `allUsers` ingress bindings permitted.
- **Secrets Management:** Secrets managed strictly in GCP Secret Manager and injected at runtime via Workload Identity Federation (WIF).
- **PII Masking:** Strict log sanitization in all DataWeave scripts.

---

## 5. Related Documentation

- [`PROJECT7_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md) — Technical details and roadmap
- [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md) — Security policy
- [`AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/AGENTS.md) — Automation protocols
- [`Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md) — Comparative guide
