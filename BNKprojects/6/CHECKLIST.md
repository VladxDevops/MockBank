+++
title = "Project6: ArgoCD Implementation & Readiness Checklist"
domain = "checklist"
topics = ["argocd-checklist", "milestones", "readiness", "verification"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["PROJECT6_DETAILS.md", "SECURITY.md", "AGENTS.md"]
updated_by = "AI Knowledge Engineer"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/README.md)  
> **Technical Specs**: [`PROJECT6_DETAILS.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/PROJECT6_DETAILS.md)

---

# Project 6: ArgoCD Implementation & Readiness Checklist

## Phase 1: Documentation & Governance (Completed)
- [x] Create project structure under `BNKprojects/6/`.
- [x] Write core documentation (`README.md`, `PROJECT6_DETAILS.md`, `SECURITY.md`, `AGENTS.md`, `CHECKLIST.md`).
- [x] Establish subdirectory indexes (`bootstrap/`, `apps/`, `manifests/`, `plugins/`, `scripts/`).
- [x] Integrate Project6 into root microservices index (`BNKprojects/README.md`).
- [x] Record sanitized session transcript and update `CHANGELOG.md`.

---

## Phase 2: Bootstrap & Cluster Infrastructure (Planned, not started)
- [ ] Provision GKE Autopilot cluster via Terraform (`terraform/modeles/project6/` module).
- [ ] Configure Workload Identity Federation (WIF) bindings for ArgoCD service accounts in Project0 foundation.
- [ ] Create `argocd` namespace with Restricted Pod Security Standard.
- [ ] Deploy base ArgoCD components via Kustomize (`BNKprojects/6/bootstrap/`).
- [ ] Configure Keycloak OIDC integration in `argocd-cm.yaml` targeting Project1.
- [ ] Verify TLS certificate termination and private ingress access.

---

## Phase 3: Application & GitOps Management (Planned, not started)
- [ ] Deploy root App-of-Apps manifest (`apps/root-app.yaml`).
- [ ] Onboard Project 1 (Identity Service) Kubernetes manifests into ArgoCD.
- [ ] Onboard Project 2 (Core Banking) Kubernetes manifests into ArgoCD.
- [ ] Onboard Project 5 (Kafka Event streaming) StatefulSets into ArgoCD.
- [ ] Configure SOPS CMP sidecar plugin (`plugins/sops-cmp-sidecar.yaml`) for in-repo secret decryption.

---

## Phase 4: Drift Detection & Release Safety Verification (Planned, not started)
- [ ] Test automated drift detection (introduce manual state deviation and verify auto-healing in `dev`).
- [ ] Verify RBAC group mapping using Keycloak test users.
- [ ] Validate pre-commit and CI/CD manifest linting scripts (`scripts/validate-manifests.sh`).
- [ ] Perform audit logging check to confirm sync events stream to Cloud Logging.
