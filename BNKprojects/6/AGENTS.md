+++
title = "Project6: AI Agent Protocols & Operating Rules"
domain = "agent-protocols"
topics = ["argocd-agents", "protocols", "bot-guidelines", "gitops-rules"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["SECURITY.md", "PROJECT6_DETAILS.md", "../../Documentation/internal/AGENTS.md"]
updated_by = "AI Context Specialist"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/6/README.md)  
> **Global Policy**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)

---

# Project 6: AI Agent Protocols & Operating Rules

## 1. Prime Directive Compliance
All AI Agents (Gemini, Gemma, Claude, etc.) operating on Project6 MUST adhere to the global Security Directive:
**Security > Privacy > Velocity.**

- **Prohibition:** Agents must NEVER suggest exposing the ArgoCD UI or API to unauthenticated users (`allUsers`).
- **Secret Safety:** Agents must NEVER output or commit plaintext secrets into Kubernetes manifest files. All secrets must use SOPS encryption or GCP Secret Manager references.

---

## 2. Path Accuracy & Diff Mode Requirements
- **Absolute Paths:** All file paths used in suggestions, tools, or references must be absolute, starting from the workspace root:  
  `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/BNKprojects/6/...`
- **Unified Diff Mode:** Code/manifest edits proposed by agents must be formatted in unified diff mode with clear path headers.

---

## 3. Mandatory Agent Workflows for Project6

### A. Manifest Modification Workflow
1. Read existing Kustomize/Helm manifests in `BNKprojects/6/manifests/` or `BNKprojects/6/apps/` before suggesting edits.
2. Ensure overlay changes (`dev`, `staging`, `prod`) do not override base security policies (e.g., dropping pod security contexts).
3. Verify that changes to application sync policies do not enable `prune: true` or `selfHeal: true` in production without explicit user consent.

### B. Transcript & Changelog Updates
- Any session resulting in structural, architectural, or security changes in Project6 must append a sanitized entry to:  
  `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/Documentation/internal/Agents/Memory/transcripts.md`
- The project's root `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/CHANGELOG.md` must be updated in the same change.

---

## 4. AI Retrieval Guidance

### Why Retrieve This Document?
- To inspect operating constraints and rules when generating or modifying ArgoCD manifests, scripts, or documentation in `BNKprojects/6/`.
