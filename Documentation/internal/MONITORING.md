# MONITORING.md - Global Observability Strategy

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Principles
Monitoring follows the **Security First** directive. We prioritize detecting security anomalies and system failures over business metrics.

*   **Golden Signals:** We track Latency, Traffic, Errors, and Saturation for all services.
*   **Privacy:** Log sinks must utilize Cloud Logging exclusions or masking to ensure no PII or session tokens are ingested.
*   **Fail-Closed:** Alerts are configured to trigger if security gates (MFA) are bypassed or failing.

## 1.1 Masking Specification
To ensure consistency across services, the following masking standards apply:

| Data Type | Masking Format | Example |
| :--- | :--- | :--- |
| **Email** | Partial obfuscation | `j***n@example.com` |
| **Account Number** | Last 4 digits visible | `********1234` |
| **Tokens/Secrets** | Full replacement | `[REDACTED]` |

## 2. Project 1: Identity Service (Keycloak)
**Focus:** Authentication Availability & Resource Saturation.

| Metric | Target | Alert Threshold |
| :--- | :--- | :--- |
| **Auth Latency** | < 500ms | > 1.5s (p95) |
| **Token Failure Rate** | < 0.1% | > 2% in 5 mins |
| **DB Conn Pool** | < 15 active | > 18 (Max 20 for f1-micro) |
| **Cold Start Time** | < 10s | > 15s |

**Key Logs to Watch:**
*   `type=LOGIN_ERROR`: High frequency indicates potential brute-force or credential stuffing.
*   `Acquisition timeout`: Indicates Cloud SQL saturation (Reference: `Testing-keycloakscript-report.md`).

## 3. Project 2: Transaction Service
**Focus:** Orchestration Logic & Audit Integrity.

### Journey Monitoring
We monitor the "Step-Up Auth" state machine defined in `PROJECT_DETAILS.md`.

*   **MFA Trigger Rate:** Correlation between transactions >= $10k and `mfa_challenge_issued` logs.
*   **Audit Lag:** Delay between transaction execution and MongoDB document insertion.
*   **MFA Timeouts:** Automated tracking of the `TIMEOUT` error code in the `journeys` collection.

**Diagnostic Query (Automated):**
Monitoring agents will periodically run the following to detect systemic MFA issues:
```javascript
db.journeys.countDocuments({
    "steps.step": "mfa_verification",
    "steps.status": "failed",
    "steps.error_code": "TIMEOUT",
    "timestamp": { $gt: new Date(Date.now() - 3600000) }
})
```

## 4. Project 3: CI/CD & Release Safety
**Focus:** Pipeline Integrity & Deployment Risk.

*   **Build Failure Rate:** Number of builds blocked by SAST (Static Analysis) vs. functional failures.
*   **Canary Health:** Error rate divergence between the `Canary` revision and `Stable` revision during traffic splitting.
*   **Rollback Count:** Frequency of automated rollbacks triggered by Cloud Run health check failures.

## 5. Alerting & Incident Response

### Severity 1 (Critical) - Immediate Page
*   Keycloak service returning 5xx for > 1 minute.
*   Detection of "Audit Gap" (Transactions occurring without corresponding MongoDB logs).
*   VPC Connector Egress failure (Total isolation).

### Severity 2 (Warning) - Ticket Created
*   Increased MFA timeout rate (> 5% of challenges).
*   JDBC connection pool reaching 80% capacity.
*   SAST gate failures in Project 3.

## 6. Audit Agents (Protocol)
Per `AGENTS.md`, specialized bots will inspect logs for:
1.  **Hardcoded Secret Detection:** Scanning logs for strings resembling API keys or tokens.
2.  **PII Leakage:** Scanning for unmasked email addresses or account numbers in structured logs.
3.  **Unauthorized Config Change:** Alerting on any manual configuration changes made via the GCP Console (Non-Declarative actions).

---
*Refer to `Documentation/internal/SECURITY.md` for incident escalation paths.*
---
