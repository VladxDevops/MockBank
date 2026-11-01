+++
title = "Testing Strategy & Automated Test Protocols"
domain = "testing"
topics = ["testing", "jest", "supertest", "mocking", "journeys", "security-testing"]
difficulty = "intermediate"
parent = "README.md"
children = ["TEST_ENVIRONMENT_STRATEGY.md", "TESTING-KEYCLOAK-INTERNAL.md"]
related = ["SECURITY.md", "../../BNKprojects/1/README-TESTING.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **Security Directives**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)  
> **Keycloak Integration Testing**: [`BNKprojects/1/README-TESTING.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/1/README-TESTING.md)

<!-- AI RETRIEVAL HINTS
- Purpose: Outlines testing layers (Unit, Integration, Security Journeys) and mocking rules for the banking platform.
- Questions Answered:
  1. What test frameworks and coverage mandates are required?
  2. How are MongoDB and Keycloak identity providers mocked during tests?
  3. What are the core rules for testing Auth and Journey logic?
- When to Retrieve: Writing test suites, setting up mocks, or reviewing testing guidelines.
- When NOT to Retrieve: Querying production deployment pipelines or Terraform IaC logic.
- Prerequisites: [SECURITY.md]
- Follow-up Reading: [TEST_ENVIRONMENT_STRATEGY.md]
-->

---

# Testing Strategy

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Philosophy
We test to prove **security** and **reliability**, not just functionality.

## 2. Testing Layers

### A. Unit Tests (Jest)
*   **Scope:** Individual functions and logic blocks.
*   **Focus:** Edge cases in "Journey" logic (e.g., "What if risk score is exactly 50?").
*   **Requirement:** 100% coverage on Auth logic.

### B. Integration Tests (Supertest)
*   **Scope:** API endpoints and Database interactions.
*   **Focus:** Verifying that MongoDB audit logs are written correctly after a transaction.
*   **Mocking:** External Identity Providers (IdP) and GCP Services must be mocked to avoid cost and dependency.

### C. Security Scans (SAST, SCA, DAST)
*Detailed specifications, SLAs, and execution runbooks are documented in [`SECURITY_SCANNING.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY_SCANNING.md).*

*   **Static Application Security Testing (SAST):**
    *   Application source code (Python, Node.js, Java) is scanned with Semgrep OSS on every pull request (`ci.yaml`).
    *   Rule sets include `p/owasp-top-ten`, `p/secrets`, `p/security-audit`, `p/python`, and `p/javascript`.
    *   Zero tolerance for hardcoded GCP keys, credentials, or injection vulnerabilities.
*   **Software Composition Analysis (SCA):**
    *   **Node.js**: `npm audit --audit-level=high` blocks PRs containing high/critical package CVEs.
    *   **Python**: `pip-audit -r requirements.txt` scans pip dependencies against CVE/OSV registries.
    *   **Containers**: Aqua Trivy scans all built Docker images (Keycloak, Transaction Service) in CD (`cd.yaml`) prior to Artifact Registry pushing or Cloud Deploy releases.
    *   **Automated Updates**: Dependabot (`.github/dependabot.yml`) scans dependencies weekly.
*   **Dynamic Application Security Testing (DAST):**
    *   Automated OWASP ZAP Baseline and API scans run against target service endpoints (`.github/workflows/dast.yaml`).
    *   Verifies HTTP security headers (CSP, HSTS), secure cookie flags, and endpoint fuzzing against unauthenticated access.

## 3. The "Bank Simulation"
To simulate the bank environment described in the JD:
1.  **Happy Path:** User logs in -> MFA Success -> Transfer Complete.
2.  **Attack Path:** User logs in -> MFA Fails 3 times -> Account Locked -> Audit Log verified.

## 4. Mandatory Automation Standard (SOP)
To ensure environment parity and deployment reliability, the following must be implemented for **ALL** projects (Project 1, 2, and future Project 3):

*   **Test Script:** Every project root must contain a `test-<service>.sh` script.
*   **Dual Verification:** Scripts must support both `Proxy/Tunnel` (internal API) and `Direct IAM` (infrastructure health) methods.
*   **Troubleshooting Docs:** Two troubleshooting files are required per project:
    1. `TROUBLESHOOTING.md`: Focuses on deployment and runtime failures.
    2. `TROUBLESHOOTING_SCRIPTS.md`: Focuses on failures of the automation tools themselves.
*   **Consistency:** All project leads must replicate this pattern to ensure a "World Class" developer experience.
