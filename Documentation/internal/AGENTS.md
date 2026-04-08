# AGENTS.md - Automated Systems & Bot Protocols

Please: 
Read the internal .md files they are a guidlines for multiple aspect like architechture, instructions, how tos, security, etc. 
Search if a file already exits before creating a new file to keep the directories organized. 
Document all changes in the changelo.md. Keep internal and internal documentation up to date. 


**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Core Directive
The highest priority for all automated agents (CI/CD runners, Monitoring Bots, AI Assistants) is **Security**, followed closely by **Privacy**. Operational efficiency is secondary to these constraints.

## 2. Agent Classifications

### A. Deployment Agents (CI/CD)
*   **Role:** Execute safe, staggered deployments to production environments.
*   **Security:** Must operate with ephemeral credentials. No long-lived secrets stored in agent configurations.

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


Terraform imports should include the .tfvars file to prevent the terminal for asking already existing inputs.

### Terraform Variables
*   **Constraint:** Do not hardcode Service Account names or IDs in `main.tf` files.
*   **Requirement:** Always create a corresponding variable in `variables.tf` (e.g., `service_account_id`) and populate it via `.tfvars`. This ensures that sensitive naming conventions are not leaked in the module source and allows for environment-specific naming if needed.

### Diagnostics & Troubleshooting
*   **Docker Precision:** Agents must not assume container names match service names. When suggesting CLI commands for container inspection, Agents must include a discovery step: `sudo docker ps --format "table {{.Names}}\t{{.Status}}"`.
*   **Path Absolute Accuracy:** All file references and diffs must use absolute paths to ensure context continuity across multi-directory projects.
*   **Context Verification:** Before proposing a fix for a "crashed" service, Agents must request the last 50 lines of logs to avoid guessing the failure mode (e.g., distinguishing between OOM and Connection Refused).

### 5. Declarative Configuration Directive
*   **Source of Truth:** All infrastructure and application state (Clients, Realms, Policies) must reside in version-controlled files (HCL, JSON, YAML).
*   **Prohibition of Manual State:** Agents must never suggest manual configuration via Admin UIs or `docker exec` sessions as a permanent solution.
*   **Reproducibility:** If a change cannot be captured in a declarative manifest, it must be documented as a critical architectural debt.

Please keep the changelog.md up to date.