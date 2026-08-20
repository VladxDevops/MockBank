+++
title = "Project6: ArgoCD Technical Architecture & Strategy"
domain = "gitops"
topics = ["argocd-details", "app-of-apps", "kustomize", "gke-autopilot", "continuous-delivery"]
difficulty = "advanced"
parent = "README.md"
children = []
related = ["SECURITY.md", "AGENTS.md", "CHECKLIST.md", "../../Documentation/internal/SECURITY.md"]
updated_by = "AI Knowledge Engineer"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/README.md)  
> **Global Policy**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)

---

# Project6: ArgoCD Technical Architecture & Strategy

## 1. Overview & Business Rationale

Project6 implements a **Kubernetes-Native GitOps Engine** utilizing **ArgoCD** hosted on Google Kubernetes Engine (GKE Autopilot).

### Hybrid Continuous Delivery Strategy
The Altmtrk2026 Bank Platform employs a dual-engine CD strategy:
1. **Google Cloud Deploy:** Used for serverless Cloud Run deployments (e.g., Keycloak identity service, Cloud Run microservices).
2. **ArgoCD GitOps Engine:** Used for Kubernetes workloads requiring stateful sets, complex microservice graphs, event streaming infrastructure (Kafka), and automated drift detection across clusters.

---

## 2. Core Architectural Principles

### A. Git as the Single Source of Truth
All cluster configurations, application definitions, network policies, and runtime parameters are declared in git manifests (`BNKprojects/6/apps/` and `BNKprojects/6/manifests/`). Manual state changes via `kubectl` or Web UI are explicitly prohibited and automatically reverted by ArgoCD reconciliation loops.

### B. App-of-Apps Pattern
Project6 utilizes the **App-of-Apps pattern** to orchestrate application deployments:
- **Root Application (`apps/root-app.yaml`):** A master ArgoCD `Application` resource that watches `BNKprojects/6/apps/base/` and automatically provisions/manages child applications.
- **Child Applications:** Declarative manifests defining microservice deployments for Project1 (Identity), Project2 (Core Banking), and Project 5 (Kafka Event Pipeline).

### C. Environment Overlays (Kustomize)
Configurations are structured using Kustomize base and overlay layers:
- `manifests/base/`: Contains common Kubernetes resource definitions (Deployments, Services, ConfigMaps, NetworkPolicies).
- `manifests/overlays/dev/`: Development environment parameters (low resource requests, automated self-heal).
- `manifests/overlays/staging/`: Staging environment parameters (replica mirroring).
- `manifests/overlays/prod/`: Production environment parameters (strict pod disruption budgets, manual/PR-gated sync).

---

## 3. Infrastructure & Cost Engineering (GKE Autopilot)

### Cost Optimization
To align with the platform's cost directives:
- ArgoCD is deployed on **GKE Autopilot**, utilizing pay-per-pod resource allocation.
- ArgoCD components (Server, Repo Server, Application Controller) are configured with tuned CPU and memory resource requests to minimize node footprint while maintaining sync responsiveness.
- Auto-scaling and pod preemption rules ensure minimal idle expenditure during non-peak hours.

---

## 4. Integration Matrix with Bank Microservices

| Project | Domain | Integration Point with ArgoCD |
| :--- | :--- | :--- |
| **Project 0** | Foundation & IAM | Provides GCP Service Accounts and Workload Identity Federation (WIF) for ArgoCD GKE workloads. |
| **Project 1** | Identity (Keycloak) | Acts as the OIDC Identity Provider for ArgoCD UI login & RBAC authorization mapping. |
| **Project 2** | Core Banking Backend | Managed as a child ArgoCD application deployed via Kustomize overlays. |
| **Project 5** | Kafka Event Bus | Managed as a child ArgoCD application deploying Strimzi / Kafka StatefulSets on GKE. |

---

## 5. AI Retrieval & Navigation Guidance

### Why Retrieve This Document?
- To understand the technical details of the ArgoCD GitOps architecture, App-of-Apps pattern, or hybrid CD model.
- To evaluate how microservices from Projects 1, 2, and 5 integrate into ArgoCD.

### Prerequisites
- Overview in [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/README.md).
- Security guidelines in [`SECURITY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/SECURITY.md).
