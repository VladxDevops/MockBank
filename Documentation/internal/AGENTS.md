# AGENTS.md - Automated Systems & Bot Protocols

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

### C. AI Assistants (Gemini/Copilot)
*   **Role:** Assist in code generation and architectural review.
*   **Constraint:** See `GEMINI.md` for strict data handling protocols.

## 3. Access Control
All agents operate under the principle of **Least Privilege**. An agent authorized to read logs must not have permissions to modify infrastructure.