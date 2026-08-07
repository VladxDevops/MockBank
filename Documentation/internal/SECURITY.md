+++
title = "Security & Privacy Policy - The Prime Directive"
domain = "security"
topics = ["security", "privacy", "zero-trust", "iam", "secrets-management"]
difficulty = "advanced"
parent = "README.md"
children = []
related = ["AGENTS.md", "Gobernance/SERVICE_ACCOUNT_GOVERNANCE.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **Related Agent Rules**: [`AGENTS.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)

---

# security.md - Security & Privacy Policy

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. The Prime Directive
**Security is the highest priority.**

In any conflict between feature velocity, user convenience, or system performance, **Security** takes precedence, followed immediately by **Privacy**.

## 2. Security Standards
*   **Authentication:** Multi-Factor Authentication (MFA) is mandatory for all administrative and high-value transaction flows.
*   **Authorization:** Strict Role-Based Access Control (RBAC). Default access is "Deny All".
*   **Vulnerability Management:** Critical vulnerabilities must be patched within 24 hours of detection.
*   **Secrets Management:** No passwords, keys, or sensitive information will be hardcoded. All secrets must be managed via GCP Secret Manager. Please alway double check that the GCP project numbers, names, and ids are not harcoded. Do not hard code service account email addresses nor keys. 

## 3. Privacy Standards
*   **Data Minimization:** We only collect data strictly necessary for the banking transaction.
*   **Right to be Forgotten:** Systems must support the complete erasure of user data upon request, in compliance with GDPR/CCPA.
*   **Log Sanitization:** Application logs must never contain clear-text passwords, tokens, or PII.

## 4. Compliance
*   **PCI-DSS:** All payment card handling must adhere to PCI standards.
*   **Audit Trails:** All access to customer data is logged immutably for audit purposes.

## 5. Incident Response
*   If a security breach is suspected, the system is designed to "fail closed" (deny access) rather than "fail open".
