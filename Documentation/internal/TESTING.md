th # Testing Strategy

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
