# Changelog

All notable changes to the "Bank" project will be documented in this file. This log serves to track architectural decisions, successful implementations, and failed experiments to avoid regression.

## Usage Guide
1.  **Update Frequency:** Update this file immediately after any significant architectural decision or code merge.
2.  **Format:** Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) convention.
3.  **Categories:**
    *   `Added` for new features.
    *   `Changed` for changes in existing functionality.
    *   `Deprecated` for soon-to-be removed features.
    *   `Removed` for now removed features.
    *   `Fixed` for any bug fixes.
    *   `Security` in case of vulnerabilities.
4.  **Decisions:** Explicitly log *why* a decision was made (e.g., "Selected Cloud Run for cost reasons") to prevent re-litigating settled debates.

## [0.1.0] - Initial Setup
### Added
- **security.md**: Established the "Prime Directive" (Security > Privacy). Defined standards for MFA, RBAC, and Incident Response.
- **Architecture.md**: Defined system topology (GCP, Cloud Run, MongoDB, Keycloak). Added "Infrastructure & Operations" section mandating Terraform and cost optimization.
- **AGENTS.md**: Defined protocols for CI/CD, Monitoring, and AI agents.
- **GEMINI.md**: Established usage guidelines for AI assistants (Data sanitization, Security scanning).

### Decisions & Constraints
- **Secrets Management**: Hardcoding secrets is strictly prohibited. Adopted **GCP Secret Manager** as the single source of truth.
- **Infrastructure**: Selected **GCP Cloud Run** for cost-efficiency without compromising security.
- **AI Usage**: AI-generated code is treated as "untrusted" until human review and SAST scan.
- **Database**: MongoDB selected for Audit/Log storage; requires customer-managed encryption keys.

### Pending
- Implementation of Keycloak on Cloud Run.
- Creation of Terraform scripts for base infrastructure.
