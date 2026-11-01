+++
title = "Security Scanning Architecture & Governance (SAST, SCA, DAST)"
domain = "security"
topics = ["security", "sast", "sca", "dast", "trivy", "semgrep", "owasp-zap", "dependabot", "checkov"]
difficulty = "advanced"
parent = "SECURITY.md"
children = []
related = ["TESTING.md", "RELEASE_SAFETY.MD", "SECURITY.md", "github-actions.md"]
updated_by = "Antigravity"
version = "1.0"
+++

> **Parent**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)  
> **Related Protocols**: [`Documentation/internal/TESTING.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/TESTING.md) | [`Documentation/internal/RELEASE_SAFETY.MD`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/RELEASE_SAFETY.MD)

<!-- AI RETRIEVAL HINTS
- Purpose: Comprehensive specification and operational standard for SAST, SCA, DAST, and Container/IaC security scanning across the Altmtrk2026 Bank Platform.
- Questions Answered:
  1. What scanning tools are implemented for SAST, SCA, and DAST?
  2. How do scanning gates enforce the Release Safety Policy across CI, CD, and post-deploy?
  3. How should engineers run and triage SAST, SCA, and DAST scans locally and in CI?
  4. What are the vulnerability remediation SLAs?
- When to Retrieve: Setting up pipelines, triaging vulnerability alerts, reviewing pull requests, or updating dependencies and container images.
-->

---

# Security Scanning Architecture & Governance (SAST, SCA, DAST)

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Executive Summary & Principles

In accordance with the **Prime Directive** ([`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)), security takes precedence over feature velocity, convenience, and runtime performance. Software cannot be promoted to `TEST` or `PROD` without passing automated security gates across static analysis, open-source dependency auditing, container scanning, and dynamic runtime testing.

### The Security Scanning Triad + IaC & Containers
```
                     +---------------------------------------+
                     |    Altmtrk2026 Bank Security Gates     |
                     +---------------------------------------+
                                         |
     +-------------------+---------------+-------------------+-------------------+
     |                   |                                   |                   |
     v                   v                                   v                   v
+---------+         +---------+                         +---------+         +---------+
|  SAST   |         |   SCA   |                         |  DAST   |         | IaC/Env |
| Semgrep |         |pip-audit|                         |OWASP ZAP|         | Checkov |
| Secrets |         |npm audit|                         | Baseline|         | Tfsec   |
| Top 10  |         | Trivy   |                         | API Scan|         | Trivy   |
+---------+         +---------+                         +---------+         +---------+
 (Pre-PR)            (Pre-PR & Build)                    (Post-Deploy)       (Pre-PR)
```

---

## 2. Scanning Matrix & Tooling Rationale

| Scan Type | Scope & Target | Tool Selected | Execution Stage | Enforcement Gate |
| :--- | :--- | :--- | :--- | :--- |
| **SAST (Code)** | Python (`BNKprojects/1`, `BNKprojects/5`), Node.js (`BNKprojects/2`), Java (`BNKprojects/7`) | **Semgrep OSS** | Pull Request (`ci.yaml`), Pre-commit | **Blocking**: Zero `CRITICAL` or `HIGH` OWASP Top 10 vulnerabilities |
| **SAST (Secrets)** | All repository commits, config files, shell scripts | **Semgrep Secrets / Gitleaks** | Pull Request (`ci.yaml`), Pre-commit | **Blocking**: Zero hardcoded credentials, GCP keys, tokens, or PII |
| **SAST (IaC)** | Terraform files (`terraform/`, `PLATFORM/GCP/terraform`) | **Checkov / Trivy Config** | Pull Request (`ci.yaml`) | **Blocking**: Zero non-compliant IAM bindings, unencrypted storage, or public ingress (`allUsers`) |
| **SCA (Dependencies)** | Node.js (`package.json`), Python (`requirements.txt`) | **`npm audit`**, **`pip-audit`**, **Dependabot** | Pull Request (`ci.yaml`), Scheduled weekly | **Blocking**: Zero unpatched `HIGH` or `CRITICAL` CVEs |
| **SCA (Containers)** | Built Docker images (Keycloak, Transaction Service, Kafka) | **Aqua Trivy (`trivy-action`)** | Image Build in CD (`cd.yaml`) | **Blocking**: Zero unpatched `CRITICAL` OS or application package vulnerabilities |
| **DAST (APIs & Web)** | Cloud Run endpoints (`transaction-service`, `keycloak-service`), mock runners | **OWASP ZAP (Baseline & API)** | Post-deployment in CD or Ephemeral Runner (`dast.yaml`) | **Advisory/Gate**: Baseline header compliance, injection resilience, zero unauthenticated endpoints |

---

## 3. Detailed Component Standards

### A. Static Application Security Testing (SAST)
*   **Engine**: Semgrep OSS is utilized due to fast execution, zero external daemon requirements, and rich multi-language rule sets.
*   **Rule Packs**:
    *   `p/security-audit`: General security misconfigurations and insecure APIs.
    *   `p/secrets`: Detection of private keys, GCP service account credentials, JWT tokens, and database passwords.
    *   `p/owasp-top-ten`: Coverage for SQL injection, NoSQL injection (MongoDB in Project 2), Command injection, and ReDoS.
    *   `p/python`: Specialized Flask, Python cryptography, and SAML assertions validation (`BNKprojects/1`).
    *   `p/javascript`: Node.js and Express route sanitization, prototype pollution, and SSRF prevention (`BNKprojects/2`).
