# Project 1: Secure Bank Portal (Infrastructure & Protocols)

**CLASSIFICATION: INTERNAL**

## 1. Objective
Deploy a centralized Identity Provider (Keycloak) on GCP using Terraform and integrate two distinct banking applications to master **OIDC** and **SAML** protocols. This covers the "Identity Standards" and "DevOps/Release" sections of the JD.

## 2. Architecture
*   **Identity Provider:** Keycloak running on GCP Cloud Run (Serverless).
*   **Database:** Cloud SQL (PostgreSQL) for Keycloak persistence.
*   **Infrastructure:** Provisioned 100% via Terraform.

## 3. The Applications (Simulated)
1.  **Retail Banking App (Modern):**
    *   **Protocol:** OIDC (OAuth2).
    *   **Flow:** Authorization Code Flow with PKCE.
    *   **Tech:** Python (Flask) or Node.js.
    *   **Auth:** Social Login (Google) + Username/Password.

2.  **Legacy Teller Portal (Internal):**
    *   **Protocol:** SAML 2.0.
    *   **Flow:** SP-Initiated SSO.
    *   **Tech:** Python (Flask) with `python3-saml`.
    *   **Auth:** Username/Password only (Strict Internal).

## 4. Key Deliverables
1.  **Terraform Scripts:**
    *   Deploy Cloud Run Service.
    *   Deploy Cloud SQL Instance.
    *   Configure VPC Connector (Serverless to SQL).
2.  **Keycloak Configuration:**
    *   Realm: `Mockbankrealm`.
    *   Clients: `retail-app` (OIDC), `teller-portal` (SAML).

## 5. Interview Prep: Protocol Deep Dive
**Question:** "Explain the difference between OIDC and SAML in our bank."
**Answer:**
*   **OIDC:** Built on JSON/REST. Used for our Mobile/Web retail apps. Lightweight, mobile-friendly. Token: JWT.
*   **SAML:** XML-based. Used for legacy internal apps and B2B federation. Heavy, carries more trust context but harder to parse on mobile. Token: XML Assertion.

## 6. Development Plan
1.  Write Terraform for GCP Cloud Run + SQL.
2.  Deploy Keycloak.
3.  **Phase 3: Retail App (OIDC Integration):**
    *   **Client Configuration:**
        *   Client ID: `retail-app`
        *   Access Type: `PRIVATE, GCP authenticated`
        *   Flow: Authorization Code Flow
        *   PKCE: Enforced (`S256`)
        *   Redirect URI: `http://localhost:3000/callback`
    *   **Implementation:** 
        *   Use `openid-client` (Node) or `Authlib` (Python).
        *   Ensure `code_challenge` is sent in the `/auth` request.
        *   Validate the `nonce` and `state` parameters to prevent CSRF/Replay.
4.  **Create "Teller App" (SAML Integration):**
    *   Setup `teller-portal` client in Keycloak with SAML 2.0.
    *   Capture and verify the signed XML assertion.
