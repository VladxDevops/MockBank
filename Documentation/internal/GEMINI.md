# GEMINI.md - AI Assistant Usage Guidelines

**CLASSIFICATION: INTERNAL USE ONLY**

## 1. Usage Policy
Gemini Code Assist is utilized to accelerate development, refactor code, and generate test cases. However, it must be used within strict security boundaries.

## 2. Data Privacy & Security
**Priority: Security > Privacy > Utility**

*   **Prohibited Data:** Never paste real customer data, production secrets, private keys, or unmasked PII into the chat context.
*   **Sanitization:** All code snippets shared with the AI must use dummy data (e.g., "John Doe", "Bank of Example").
*   **Persistent Memory (MemPalace/LTM):** If using agents with long-term memory capabilities:
    *   **Memory Palace Standard:** We use a documentation-based LTM approach via `KNOWLEDGE_MAP.md`. 
    *   **Notation:** Use AAAK (As Always, All Knowledge) headers and TOON (Token Oriented Object Notation) for relationship definitions to maximize token efficiency.
    *   **Transcript Ledger:** Use `Documentation/internal/trasnscripts.md` for sanitized summaries of important AI-assisted sessions. Store decisions, outcomes, and follow-ups, not verbatim chats.
    *   No PII or production secrets may be "memorized."
    *   Context files must be updated immediately in `CHANGELOG.md` when architectural bounds shift.

## 3. Code Generation Standards
*   **Review Required:** All AI-generated code is treated as "untrusted" until reviewed by a human engineer.
*   **Security Scanning:** Generated code must pass static analysis (SAST) for vulnerabilities (e.g., injection flaws, hardcoded secrets) before being committed.

## 4. Architecture Assistance
*   Gemini may be used to draft architectural patterns (e.g., "How to implement OIDC flow").
*   Gemini may NOT be used to design proprietary cryptographic algorithms. Standard libraries must be used.