*   **Ignoring False Positives**:
    *   File exclusions must be tracked in `.semgrepignore`.
    *   Inline rule suppression must use `# nosemgrep: rule-id` accompanied by a mandatory ticket number and justification comment signed off by the Security Lead.

### B. Software Composition Analysis (SCA) & Container Vulnerability Scanning
*   **Node.js**:
    *   Executed via `npm audit --audit-level=high`.
    *   Lockfiles (`package-lock.json`) must strictly match `package.json`.
*   **Python**:
    *   Executed via `pip-audit -r requirements.txt`.
    *   Requirements must be compiled and pinned deterministically using `pip-compile` (`requirements.in` -> `requirements.txt`).
*   **Container Images**:
    *   Images built for Google Cloud Run or GKE (Keycloak in Project 1, Transaction Service in Project 2) must be scanned with `trivy image --severity HIGH,CRITICAL` before deployment.
    *   Base images must use pinned digest or minimal distroless/slim variants (e.g. `python:3.12-slim`, `node:20-alpine`, `ubi9-minimal`).
*   **Dependabot**:
    *   Configured in `.github/dependabot.yml` to automatically submit dependency updates and security patches on a weekly schedule.

### C. Dynamic Application Security Testing (DAST)
*   **Engine**: OWASP ZAP (Zed Attack Proxy).
*   **Scan Modes**:
    1.  **Baseline Scan (`zap-baseline.py`)**: Checks for security headers (`Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`), secure cookie flags (`HttpOnly`, `Secure`, `SameSite`), and improper error information disclosure.
    2.  **API Scan (`zap-api-scan.py`)**: Consumes the OpenAPI specification (`swagger.json`/`openapi.yaml`) or REST endpoint lists for active fuzzing against injection, parameter tampering, and broken object-level authorization (BOLA).
*   **Execution Strategy**:
    *   **CI Ephemeral Verification**: In the pull-request or staging pipeline, services run in an ephemeral container environment with mock backends while ZAP executes targeted API scans.
    *   **CD Post-Deploy Verification**: Automated trigger targeting non-production Cloud Run URLs via authenticated internal identity tokens or `cloud-run-proxy`.

---

## 4. Vulnerability Remediation SLAs

In strict adherence to Level 1 Policy ([`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)):

| Severity | Definition | Remediation SLA | Pipeline Behavior |
| :--- | :--- | :--- | :--- |
| **CRITICAL** | Remote code execution, unauthenticated data access, hardcoded production secrets, active CVE with known exploit | **< 24 Hours** | Build fails immediately. Releases are blocked. Hotfix expedited. |
| **HIGH** | Privilege escalation, SQL/NoSQL injection, missing authorization checks, critical dependency vulnerability | **< 7 Days** | Pull request blocked. Release promotion to `TEST`/`PROD` withheld. |
| **MEDIUM** | Insecure transport configurations, missing security headers, CSRF weaknesses on non-critical endpoints | **< 30 Days** | Build emits warning and uploads SARIF report. Triage required in backlog. |
| **LOW / INFO** | Informational disclosures, code style security recommendations | **Best Effort** | Tracked during routine dependency and refactoring sprints. |

---

## 5. Developer Local Runbooks

Developers and AI Agents should execute security scans locally before pushing changes to avoid CI build failures:

### Local SAST (Semgrep)
```bash
# Run Semgrep with standard security rules
semgrep scan --config "p/security-audit" --config "p/secrets" --config "p/owasp-top-ten" .
```

### Local SCA - Python (`BNKprojects/1` & `BNKprojects/5`)
```bash
# Install and run pip-audit
pip install pip-audit
pip-audit -r BNKprojects/1/requirements.txt
pip-audit -r BNKprojects/5/requirements.txt
```

### Local SCA - Node.js (`BNKprojects/2`)
```bash
# Check Node.js dependencies
cd BNKprojects/2/container
npm audit --audit-level=high
```

### Local Container Scan (Trivy)
```bash
# Scan a built local container image
trivy image transaction-service:latest --severity HIGH,CRITICAL
```

### Local DAST (OWASP ZAP Docker)
```bash
# Run baseline scan against local mock container
docker run -t --network="host" ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://localhost:8080 -r zap_report.html
```

---

## 6. Integration Checklist & Next Steps
- [x] Establish `SECURITY_SCANNING.md` standard.
- [x] Register in `DOCUMENTATION_HIERARCHY.md`.
- [x] Cross-reference in `TESTING.md` and `RELEASE_SAFETY.MD`.
- [x] Implement SAST and SCA jobs in `.github/workflows/ci.yaml`.
- [x] Implement Trivy container image scanning in `.github/workflows/cd.yaml`.
- [x] Configure `.github/dependabot.yml` for automated dependency alerting.
- [x] Implement dedicated DAST workflow in `.github/workflows/dast.yaml`.
