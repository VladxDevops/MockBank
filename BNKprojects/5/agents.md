+++
title = "Project 5 (Kafka Event Streaming Platform) Agent Protocols"
domain = "event-streaming"
topics = ["event-streaming", "kafka", "agents", "project5"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = ["../../Documentation/internal/AGENTS.md", "../../Documentation/internal/SECURITY.md", "PROJECT5_DETAILS.md"]
updated_by = "AI Context Specialist"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/5/README.md)  
> **Master Agent Protocols**: [`Documentation/internal/AGENTS.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/AGENTS.md)  
> **Security Prime Directive**: [`Documentation/internal/SECURITY.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/SECURITY.md)

---

# AGENTS.md - Project 5 Protocols

Please: 
Read the internal .md files they are guidelines for multiple aspects like architecture, instructions, how tos, security, etc. 
Search if a file already exists before creating a new file to keep the directories organized. 
Document all changes in the CHANGELOG.md. Keep internal and external documentation up to date.

**CLASSIFICATION: INTERNAL USE ONLY**

This document outlines specific protocols for Automated Agents interacting with Project 5 (Kafka Event Streaming).

## 0. Critical Security Constraint
**VPC ISOLATION & SECURE ACCESS:** Kafka brokers must be restricted to private VPC access and run without public exposure. 
*   Do NOT suggest exposing Kafka broker listener ports (e.g. 9092, 9093) on `0.0.0.0` or to the public web in non-local environments.
*   Do NOT commit sensitive credentials, Truststores, or `.env` files to git.

## 1. Deployment & Image Build
*   **Multi-Stage Docker Builds:** Standardize containerized Python workloads (producer, consumer) via a multi-stage Dockerfile. Ensure compiler dependencies are omitted from the runner stage.
*   **Non-Root User Group:** Enforce running image execution tasks under `USER appuser` (UID/GID 10001) to limit root/privilege escalations.
*   **Pinned Base Images:** Pin the exact developer/prod container versions (e.g. `python:3.11-slim` or `apache/kafka:3.8.0`) inside Dockerfiles and Compose configurations.

## 2. Configuration Management
*   **No Hardcoded Bootstraps:** All Kafka connection configurations must read from the environment (defaulting to `localhost:9092` for standalone runs, and resolved via `KAFKA_BOOTSTRAP_SERVERS` inside compose networks or Cloud Run).
*   **Topic Initialization:** Maintain declarative configurations for topics (e.g., in docker-compose.yml `init-topics` container runtime commands).

## 3. Log Ingestion & Privacy
*   **PII Masking:** Ensure all pipeline logs emitted by containerised clients sanitize card details, customer PII, and sensitive records before shipping to standard output. Log message identifiers and transaction totals for tracking, while masking sensitive details.

## 4. Diagnostics & Troubleshooting
*   **Verify Container Name:** Do not assume container names match services. Instruct developers or system tasks to run `sudo docker ps` to check exact running instances (e.g., `kafka-bank` or `kafka-producer-bank`).

*Refer to `../../Documentation/internal/AGENTS.md` for global policies.*
