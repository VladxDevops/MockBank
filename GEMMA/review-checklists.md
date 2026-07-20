# PR, Terraform, Kubernetes, Security Checklists

## PR Review Checklist
*   Code Style: Follows Bank coding standards.
*   Unit Tests: Includes adequate unit tests to cover all new functionality and bug fixes.
*   Integration Tests:  Includes integration tests for interacting with other components.
*   Security Checks: No known security vulnerabilities identified (run SAST scans).
*   Code Comments: Sufficient comments explaining complex logic.
*   Reviewer Feedback: Incorporates feedback from reviewers effectively.

## Terraform Checklist
*   Variables: Uses environment variables for configurable values.
*   Modules: Reuses modules to promote consistency.
*   Outputs: Exposes necessary outputs for monitoring and use by other systems.
*   Idempotency: Terraform performs idempotent operations.

## Kubernetes Checklist
*   Resource Limits: Sets appropriate resource limits (CPU, memory) for containers.
*   Health Checks: Implements health checks to ensure container availability.
*   Secrets Management: Uses a secure secrets management solution: Google Cloud Platform Secret manager.
*   Logging & Monitoring: Logs all relevant events and metrics.

## Security Checklist
*   Input Validation:  Validates all user inputs to prevent injection attacks.
*   Authentication & Authorization: Enforces strong authentication and authorization mechanisms.
*   Data Encryption: Encrypts sensitive data at rest and in transit.
*   Vulnerability Scanning: Regularly scans for known vulnerabilities (e.g., using tools like Snyk or SonarQube).