+++
title = "Global AI Agent Protocols & Automated Systems Guidelines"
domain = "agents"
topics = ["ai-agents", "protocols", "bot-guidelines", "gemma", "gemini", "antigravity"]
difficulty = "intermediate"
parent = "README.md"
children = [
    "Agents/skills/agents.md",
    "Agents/skills/building-docker-images/SKILL.md",
    "Agents/skills/REMMEMBERING/SKILL.md",
    "Agents/GEMMA/GEMMA.md"
]
related = [
    "SECURITY.md",
    "GEMINI.md",
    "../../terraform/AGENTS.md",
    "../../BNKprojects/1/AGENTS.md",
    "../../BNKprojects/5/agents.md",
    "../../BNKprojects/6/AGENTS.md",
    "../../BNKprojects/7/AGENTS.md"
]
updated_by = "AI Context Specialist"
version = "1.3"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **Security Prime Directive**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)  
> **Sub-Agent Protocols**: [`terraform/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/terraform/AGENTS.md) | [`BNKprojects/1/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/1/AGENTS.md) | [`BNKprojects/5/agents.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/agents.md) | [`BNKprojects/6/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/6/AGENTS.md) | [`BNKprojects/7/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/7/AGENTS.md)

---

# AGENTS.md - Automated Systems & Bot Protocols

Please: 
Read the internal .md files they are guidelines for multiple aspects like architecture, instructions, how tos, security, etc. 
Search if a file already exists before creating a new file to keep the directories organized. 
Document all changes in the CHANGELOG.md. Keep internal documentation up to date. 

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Core Directive
The highest priority for all automated agents (CI/CD runners, Monitoring Bots, AI Assistants) is **Security**, followed closely by **Privacy**. Operational efficiency is secondary to these constraints.
**PROHIBITION:** Agents must NEVER suggest allowing unauthenticated traffic (`allUsers`) to private services. Any suggestion to bypass IAM-based ingress is a violation of the Prime Directive.

## 2. Agent Classifications

### A. Deployment Agents (CI/CD)
*   **Role:** Execute safe, staggered deployments to production environments.
*   **Security:** Must operate with ephemeral credentials. No long-lived secrets stored in agent configurations.
*   **Compliance:** Must enforce all gates defined in `RELEASE_SAFETY.md`.

### B. Audit & Monitoring Agents
*   **Role:** Inspect MongoDB logs, Cloud Logging, and system metrics for anomalies.
*   **Privacy:** Must utilize log masking to ensure no PII (Personally Identifiable Information) or payment card details are ingested into monitoring dashboards.

### C. AI Assistants (Gemini / Antigravity)
*   **Role:** Assist in code generation, refactoring, and architectural review.
*   **Constraint:** See `Documentation/internal/GEMINI.md` for strict data handling protocols.

### D. AI Assistants (Gemma)
*   **Role:** Repository Domain Expert & local AI engineering assistant.
*   **Constraint:** See `Documentation/internal/GEMMA/GEMMA.md` for operating protocol and `Documentation/internal/GEMMA/skill.md` for capabilities.

## 3. Access Control
All agents operate under the principle of **Least Privilege**. An agent authorized to read logs must not have permissions to modify infrastructure.

## 4. AI Agent Blueprint & Project Guidelines
This document serves as the primary source of truth and instruction set for AI Agents (Gemini, Gemma, Antigravity) and developers working on this project.

### Internal Documentation Map
Internal policy documents have been consolidated into the `Documentation/internal/` directory. Agents must consult these files to ensure compliance:

*   **`Documentation/internal/SECURITY.md`**: The Prime Directive (Security > Velocity).
*   **`Documentation/internal/GEMINI.md`**: AI usage rules and data sanitization.
*   **`Documentation/internal/TESTING.md`**: Testing strategies (Mocking, Journeys).
*   **`Documentation/internal/CONTRIBUTING.md`**: PR process and coding standards.
*   **`Documentation/internal/transcripts.md`**: Sanitized AI session summaries and durable chat outcomes.

### Terraform Variables
*   **Constraint:** Do not hardcode Service Account names or IDs in `main.tf` files.
*   **Requirement:** Always create a corresponding variable in `variables.tf` (e.g., `service_account_id`) and populate it via `.tfvars`. This ensures that sensitive naming conventions are not leaked in the module source and allows for environment-specific naming.

### Diagnostics & Troubleshooting
*   **Docker Precision:** Agents must not assume container names match service names. When suggesting CLI commands for container inspection, Agents must include a discovery step: `sudo docker ps --format "table {{.Names}}\t{{.Status}}"`.
*   **Path Absolute Accuracy:** All file references and diffs must use absolute paths to ensure context continuity across multi-directory projects.
*   **Diff Mode Requirement:** Each response providing code changes must include a "preview in diff mode" (unified diff format) with absolute paths to ensure the user knows exactly where and how to insert the code.
*   **Context Verification:** Before proposing a fix for a "crashed" service, Agents must request the last 50 lines of logs to avoid guessing the failure mode.

### Transcript Ledger Protocol
*   **Session Memory:** Agents must use `Documentation/internal/transcripts.md` to record sanitized summaries of important AI-assisted sessions, including requests, decisions, outcomes, and follow-up actions.
*   **No Sensitive Data:** Transcript entries must never contain secrets, private keys, access tokens, unmasked PII, real customer data, or full sensitive logs.
*   **When to Update:** Add an entry when a session changes project process, architecture, security posture, troubleshooting knowledge, or documentation behavior.
*   **Source-of-Truth Rule:** If a transcript entry creates a durable rule, copy that rule into the relevant source document; do not leave policy only in the transcript ledger.
*   **Changelog Coupling:** If the session results in a code, architecture, or documentation change, update the relevant `CHANGELOG.md` in the same change.

### 5. Declarative Configuration Directive
*   **Source of Truth:** All infrastructure and application state (Clients, Realms, Policies) must reside in version-controlled files (HCL, JSON, YAML).
*   **Prohibition of Manual State:** Agents must never suggest manual configuration via Admin UIs or `docker exec` sessions as a permanent solution.
*   **Reproducibility:** If a change cannot be captured in a declarative manifest, it must be documented as a critical architectural debt.

### 6. Modular Infrastructure Directive
*   **Reusability:** All CI/CD and release safety infrastructure (Workload Identity, Cloud Deploy pipelines) must be encapsulated in reusable modules.
*   **Standardization:** Service-specific logic (e.g., repository name, service name) must be passed as variables to these modules.
*   **Centralization:** Foundational identity resources (Service Accounts, WIF Pools) should be declared once in the foundation module (`project0`).
*   **Dependency Management:** Downstream modules must reference shared identities using input variables to avoid state duplication.

### 7. GitOps Build Protocol
*   **Placeholder Configs:** If a container requires a configuration file at build-time (e.g., `realm-export.json`) that is managed via Terraform/runtime, Agents must use an `echo` command in the CI/CD pipeline to generate a placeholder file.

### 8. IAM Resource Standards
*   **Explicit Declaration:** Do NOT use `for_each` or `count` to loop through a list of roles for a single identity.
*   **Readability:** Every IAM role assignment must be its own unique Terraform resource (`google_project_iam_member`).
*   **Consistency:** Use the service account's email attribute for the `member` field.

### 9. AI Skill Development
Specialized AI personas and meta-prompts are managed in the externalized library:
*   **Registry:** `/home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/Agents/skills/`

#### Skill Usage Directive
Agents MUST check the skill registry before generating new solution guidance:
*   If creating or updating a `Dockerfile`, use the `building-docker-images` skill.
*   If managing container context, use `.dockerignore` guidance.
*   If preserving durable session context, use the `remembering` skill.

---

## 10. Context and Documentation Policy

Before generating or modifying code or documentation:
1. Identify the relevant project/domain.
2. Follow the repository documentation entry points.
3. Apply the Progressive Disclosure skill.
4. Load only the context required for the current task.
5. Follow documentation breadcrumbs before performing broad searches.
6. Do not read entire documentation trees unless explicitly necessary.
7. Create or update documentation according to the same navigation and retrieval conventions.
