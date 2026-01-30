# Contributing Guidelines

## 1. The Prime Directive
**Security > Velocity.**
Do not merge code that "works" but is insecure. If a feature requires bypassing security controls, the feature is wrong.

## 2. Pull Request (PR) Process
1.  **Atomic Changes:** Keep PRs small and focused on a single "Journey" or infrastructure change.
2.  **Security Checklist:**
    *   [ ] No secrets (API keys, passwords) are hardcoded.
    *   [ ] Input validation is applied to all API endpoints.
    *   [ ] PII is masked in log outputs.
3.  **Review:** All PRs affecting IAM or Auth flows require a review from a designated Security Engineer.

## 3. Coding Standards
*   **Language:** Node.js (TypeScript preferred) for App; HCL for Infrastructure.
*   **Linting:** Run `npm run lint` before committing.
*   **Secrets:** Use `process.env.SECRET_NAME` to access credentials injected by GCP Secret Manager.

## 4. Branching Strategy
*   `main`: Production-ready code.
*   `dev`: Integration branch.
*   `feature/xyz`: New features (e.g., `feature/oidc-login`).
*   `fix/xyz`: Bug fixes.
