# AGENTS.md - Automated Systems & Bot Protocols

Please read the internal .md files they are a guidlines for multiple aspect like architechture, instructions, how tos, security, etc. 

Please search if a file already exits before creating a new file to keep the directories organized. 


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

Please keep the changelog.md up to date.