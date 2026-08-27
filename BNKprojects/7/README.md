+++
title = "Project 7: MuleSoft Integration Layer"
domain = "mulesoft"
topics = ["mulesoft", "integration", "api-led-connectivity", "anypoint-platform", "project7", "runtime-fabric"]
difficulty = "beginner"
parent = "../README.md"
children = [
    "PROJECT7_DETAILS.md",
    "SECURITY.md",
    "AGENTS.md",
    "CHECKLIST.md",
    "CONTAINER_STRUCTURE_PLAN.md",
    "IMPLEMENTATION_STATUS.md",
    "container/README.md"
]
related = [
    "../../Documentation/internal/mulesoft/README.md",
    "../../Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md",
    "../../Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md",
    "../1/README.md",
    "../2/container/README.md",
    "../5/PUBSUB.md",
    "../6/README.md"
]
updated_by = "AI Context Specialist"
version = "1.0"
+++

> **Parent**: [`../README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/README.md)  
> **MuleSoft Internal Hub**: [`Documentation/internal/mulesoft/README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/README.md)  
> **Global Policy**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)  
> **Security Directives**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)

---

# Project 7: MuleSoft Integration Layer (`BNKprojects/7/`)

Project 7 is the home for MuleSoft Anypoint Platform integration assets for the Altmtrk2026 Bank Platform.

Status: **Planning / Initial Implementation (Phase 0-1)**  
Deployment Target: **Runtime Fabric on GKE** (Selected for Production per 2026-08-26 decision; CloudHub trial for POCs)

## Scope

Project 7 owns MuleSoft-specific implementation artifacts:

- API specifications for MuleSoft-managed APIs (RAML / OpenAPI).
- Mule application source code (flows, sub-flows, configurations).
- DataWeave mappings and reusable transformations.
- MUnit tests and verification suites.
- API Manager policy documentation and schemas.
- Deployment manifests and notes for Runtime Fabric on GKE and Anypoint Platform.

Project 7 does not own GCP foundation infrastructure. Terraform and Project 0 remain responsible for shared cloud resources, network paths, VPC connectors, IAM service accounts, DNS, and secrets required for MuleSoft connectivity.

## Initial Integration Candidates

| Bank Project | MuleSoft Role |
| :--- | :--- |
| **Project 1 - Keycloak Identity** | Align API authentication and authorization with OIDC token introspection and claims validation policies. |
| **Project 2 - Transaction Service** | Provide a controlled API facade, rate limiting, and request/response contract normalization. |
| **Project 4 - Actimize** | Mediate AML/fraud integrations after event contracts and decision schemas are stable. |
| **Project 5 - Kafka / Pub/Sub** | Support partner ingress, transformation, and API-to-event bridging into the event backbone. |
| **Project 6 - ArgoCD** | GitOps integration for Runtime Fabric on GKE deployment manifests and continuous sync. |

## Documentation & Directory Navigation

| Document / Directory | Description | Link |
| :--- | :--- | :--- |
| **`PROJECT7_DETAILS.md`** | Deep-dive technical specifications, RACI matrix, architecture decisions, and roadmap | [`PROJECT7_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md) |
| **`SECURITY.md`** | Zero-trust security policy, OIDC token validation, PII masking, and Secret Manager standards | [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md) |
| **`AGENTS.md`** | AI Agent protocols and CI/CD automation rules | [`AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/AGENTS.md) |
| **`CHECKLIST.md`** | Phased implementation checklist from Phase 0 to Phase 5 | [`CHECKLIST.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CHECKLIST.md) |
| **`CONTAINER_STRUCTURE_PLAN.md`** | Container structure, build planning, and dependency configuration | [`CONTAINER_STRUCTURE_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/CONTAINER_STRUCTURE_PLAN.md) |
| **`IMPLEMENTATION_STATUS.md`** | Environment configuration and implementation status tracking | [`IMPLEMENTATION_STATUS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/IMPLEMENTATION_STATUS.md) |
| **`container/`** | Multi-stage Dockerfile, .dockerignore, and container documentation | [`container/README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/container/README.md) |

## Planned Source Layout

```text
BNKprojects/7/
  README.md
  PROJECT7_DETAILS.md
  SECURITY.md
  AGENTS.md
  CHECKLIST.md
  CONTAINER_STRUCTURE_PLAN.md
  IMPLEMENTATION_STATUS.md
  container/
    Dockerfile
    .dockerignore
    README.md
    config/
  src/
    main/mule/
    main/resources/
    test/munit/
```

## First Milestone (Phase 1 POC)

Build a non-sensitive `bank-integration-health-api` proof of concept before touching production-like financial workflows.

Minimum acceptance criteria:
1. No production credentials in code or repository.
2. No real customer data or unmasked PII.
3. Local-only or sandbox deployment (CloudHub trial or local container).
4. PII-safe logs and correlation IDs.
5. MUnit tests for routing and transformation basics (>= 80% coverage).

## Required Reading

1. [`Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md)
2. [`Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)
3. [`Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md)
4. [`BNKprojects/7/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md)
5. [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)
