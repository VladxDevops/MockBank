+++
title = "MuleSoft Integration Subdomain Index"
domain = "mulesoft"
topics = ["index", "mulesoft", "anypoint-platform", "integration", "api-led-connectivity"]
difficulty = "beginner"
parent = "../README.md"
children = ["MULESOFT_IMPLEMENTATION_PLAN.md", "MULESOFT_LEARNING_PATH.md"]
related = ["../../../BNKprojects/7/README.md", "../Architecture.md", "../../../BNKprojects/5/PUBSUB.md"]
updated_by = "Codex"
version = "0.1"
+++

> **Parent**: [`../README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **Implementation Project**: [`BNKprojects/7/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/7/README.md)

---


# MuleSoft Integration Subdomain Index

This directory is the internal learning and planning hub for introducing MuleSoft Anypoint Platform into the "MockBank" Bank Platform.

## Decision Summary

MuleSoft should be treated as a new **integration-layer project/subproject**, not as part of Project 0 foundation infrastructure.

Project 0 and Terraform still own infrastructure prerequisites that MuleSoft depends on, such as VPC connectivity, service accounts, IAM bindings, DNS, Secret Manager entries, firewall allow-lists, and private endpoint routing. MuleSoft itself belongs in a separate project domain because it introduces application integration logic, API mediation, transformations, policies, and runtime operations.

Recommended repository placement:

| Concern | Repo Location | Rationale |
| :--- | :--- | :--- |
| MuleSoft learning, design rules, and architecture notes | `Documentation/internal/mulesoft/` | Internal education and architectural policy. |
| MuleSoft implementation plan and integration assets | `BNKprojects/7/` | Keeps the integration layer separate from infrastructure and bank services. |
| GCP connectivity, DNS, IAM, secrets, and allow-listing | `terraform/` and Project 0 modules | These are shared infrastructure dependencies. |
| Mule app source code, API specs, and tests | Future `BNKprojects/7/apps/`, `BNKprojects/7/apis/`, `BNKprojects/7/tests/` | Keeps deployable integration artifacts together. |

## Documentation Index

| Document | Purpose | Start Here When |
| :--- | :--- | :--- |
| [`MULESOFT_LEARNING_PATH.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md) | Beginner learning path for MuleSoft concepts and tools. | You have not used MuleSoft before. |
| [`MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md) | Architecture decision, phases, bank integration patterns, and guardrails. | You are planning how MuleSoft fits into Projects 1-7. |
| [`BNKprojects/7/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/7/README.md) | Implementation project anchor for the MuleSoft integration layer. | You are ready to create API specs, Mule apps, or deployment automation. |

## First Integration Targets

1. **Project 1 - Identity / Keycloak**: Use Keycloak-issued OAuth2/OIDC tokens for API access patterns and policy alignment.
2. **Project 2 - Core Banking Backend**: Expose controlled system APIs around transaction service operations.
3. **Project 5 - Kafka / Pub/Sub Event Streaming**: Bridge event-driven flows where MuleSoft is useful for API mediation, transformation, partner ingress, or SaaS integration.
4. **Project 4 - Actimize**: Route fraud and AML events to Actimize-facing APIs once event schemas are stable.

## Current Status

Status: **Planning / Not Implemented**

No MuleSoft runtime, CloudHub deployment, Runtime Fabric deployment, Anypoint API Manager policy, or Mule app source has been added yet. This documentation only establishes the learning path, architecture boundary, and repository placement.

## Observability and Platform Alignment

MuleSoft and OpenTelemetry should be considered complementary in the same bank architecture.

- MuleSoft provides the integration and transformation layer between APIs, systems, and partner channels.
- OpenTelemetry provides the instrumentation standard to observe those interactions in a consistent way.
- GCP Monitoring, Cloud Trace, and Cloud Logging remain the operational backends for alerting and visualization.

For this repository, the practical guidance is to keep MuleSoft design decisions and GCP observability decisions separate but aligned:

1. define the API and integration flows first
2. identify the critical transactions that traverse MuleSoft
3. attach traceable IDs and correlation metadata to those requests
4. ensure telemetry captures latency, faults, retries, policy denials, and transformation errors
5. keep all sensitive payload content out of logs and traces

This keeps the integration layer manageable without sacrificing security, diagnostics, or platform observability.

## Official References

- MuleSoft Runtime Manager: <https://docs.mulesoft.com/runtime-manager/>
- CloudHub overview: <https://docs.mulesoft.com/runtime-manager/cloudhub>
- Deployment options: <https://docs.mulesoft.com/runtime-manager/deployment-strategies>
- Design Center: <https://docs.mulesoft.com/design-center/>
- API Manager getting started: <https://docs.mulesoft.com/api-manager/latest/getting-started-proxy>
- Secure configuration properties: <https://docs.mulesoft.com/mule-runtime/latest/secure-configuration-properties>

<!-- AI RETRIEVAL TRIGGERS:
- Where is MuleSoft documented? -> Documentation/internal/mulesoft/README.md
- Is MuleSoft infrastructure or a project? -> Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md
- How do I learn MuleSoft for this bank repo? -> Documentation/internal/mulesoft/MULESOFT_LEARNING_PATH.md
-->
