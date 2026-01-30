# Altmtrk2026 Bank Platform

## Overview
This repository hosts the source code for the Altmtrk2026 Banking Platform. It is designed as a secure, cloud-native system leveraging GCP, Keycloak (Identity), and MongoDB (Audit).

## ⚠️ Security Warning
**Security is the highest priority.** Before contributing, you must read the [Security Policy](./security.md).
*   No hardcoded secrets.
*   No PII in logs.
*   MFA required for all admin actions.

## Documentation Map
*   **[Architecture](./Architecture.md):** System topology and component design.
*   **[Agents & Bots](./AGENTS.md):** Rules for CI/CD and AI usage.
*   **[Changelog](./CHANGELOG.md):** History of architectural decisions.

## Getting Started

### Prerequisites
1.  **Google Cloud SDK:** Authenticated with `gcloud auth login`.
2.  **Terraform:** v1.5+.
3.  **Node.js:** v18+ (LTS).

### Local Development
```bash
# 1. Clone the repo
git clone <repo_url>

# 2. Install dependencies
npm install

# 3. Run local mock environment
npm run dev:mock
```
