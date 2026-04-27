# AGENTS.md - Project 1 Protocols

Please: 
Read the internal .md files they are a guidlines for multiple aspect like architechture, instructions, how tos, security, etc. 
Search if a file already exits before creating a new file to keep the directories organized. 
Document all changes in the changelo.md. Keep internal and internal documentation up to date. 

**CLASSIFICATION: INTERNAL USE ONLY**

This document outlines specific protocols for Automated Agents interacting with Project 1 (Identity Service).

## 0. Critical Security Constraint
**ZERO UNAUTHENTICATED INGRESS:** All services in Project 1 must remain private. 
*   Do NOT suggest `allUsers` IAM bindings.
*   Do NOT suggest disabling IAM authentication on Cloud Run.

## 1. Deployment Agents (CI/CD)
*   **Keycloak Updates:** Agents must use the `kc.sh build` command to optimize the image before deployment.
*   **Zero-Downtime:** Database migrations must be backward compatible.
*   **Container Build:** The Keycloak container image is built and pushed to Artifact Registry using a parameterized Cloud Build configuration (`mirror-keycloak.yaml`) to avoid hardcoding project-specific values.

## 2. Monitoring Agents
*   **Health Checks:** Monitor the `/health` endpoint of Keycloak.
*   **Log Ingestion:**
    *   **Allowed:** Login success/failure rates, latency.
    *   **Prohibited:** Ingesting user passwords, session tokens, or PII from logs. Exposing PI and PII. 

## 3. AI Assistants (Gemini)
*   **Terraform Generation:** When modifying Project 1 infrastructure, ensure `keycloak_serv_acc_account_id` is used in `main.tf` and defined in `variables.tf`. Do not suggest code with hardcoded string literals for IAM identities.
*   **Declarative Config:** All changes to the `Mockbankrealm` realm (clients, roles, scopes) must be performed via updates to `realm-export.json`. Manual UI changes are only permitted for temporary discovery, never for deployment.
*   **Diff Mode Requirement:** Each response providing code changes must include a "preview in diff mode" (unified diff format) with absolute paths to ensure the user knows exactly where and how to insert the code.
*   **Constraint:** AI must NEVER be provided with the `keycloak-admin-password` or the `master` realm private keys.

## 4. Troubleshooting Protocols
*   **Container Naming:** When providing `docker stats`, `docker exec`, or `docker logs` commands, Agents must instruct the user to verify the actual container name using `sudo docker ps`. 
*   **Service vs. Container:** Agents must explicitly distinguish between the **service name** (defined in `docker-compose.yaml`) and the **runtime container name** (e.g., `container-keycloak-1`) to prevent "No such container" errors.
*   **Resource Monitoring:** If a user reports resource usage, Agents should compare it against the defined JVM limits (2Gi/2000m) to confirm if the container is in a healthy idle state or experiencing a leak.

*Refer to `../../Documentation/internal/AGENTS.md` for global policies.*
