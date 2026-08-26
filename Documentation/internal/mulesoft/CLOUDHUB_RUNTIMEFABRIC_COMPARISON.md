+++
title = "CloudHub vs Runtime Fabric - Comparison"
domain = "mulesoft"
topics = ["mulesoft", "cloudhub", "runtime-fabric", "deployment", "architecture"]
difficulty = "intermediate"
parent = "MULESOFT_IMPLEMENTATION_PLAN.md"
children = []
related = ["MULESOFT_IMPLEMENTATION_PLAN.md", "MULESOFT_LEARNING_PATH.md"]
updated_by = "Codex"
version = "1.0"
+++

# CloudHub vs Runtime Fabric — Comparative Guide

This document summarizes the key differences, pros/cons, and decision criteria between MuleSoft CloudHub (managed SaaS runtime) and Runtime Fabric (self-managed Mule runtime on Kubernetes/GKE).

## Executive Summary

- **CloudHub (Managed SaaS):** MuleSoft-managed runtime. Fast to adopt, minimal operational burden, regional SaaS offering, suitable for organizations preferring a managed platform.
- **Runtime Fabric (Self-managed on K8s/GKE):** Customer-managed Mule runtime that runs on Kubernetes (GKE, on-prem). Provides greater control over network locality, private connectivity, and resource placement at the cost of higher operational overhead.

## Comparison Matrix

- Deployment Model
  - CloudHub: SaaS (MuleSoft hosts runtime). No cluster management.
  - Runtime Fabric: Customer-managed runtime on Kubernetes (supports GKE, on-prem, private cloud).

- Operational Ownership
  - CloudHub: MuleSoft is responsible for runtime patches, upgrades, and platform availability.
  - Runtime Fabric: Customer is responsible for Kubernetes cluster, upgrades, scaling, and node security.

- Network & Connectivity
  - CloudHub: Requires careful private connectivity design (VPC, VPN, CloudHub VPC) to reach internal GCP resources. May rely on MuleSoft-managed VPC peering in some deployments.
  - Runtime Fabric: Runs within customer network (GKE) enabling private ingress, VPC-native connectivity to GCP services, and tighter network controls.

- Security & Compliance
  - CloudHub: Compliant with many enterprise standards; secrets and access controlled via Anypoint. Some organizations with strict network isolation or on-prem requirements may find CloudHub limiting.
  - Runtime Fabric: Enables control over network isolation, private PKI, and custom security hardening (eg. private clusters, node-level controls).

- Scalability & Performance
  - CloudHub: Autoscaling managed by MuleSoft; limits and region-specific behaviors apply. Good for standard workloads.
  - Runtime Fabric: Scalability depends on Kubernetes autoscaling and cluster sizing—offers more predictable locality and custom tuning for high-throughput, low-latency needs.

- Observability & Tooling
  - CloudHub: Built-in Anypoint monitoring and logging; integrates with Anypoint Platform dashboards.
  - Runtime Fabric: You can integrate native Kubernetes/GCP observability tooling (Cloud Monitoring, Prometheus, OpenTelemetry) with finer control.

- Cost Model
  - CloudHub: SaaS subscription-based licensing; predictable OPEX but may be higher for large workloads.
  - Runtime Fabric: Requires infrastructure (GKE) costs and operational staff—higher initial TCO but may be cost-efficient at scale.

- Integration with GitOps / ArgoCD
  - CloudHub: Supports CI/CD via Anypoint pipelines and Cloud Build/Artifact Registry; less direct Kubernetes-native GitOps integration.
  - Runtime Fabric: Well-suited for GitOps (ArgoCD) workflows; leverages Kubernetes manifests, Helm, and native deployment tooling.


## Decision Criteria (Suggested)

1. Choose **CloudHub** when:
   - You want fast time-to-value with minimal operational overhead.
   - You accept MuleSoft-managed runtime and can design secure private connectivity patterns.
   - Licensing and OPEX model fits the organization budget.
   - You do not require strict network locality or Kubernetes-native controls.

2. Choose **Runtime Fabric** when:
   - You require private netwo
rk locality and tight control over cluster/networking.
   - Your organization already uses Kubernetes (GKE) and GitOps workflows (ArgoCD).
   - You have the operational maturity to manage runtime clusters and upgrades.
   - You need custom observability, isolation, or compliance controls beyond CloudHub capabilities.

## Implementation Notes for Altmtrk2026(Mockbank) Bank (Project7)

- For an initial Proof-of-Concept (Phase 1) we recommend **CloudHub 2.0** to minimize setup time and validate integration patterns.
- If private connectivity, latency, or strict data locality requirements appear during Phase 2/3, evaluate **Runtime Fabric** and align with Project6 (ArgoCD) and Project0 (Terraform, GKE provisioning).
- When choosing Runtime Fabric, include Project0 (foundation) early to provision secure GKE clusters, VPCs, and secret management integration.
- For Project7 the team has decided to use **Runtime Fabric** for production deployments to satisfy private-network, compliance, and GitOps integration requirements. See `BNKprojects/7/PROJECT7_DETAILS.md` for the decision record (2026-08-26).
- For an initial Proof-of-Concept (Phase 1) we still recommend **CloudHub 2.0** to minimize setup time and validate integration patterns quickly (CloudHub trial accounts can be used for short POCs).
- If private connectivity, latency, or strict data locality requirements appear during Phase 2/3, fully transition to **Runtime Fabric** and align with Project6 (ArgoCD) and Project0 (Terraform, GKE provisioning).
- When choosing Runtime Fabric, include Project0 (foundation) early to provision secure GKE clusters, VPCs, and secret management integration.


## Additional Notes

- **Runtime Fabric vs Cloud Run:** Runtime Fabric is a Kubernetes-hosted Mule runtime (installed on GKE or other Kubernetes platforms). It does *not* run on Google Cloud Run. Cloud Run is a serverless container platform for stateless workloads and lacks the OS-level, long-running process model and privileged host integrations that Runtime Fabric requires. Mule runtimes (including Runtime Fabric) should be deployed on Kubernetes (GKE) or CloudHub — not Cloud Run.

- **CloudHub cost / free tier:** There is no perpetual no-cost production tier for CloudHub. MuleSoft/Anypoint typically offers time-limited trial or evaluation accounts suitable for POCs; production use requires commercial licensing/subscription. For Phase 1 POC you may request an evaluation/trial from MuleSoft, but plan procurement and licensing for any longer-term use.

## Pros / Cons (Short)

- CloudHub Pros: Fast onboarding, managed upgrades, built-in monitoring, less ops.
- CloudHub Cons: Less control over network locality; potential cost premium.
- Runtime Fabric Pros: Full control, Kubernetes-native tooling, better private network fit.
- Runtime Fabric Cons: Higher operational burden; requires Kubernetes expertise.

## References

- MuleSoft: CloudHub documentation — https://docs.mulesoft.com/runtime-manager/cloudhub
- MuleSoft: Runtime Fabric documentation — https://docs.mulesoft.com/runtime-fabric/
