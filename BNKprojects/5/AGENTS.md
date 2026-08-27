+++
title = "Project 5: Event Streaming Platform Agent Protocols"
domain = "event-streaming"
topics = ["event-streaming", "kafka", "pubsub", "agents", "project5", "protocols"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "../../Documentation/internal/AGENTS.md",
    "../../Documentation/internal/SECURITY.md",
    "README.md",
    "PROJECT5_DETAILS.md",
    "PUBSUB.md",
    "CHECKLIST.md",
    "TODO.md",
    "SECURITY.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/README.md)  
> **Master Agent Protocols**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)  
> **Security Prime Directive**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)  
> **Project Security Policy**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/SECURITY.md)

---

# AGENTS.md - Project 5 (Kafka & Pub/Sub) Protocols

**CLASSIFICATION: INTERNAL USE ONLY**

This document outlines strict operating instructions, security guardrails, and execution protocols for Automated Agents (CI/CD runners, Monitoring Bots, AI Assistants: Gemini, Gemma, Antigravity) interacting with **Project 5 (Event Streaming Platform)**.

---

## 1. Prime Directives & Security Constraints

*   **VPC ISOLATION & NO PUBLIC INGRESS:** Kafka brokers, KRaft controllers, and internal pub/sub consumers must be restricted to private VPC access. Agents must **NEVER** suggest exposing Kafka broker listener ports (e.g. `9092`, `9093`) or management consoles to `0.0.0.0/0` or unauthenticated public networks.
*   **NO HARDCODED SECRETS:** Passwords, SASL credentials, TLS certificates, private keys, and `.env` files must never be committed to git or baked into container images. All credentials must be sourced dynamically via **GCP Secret Manager** or injected as environment variables.
*   **PII SANITIZATION:** Streaming payload logs emitted to standard output must never expose raw credit card numbers (PAN), Social Security Numbers (SSN), or passwords. Card numbers must be masked to the last 4 digits (`****-****-****-1234`).

---

## 2. AI Assistant Execution Rules

*   **PATH ABSOLUTE ACCURACY:** All file references and diffs must use absolute paths (e.g., `/home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/...`).
*   **DIFF MODE PREVIEW:** Code changes must be presented in unified diff format with clear file paths so developers can review changes before applying.
*   **DETERMINISTIC PARTITIONING INTEGRITY:** When generating or refactoring producer logic, Agents must preserve the key-based partitioning on `account_id` to guarantee per-account FIFO transaction ordering.
*   **IDEMPOTENCE & RELIABILITY:** Producers must always be configured with `acks=all` and `enable.idempotence=true`. Consumers must use manual synchronous offset commits (`enable.auto.commit=false`) after persistent downstream sink writes.

---

## 3. Container & Deployment Protocols

*   **Multi-Stage Docker Builds:** Standardize containerized Python workloads (`producer.py`, `consumer.py`) using multi-stage builds (`python:3.11-slim`) to omit compiler toolchains and development packages from the final runtime image.
*   **Non-Root User Group:** Containers must run under an unprivileged user (`USER appuser` or UID 10001).
*   **Pinned Base Images:** Pin explicit container versions (e.g., `apache/kafka:3.8.0`, `python:3.11-slim`), avoiding `latest` in non-local environments.
*   **Dynamic Bootstrap Discovery:** Application code must read bootstrap servers from `KAFKA_BOOTSTRAP_SERVERS` (defaulting to `localhost:9092` only for local disconnected runs).

---

## 4. Diagnostics & Troubleshooting SOP

*   **Container Inspection:** Do not assume static container names. When suggesting CLI commands, include a discovery step:
    ```bash
    sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    ```
*   **Topic & Consumer Group Verification:**
    ```bash
    # Check consumer group lag
    docker exec kafka-bank /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group transaction-processor

    # Check topic partition distribution
    docker exec kafka-bank /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic bank.transactions
    ```

---

## 5. Related Project Documentation

*   [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/README.md) — Master navigation hub
*   [`PROJECT5_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/PROJECT5_DETAILS.md) — Technical specifications & RACI matrix
*   [`PUBSUB.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/PUBSUB.md) — GCP Pub/Sub & Kafka architectural guide
*   [`CHECKLIST.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/CHECKLIST.md) — Phased implementation checklist
*   [`TODO.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/TODO.md) — Actionable task backlog
*   [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/SECURITY.md) — Security & zero-trust policy
