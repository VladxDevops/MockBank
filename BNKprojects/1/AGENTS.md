# AGENTS.md - Project 1 Protocols

**CLASSIFICATION: INTERNAL USE ONLY**

This document outlines specific protocols for Automated Agents interacting with Project 1 (Identity Service).

## 1. Deployment Agents (CI/CD)
*   **Keycloak Updates:** Agents must use the `kc.sh build` command to optimize the image before deployment.
*   **Zero-Downtime:** Database migrations must be backward compatible.

## 2. Monitoring Agents
*   **Health Checks:** Monitor the `/health` endpoint of Keycloak.
*   **Log Ingestion:**
    *   **Allowed:** Login success/failure rates, latency.
    *   **Prohibited:** Ingesting user passwords, session tokens, or PII from logs. Exposing PI and PII. 

## 3. AI Assistants (Gemini)
*   **Configuration:** AI may assist in generating Realm Export JSON files.
*   **Constraint:** AI must NEVER be provided with the `keycloak-admin-password` or the `master` realm private keys.

*Refer to `../../Documentation/internal/AGENTS.md` for global policies.*
