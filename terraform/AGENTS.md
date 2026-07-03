# AGENTS.md - Automated Systems & Bot Protocols

Please: 
Read the internal .md files they are a guidlines for multiple aspect like architechture, instructions, how tos, security, etc. 
Search if a file already exits before creating a new file to keep the directories organized. 
Document all changes in the CHANGELOG.md. Keep internal and external documentation up to date. 

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Core Directive
The highest priority for all automated agents (CI/CD runners, Monitoring Bots, AI Assistants) is **Security**, followed closely by **Privacy**. Operational efficiency is secondary to these constraints.

## 2. Agent Classifications

### A. Deployment Agents (CI/CD)
*   **Role:** Execute safe, staggered deployments to production environments.
*   **Security:** Must operate with ephemeral credentials. No long-lived secrets stored in agent configurations.
*   **Context Safety:** All workflow steps must explicitly define `working-directory` to ensure consistency across directory-switching operations (e.g., transitioning from Terraform apply to Docker builds).

### B. Audit & Monitoring Agents
*   **Role:** Inspect MongoDB logs and system metrics for anomalies.
*   **Privacy:** Must utilize log masking to ensure no PII (Personally Identifiable Information) is ingested into monitoring dashboards.

### C. AI Assistants (Gemini)
*   **Role:** Assist in code generation and architectural review.
*   **Constraint:** See `Documentation/internal/GEMINI.md` for strict data handling protocols.

## 3. Access Control
All agents operate under the principle of **Least Privilege**. An agent authorized to read logs must not have permissions to modify infrastructure.

## 4. AI Agent Blueprint & Project Guidelines
This document serves as the primary source of truth and instruction set for AI Agents (Gemini) and developers working on this project.

### Internal Documentation Map
Internal policy documents have been consolidated into the `Documentation/internal/` directory. Agents must consult these files to ensure compliance:

*   **`Documentation/internal/SECURITY.md`**: The Prime Directive (Security > Velocity).
*   **`Documentation/internal/GEMINI.md`**: AI usage rules and data sanitization.
*   **`Documentation/internal/TESTING.md`**: Testing strategies (Mocking, Journeys).
*   **`Documentation/internal/CONTRIBUTING.md`**: PR process and coding standards.
*   **`Documentation/internal/trasnscripts.md`**: Sanitized AI session summaries, troubleshooting outcomes, and durable follow-ups.

### Transcript Ledger Protocol
*   For Terraform or CI/CD troubleshooting sessions, add a sanitized summary to `Documentation/internal/trasnscripts.md` when the result changes process, state-management knowledge, IAM guidance, or deployment behavior.
*   Never store `.tfvars` contents, service account keys, private credentials, raw tokens, or unmasked project/customer data in transcript entries.
*   If the session produces an infrastructure change or documentation rule, update the relevant `CHANGELOG.md` and source document in the same change.

### Recent Architectural Shifts
*   **CI/CD Consolidation (Migration):** Foundational security resources (Workload Identity Federation, GitHub Actions Service Accounts, and Project-wide IAM) are now centralized in `modules/project0`. Service-specific modules (e.g., `project3`) must consume these via variables to maintain a single source of truth for identity.

### Recent Architectural Shifts
*   **CI/CD Consolidation (Migration 2024.1):** Foundational security resources (Workload Identity Federation, GitHub Actions Service Accounts, and Project-wide IAM) are now centralized in `modules/project0`. Service-specific modules (e.g., `project3`) must consume these via variables to maintain a single source of truth for identity.
