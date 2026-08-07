+++
title = "Keycloak & Identity Protocols Overview"
domain = "identity"
topics = ["keycloak", "oidc", "saml", "realms", "jwt", "auth-code-flow"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["../../BNKprojects/1/README.md", "../../BNKprojects/1/PROJECT1_DETAILS.md", "../../BNKprojects/3/SAML_INTERVIEW_QA.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/README.md)  
> **Keycloak Service**: [`BNKprojects/1/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/1/README.md)  
> **SAML Architecture**: [`BNKprojects/3/SAML_INTERVIEW_QA.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/3/SAML_INTERVIEW_QA.md)

<!-- AI RETRIEVAL HINTS
- Purpose: Provides technical overview of Keycloak IAM, Realm structures, OIDC vs SAML flows, and JWT tokens.
- Questions Answered:
  1. What is Keycloak and how does token issuance work in this platform?
  2. What is the distinction between master realm and Mockbankrealm?
  3. How does Authorization Code Flow with PKCE function?
- When to Retrieve: Querying Keycloak terminology, realm concepts, or OIDC/SAML token issuance mechanisms.
- When NOT to Retrieve: Diagnosing local container start scripts or Cloud Run Terraform definitions.
- Prerequisites: [README.md]
- Follow-up Reading: [../../BNKprojects/1/PROJECT1_DETAILS.md]
-->

---

# Keycloak & Identity Protocols (Technical Overview)

**NOTICE: This file is for informational purposes only (FYI).**

## 1. What is Keycloak?
Keycloak is an open-source Identity and Access Management (IAM) solution used as our centralized Identity Provider (IdP). It allows the Altmtrk2026 Banking Platform to outsource authentication and authorization logic.

**How it works:**
1.  **Redirection:** When a user accesses a protected service (like the Retail App), they are redirected to Keycloak.
2.  **Authentication:** Keycloak handles the login (MFA, Social Login, etc.).
3.  **Token Issuance:** Upon success, Keycloak issues a cryptographic token (JWT for OIDC or XML Assertion for SAML) back to the application.

## 2. Realms
A **Realm** is a logical isolation unit within Keycloak. 

*   **Isolation:** Each realm has its own users, roles, and clients.
*   **Project Context:** We use the `Mockbankrealm` realm for all banking operations. Administrative tasks are restricted to the `master` realm.
*   **Configuration:** All security policies, such as brute-force detection and MFA requirements, are defined at the realm level.

## 3. PKCE (Proof Key for Code Exchange)
PKCE (pronounced "pixie") is an extension to the OAuth 2.0 Authorization Code flow. It is mandatory for our "Public Clients" (like the Retail Banking App) to prevent authorization code injection attacks.

**The Handshake:**
1.  **Code Verifier:** The client generates a high-entropy secret string.
2.  **Code Challenge:** The client hashes the verifier and sends the hash to Keycloak.
3.  **Verification:** When the client later exchanges the authorization code for a token, it sends the original *verifier*. Keycloak verifies the hash matches.

If an attacker intercepts the authorization code, they cannot exchange it for a token because they lack the original secret `code_verifier`.

## 4. S256
**S256** refers to the **SHA-256** hashing algorithm used within the PKCE flow.

*   **Security:** It is a one-way cryptographic hash.
*   **Implementation:** Our `retail-app` configuration enforces `S256` for the `code_challenge_method`.
*   **Algorithm:** `code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))`.

## 5. CLI Verification (Headless Check)
To verify the deployment without using the Admin UI, execute the following while the `gcloud proxy` is active on port 8888:

### A. Fetch Admin Token
```bash
export TKN=$(curl -s -X POST "http://localhost:8888/realms/master/protocol/openid-connect/token" \
  -d "client_id=admin-cli" -d "username=admin" -d "password=admin" -d "grant_type=password" | jq -r .access_token)
```

### B. Validate Realm & PKCE Attribute
```bash
# Check Realm
curl -s -H "Authorization: Bearer $TKN" "http://localhost:8888/admin/realms/Mockbankrealm" | jq -r '.realm'

# Check retail-app PKCE Policy
curl -s -H "Authorization: Bearer $TKN" "http://localhost:8888/admin/realms/Mockbankrealm/clients?clientId=retail-app" \
  | jq -r '.[0].attributes["pkce.code.challenge.method"]'
```
**Successful output for PKCE must be: `S256`**

---
*Refer to `Documentation/internal/SECURITY.md` for specific implementation standards.*
