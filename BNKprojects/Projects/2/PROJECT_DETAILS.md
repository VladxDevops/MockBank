# Project 2: Transaction Journey & MongoDB Diagnostics

**CLASSIFICATION: INTERNAL**

## 1. Objective
Build a "Money Transfer" microservice that simulates a Banking Identity Journey. The goal is to master **Orchestration Logic** and **MongoDB Diagnostics** to satisfy the "FlexID/Mosaic" requirements of the Job Description.

## 2. Architecture
*   **Service:** Node.js (Express) API.
*   **Database:** MongoDB (running locally via Docker).
*   **Role:** Simulates the backend "Risk Engine" and "Audit Logger".

## 3. The "Journey" Flow (Orchestration)
The application must implement the following logic state machine:

1.  **Step 1: Login (Level 1 Auth)**
    *   User provides credentials.
    *   **Action:** Write to MongoDB Audit Log.
    *   *State:* `session_created`.

2.  **Step 2: Transaction Request**
    *   User requests to transfer amount `$X`.
    *   **Logic:**
        *   IF `$X < $10,000`: Allow immediately.
        *   IF `$X >= $10,000`: Trigger **Step-Up Auth**.

3.  **Step 3: Step-Up Authentication (MFA)**
    *   System challenges user (simulated).
    *   **Action:** Log `mfa_challenge_issued`.
    *   **Outcome:**
        *   *Success:* Proceed to transfer.
        *   *Fail:* Log `mfa_failed` with error code.

## 4. MongoDB Schema (Audit Log)
To support the "Diagnostics" interview question, we will use a document structure that captures the full journey context.

```json
{
  "journey_id": "uuid-v4",
  "user_id": "cust_12345",
  "timestamp": "ISODate()",
  "status": "failed",
  "risk_score": 85,
  "steps": [
    {
      "step": "login",
      "timestamp": "...",
      "status": "success"
    },
    {
      "step": "risk_evaluation",
      "input": { "amount": 15000 },
      "decision": "step_up_required"
    },
    {
      "step": "mfa_verification",
      "status": "failed",
      "error_code": "TIMEOUT"
    }
  ]
}
```

## 5. Interview Prep: Diagnostic Queries
You must be able to write these queries during the interview.

**Scenario:** "Users are complaining about MFA timeouts. Investigate."

**Query:**
```javascript
db.journeys.find({
    "steps.step": "mfa_verification",
    "steps.status": "failed",
    "steps.error_code": "TIMEOUT"
}).sort({ timestamp: -1 })
```

## 6. Development Plan
1.  Initialize Node.js project in `2/`.
2.  Create `docker-compose.yml` for MongoDB.
3.  Implement `POST /transfer` endpoint with the logic above.
