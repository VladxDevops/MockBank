+++
title = "CloudHub vs Runtime Fabric - Comparison & Decision Record"
domain = "mulesoft"
topics = ["mulesoft", "cloudhub", "runtime-fabric", "deployment", "architecture", "decision"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "README.md",
    "MULESOFT_IMPLEMENTATION_PLAN.md",
    "MULESOFT_LEARNING_PATH.md",
    "../../../BNKprojects/7/README.md",
    "../../../BNKprojects/7/SECURITY.md",
    "../../../BNKprojects/7/PROJECT7_DETAILS.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/README.md)  
> **Implementation Plan**: [`MULESOFT_IMPLEMENTATION_PLAN.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/mulesoft/MULESOFT_IMPLEMENTATION_PLAN.md)  
> **Project 7 Details**: [`BNKprojects/7/PROJECT7_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md)

---

# CloudHub vs Runtime Fabric — Comparative Guide & Decision Record

This document summarizes the architectural differences, operational tradeoffs, and decision criteria between MuleSoft CloudHub (managed SaaS runtime) and Runtime Fabric (self-managed Mule runtime on Kubernetes/GKE).

---

## Executive Summary

- **CloudHub (Managed SaaS):** MuleSoft-managed runtime. Fast to adopt, minimal operational burden, regional SaaS offering, suitable for early Phase 1 proof of concept.
- **Runtime Fabric on GKE (Self-managed Kubernetes):** Customer-managed Mule runtime hosted on Google Kubernetes Engine. Provides private network locality, VPC-native connectivity, data sovereignty, and GitOps integration via ArgoCD (Project 6).

---

## Architectural Comparison Matrix

| Dimension | CloudHub 2.0 (Managed SaaS) | Runtime Fabric on GKE (Kubernetes) |
| :--- | :--- | :--- |
| **Deployment Model** | MuleSoft-hosted SaaS infrastructure. | Customer-managed GKE Autopilot / Standard cluster. |
| **Operational Ownership** | MuleSoft handles runtime upgrades and patching. | Customer manages Kubernetes cluster, upgrades, node security. |
| **Network & Locality** | Requires VPN / VPC Peering back to GCP resources. | Direct private VPC subnetwork; native GCP private routing. |
| **Security & Isolation** | Shared SaaS control plane; Anypoint KMS. | Dedicated GKE namespace, Workload Identity, Cloud KMS. |
| **GitOps Integration** | Anypoint CLI / API / Cloud Build pipelines. | Native Kubernetes manifests, Helm, and ArgoCD (Project 6). |
| **Observability** | Anypoint Monitoring dashboards. | Native Cloud Monitoring, Cloud Trace, OpenTelemetry. |
| **Cost Model** | Subscription / vCore licensing; no perpetual free tier. | GKE cluster compute + Anypoint core licensing. |

---

## Decision Record

- **Selected Target:** **Runtime Fabric on GKE** for Project 7 Production Deployments
- **POC Target:** **CloudHub 2.0 / Trial Sandbox** for Phase 1 Rapid Verification
- **Decision Date:** 2026-08-26
- **Owner:** MuleSoft Admin + Architecture Team

### Decision Rationale
1. **Private Locality & Security**: Banking regulations and zero-trust directives require private VPC locality without crossing public ingress boundaries.
2. **GitOps Alignment**: Project 6 (ArgoCD) already provides declarative reconciliation and drift detection across GKE clusters.
3. **Observability**: Direct integration with Google Cloud Operations suite (Cloud Logging, Cloud Trace, OpenTelemetry).

---

## Important Platform Distinctions

### Runtime Fabric vs. Google Cloud Run
- **Runtime Fabric** requires long-running Kubernetes pods with persistent background daemon processes and specialized OS integrations.
- **Google Cloud Run** is a serverless platform designed for stateless, request-driven HTTP containers.
- **Rule:** Mule runtimes (Runtime Fabric) must be deployed to **GKE**, not Cloud Run. Cloud Run is reserved for standard stateless microservices (e.g., Project 2 Transaction Service).

### CloudHub Trial / Cost Clarification
- CloudHub has **no perpetual free tier** for production workloads.
- Time-limited trial or evaluation accounts can be requested from MuleSoft for initial Phase 1 POC experiments.

---

## References

- [MuleSoft: Runtime Fabric Documentation](https://docs.mulesoft.com/runtime-fabric/)
- [MuleSoft: CloudHub 2.0 Documentation](https://docs.mulesoft.com/cloudhub-2/)
- [Project 7 Architecture & Details](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/PROJECT7_DETAILS.md)
