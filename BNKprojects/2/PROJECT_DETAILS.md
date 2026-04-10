# Project 2: Transaction Journey & MongoDB Diagnostics

**CLASSIFICATION: INTERNAL**

## [AAAK_CONTEXT]
*   **PROJECT_ID:** 2 (Transaction Journey)
*   **STATE:** Active / Deployment Complete
*   **CORE_LOGIC:** Amount-based Step-Up Auth (Threshold: $10,000)
*   **STRICT_DEPS:** Keycloak OIDC (Proj 1), MongoDB Atlas (Audit)
*   **SECURITY_POSTURE:** Fail-Closed, No PII in Logs, Mandatory MFA.
*   **DOC_ANCHOR:** `Documentation/internal/KNOWLEDGE_MAP.md`

## 1. Objective
Build a "Money Transfer" microservice that simulates a Banking Identity Journey. The goal is to master **Orchestration Logic** and **MongoDB Diagnostics** to satisfy the "FlexID/Mosaic" requirements of the Job Description.

## 2. Architecture
*   **Service:** Node.js (Express) API.
*   **Database:** MongoDB Atlas (M0 free tier).
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
1.  [x] Initialize Node.js project in `2/`.
2.  [x] Create `docker-compose.yml` for MongoDB.
3.  [x] Implement `POST /transfer` endpoint with the logic above.

## 7. Connecting to the Database

The MongoDB database is deployed on MongoDB Atlas. The Terraform configuration will create a new project and a free-tier cluster. It will also create a database user with read/write access to the `transaction-db` database.

The credentials for the database user are generated randomly by Terraform. You can get the connection string from the MongoDB Atlas UI.

**Important:** The Node.js application will need the database connection string to connect to the database. This should be passed to the application as an environment variable (e.g., `MONGO_URI`). Do not hardcode the connection string in the application code.

The connection string will look something like this:

```
mongodb+srv://user:<password>@<cluster-url>/transaction-db?retryWrites=true&w=majority
```

You will need to replace `<password>` and `<cluster-url>` with the values from your Atlas cluster. The password will be available in the output of the `terraform apply` command.

## 8. Local Verification

To verify the service is running locally and connected to MongoDB, use the following command:

```bash
curl -X POST http://localhost:3000/transfer \
     -H "Content-Type: application/json" \
     -d '{"amount": 100, "user_id": "test_user"}'
```

**Expected Response:**
```json
{
  "message": "Transaction processed",
  "journey_id": "<uuid>",
  "status": "success",
  "decision": "approved"
}
```
