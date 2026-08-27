+++
title = "MuleSoft Integration Subdomain Index"
domain = "mulesoft"
topics = ["index", "mulesoft", "anypoint-platform", "integration", "api-led-connectivity", "runtime-fabric"]
difficulty = "beginner"
parent = "../README.md"
children = [
    "MULESOFT_IMPLEMENTATION_PLAN.md",
    "MULESOFT_LEARNING_PATH.md",
    "CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md"
]
related = [
    "../../../BNKprojects/7/README.md",
    "../../../BNKprojects/7/SECURITY.md",
    "../../../BNKprojects/7/PROJECT7_DETAILS.md",
    "../Architecture.md",
    "../INFRASTRUCTURE.md",
    "../../../BNKprojects/5/PUBSUB.md",
    "../../../BNKprojects/6/README.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`../README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **Implementation Project**: [`BNKprojects/7/README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md)  
> **Global Agent Protocols**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)  
> **Security Prime Directive**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)

---

# MuleSoft Integration Subdomain Index

This directory is the internal learning and planning hub for introducing MuleSoft Anypoint Platform into the Altmtrk2026 Bank Platform.

## Decision Summary

MuleSoft is implemented as **Project 7: MuleSoft Integration Layer** under `BNKprojects/7/`, treated as a dedicated **integration-layer domain**, not as part of Project 0 foundation infrastructure.

Project 0 and Terraform remain responsible for shared infrastructure prerequisites (VPC networking, service accounts, IAM bindings, GKE clusters, DNS, and GCP Secret Manager entries). Project 7 owns application integration logic, API mediation, transformations, API Manager policies, and Runtime Fabric deployment manifests.

Recommended repository placement:

| Concern | Repo Location | Rationale |
| :--- | :--- | :--- |
| MuleSoft learning, architecture notes, and comparative guides | `Documentation/internal/mulesoft/` | Internal education, architectural decisions, and platform policies. |
| MuleSoft implementation project, security policy, and manifests | `BNKprojects/7/` | Encapsulates the integration layer, flows, and configuration. |
| GCP connectivity, DNS, IAM, GKE, and secrets | `terraform/` and Project 0 modules | Shared infrastructure foundations. |
| Mule app source code, API specs, and MUnit tests | `BNKprojects/7/src/` | Deployable integration artifacts. |

## Documentation Index

| Document | Purpose | Start Here When |
| :--- | :--- | :--- |
| [`MULESOFT_LEARNING_PATH.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md) | Beginner learning path for MuleSoft concepts and tools. | You are onboarding onto MuleSoft fundamentals. |
| [`MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md) | Architecture decision, phases, bank integration patterns, and guardrails. | You are planning how MuleSoft integrates across Projects 1-7. |
| [`CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md) | Architectural comparison and decision record between CloudHub and Runtime Fabric. | You need deployment model guidance and trade-offs. |
| [`BNKprojects/7/README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/README.md) | Implementation project anchor for the MuleSoft integration layer. | You are creating API specs, Mule apps, or deployment automation. |
| [`BNKprojects/7/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/SECURITY.md) | MuleSoft integration layer security and access control policy. | You are verifying token validation, PII masking, or secret management. |

## Primary Integration Targets

1. **Project 1 - Identity / Keycloak**: Keycloak-issued OAuth2/OIDC token introspection and JWT claim policies.
2. **Project 2 - Core Banking Backend**: Controlled system API facades and DataWeave contract normalization.
3. **Project 4 - Actimize**: Mediate AML and fraud decision APIs once event schemas are stable.
4. **Project 5 - Kafka / Pub/Sub Event Streaming**: Bridge event-driven flows for partner ingress, event normalization, and publishing to the bank event backbone.
5. **Project 6 - ArgoCD GitOps**: Declarative deployment synchronization for Runtime Fabric on GKE workloads.

## Current Architectural Status

- **Status:** **Planning / Initial Implementation (Phase 0-1)**
- **Deployment Decision:** **Runtime Fabric on GKE** selected for production deployments (Decision Date: 2026-08-26). CloudHub evaluation accounts used for Phase 1 proof of concept.
- **Serverless Boundary:** Google Cloud Run is utilized for stateless microservices (Project 2); GKE hosts Runtime Fabric.

## Observability & OpenTelemetry Alignment

MuleSoft and OpenTelemetry are complementary:
- MuleSoft provides API mediation, routing, and data transformation.
- OpenTelemetry provides vendor-neutral instrumentation (traces, metrics, logs) across services.
- Google Cloud Monitoring, Cloud Trace, and Cloud Logging provide the centralized observability backends.

## Official References

- MuleSoft Runtime Manager: <https://docs.mulesoft.com/runtime-manager/>
- Runtime Fabric Overview: <https://docs.mulesoft.com/runtime-fabric/>
- CloudHub Overview: <https://docs.mulesoft.com/runtime-manager/cloudhub>
- API Manager Policies: <https://docs.mulesoft.com/api-manager/latest/getting-started-proxy>
- DataWeave Reference: <https://docs.mulesoft.com/dataweave/latest/>

<!-- AI RETRIEVAL TRIGGERS:
- Where is MuleSoft documented? -> Documentation/internal/mulesoft/README.md
- Is MuleSoft infrastructure or a project? -> Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md
- How do I learn MuleSoft for this bank repo? -> Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md
- What is the deployment model comparison? -> Documentation/internal/mulesoft/CLOUDHUB_RUNTIMEFABRIC_COMPARISON.md
- Where is Project 7 security documented? -> BNKprojects/7/SECURITY.md
-->
