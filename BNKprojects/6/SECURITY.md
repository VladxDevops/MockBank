+++
title = "Project6: ArgoCD Security & Access Control Policy"
domain = "security"
topics = ["argocd-security", "oidc", "keycloak", "rbac", "sops", "sealed-secrets", "zero-trust"]
difficulty = "advanced"
parent = "README.md"
children = []
related = ["PROJECT6_DETAILS.md", "AGENTS.md", "../../Documentation/internal/SECURITY.md"]
updated_by = "AI Security Auditor"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/README.md)  
> **Prime Directive**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)

---

# Project6: ArgoCD Security & Access Control Policy

## 1. Prime Security Directive

Per the platform's global security policy ([`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)), **Security and Privacy strictly outrank velocity**. 

Any change or configuration that compromises zero-trust isolation, exposes internal control planes to unauthenticated access, or hardcodes sensitive credentials is strictly prohibited.

---

## 2. Ingress & Control Plane Hardening

### Prohibition of Public / Unauthenticated Access
- The ArgoCD Web UI and gRPC server **must NEVER** be exposed publicly without authentication or via `allUsers` / `allAuthenticatedUsers` bindings.
- Ingress to the ArgoCD API server must be secured using GKE Internal Load Balancers or IAP (Identity-Aware Proxy) behind strict IP restrictions and TLS 1.3 encryption.

---

## 3. Authentication & RBAC Integration

### OIDC SSO via Project 1 (Keycloak)
- Direct local admin accounts are disabled in production (`admin.enabled: "false"` in `argocd-cm.yaml`).
- Authentication is federated exclusively through **Project 1 Keycloak** using OIDC with PKCE (S256).

### Role-Based Access Control (RBAC) Mapping
User roles are dynamically assigned via Keycloak token group claims (`argocd-rbac-cm.yaml`):

| Keycloak Group | ArgoCD Role | Granted Permissions |
| :--- | :--- | :--- |
| `bank-devops-admin` | `role:admin` | Full cluster & application management |
| `bank-developers` | `role:developer` | Read access to applications; sync privileges in `dev` / `staging` |
| `bank-auditors` | `role:readonly` | Read-only inspection of application sync status & logs |

---

## 4. Declarative Secret Management Policy

### Prohibition of Plaintext Secrets
- Plaintext Kubernetes `Secret` manifests **must NEVER** be committed to git repositories under `BNKprojects/6/`.

### Approved Secret Workflows
1. **SOPS / KSOPS Encryption:** Secrets in git are encrypted using Mozilla SOPS backed by Google Cloud KMS (`projects/PROJECT_ID/locations/global/keyRings/bank-keyring/cryptoKeys/argocd-key`). Decryption occurs in-memory inside the ArgoCD repo-server via CMP sidecars (`plugins/sops-cmp-sidecar.yaml`).
2. **External Secrets Operator (ESO):** ArgoCD syncs `ExternalSecret` manifests that pull runtime secrets directly from GCP Secret Manager.

---

## 5. Pod Security Standards & Isolation

- **Namespace Isolation:** ArgoCD components reside in a dedicated `argocd` namespace governed by Kubernetes **Restricted Pod Security Standards**.
- **Non-Root Containers:** All ArgoCD workloads must run as non-root (`runAsNonRoot: true`, `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false`).

---

## 6. AI Retrieval & Navigation Guidance

### Why Retrieve This Document?
- To review security controls, OIDC/Keycloak mapping, and secret management guidelines for Project 6.
- To verify compliance with zero-trust ingress and RBAC requirements.

### Prerequisites
- Global Security Policy ([`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)).
