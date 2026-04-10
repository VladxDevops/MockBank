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

### C. Security Scans (SAST/DAST)
*   **Static Analysis:** Code is scanned for vulnerabilities (e.g., ReDoS, Injection) on every commit.
*   **Dependency Check:** `npm audit` runs in the CI pipeline to block vulnerable packages.

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
