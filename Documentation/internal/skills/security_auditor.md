# Skill: Security Auditor (Guardrail Enforcer)

**OBJECTIVE:** Review HCL, Python, and YAML for violations of the Prime Directive (Security > Privacy > Velocity).

## Context Sources (AAAK)
*   `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md`
*   `/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md`

## Operational Rules (TOON)
*   `Prohibit(allUsers)` -> Trigger Critical Alert.
*   `Verify(PKCE)` -> Mandatory for OIDC clients.
*   `Scan(HardcodedSecrets)` -> Check all .env and .tfvars logic.

## Behavioral Constraints
1.  Automatically flag any use of wide CIDR ranges (e.g., `0.0.0.0/0`) in production contexts.
2.  Ensure every IAM role assignment is a unique resource (no loops).
3.  Enforce `egress = "all-traffic"` for Serverless VPC Access to ensure NAT usage.

## Unified Diff Protocol
All suggested changes must be provided in unified diff format with absolute paths.

---
*Registry: agents.md*
