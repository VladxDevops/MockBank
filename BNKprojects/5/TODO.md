+++
title = "Project 5: Event Streaming Platform - Engineering Task Backlog & TODO"
domain = "event-streaming"
topics = ["kafka", "pubsub", "todo", "backlog", "tasks", "project5", "engineering"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "README.md",
    "PROJECT5_DETAILS.md",
    "PUBSUB.md",
    "CHECKLIST.md",
    "SECURITY.md",
    "AGENTS.md"
]
updated_by = "AI Context Specialist"
version = "1.0"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/README.md)  
> **Technical Specs**: [`PROJECT5_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/PROJECT5_DETAILS.md)  
> **Implementation Checklist**: [`CHECKLIST.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/CHECKLIST.md)  
> **Pub/Sub Guide**: [`PUBSUB.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/PUBSUB.md)

---

# Project 5: Engineering Task Backlog & TODO List

This document tracks immediate actionable engineering tasks, backlog items, priority assignments, and acceptance criteria for Project 5 (Kafka & GCP Pub/Sub Event Streaming).

---

## Priority Legend
*   🔴 **P0 (Critical / Blocker)**: Must be completed before advancing to the next implementation phase.
*   🟡 **P1 (High Priority)**: Core functional deliverables for Phase 2 & 3.
*   🟢 **P2 (Medium Priority)**: Integration connectors, automation tests, and observability tooling.
*   ⚪ **P3 (Low Priority)**: Long-term optimization, multi-region replication, and nice-to-haves.

---

## 1. Immediate Backlog (Phase 2 & Phase 3)

| Task ID | Priority | Task Description | Owner | Target Milestone | Status |
| :--- | :---: | :--- | :--- | :---: | :---: |
| **TSK-P5-001** | 🔴 P0 | **JSON Schema Validation in Python Producer/Consumer**<br/>Add formal JSON schema validation before producing to `bank.transactions` and upon consuming. | Streaming Eng | Phase 2 | 📋 Todo |
| **TSK-P5-002** | 🔴 P0 | **Dead-Letter Queue (DLQ) & Poison Pill Isolation**<br/>Implement error-catching handler in `src/consumer.py` to route malformed messages to `bank.dead-letter` with backoff retries. | Streaming Eng | Phase 2 | 📋 Todo |
| **TSK-P5-003** | 🟡 P1 | **Real-Time Fraud Alert Stream Processor Prototype**<br/>Create `src/fraud_detector.py` to consume `bank.transactions`, detect high-risk patterns (> $10k or rapid velocity), and emit to `bank.fraud-alerts`. | AML / Security Eng | Phase 2 | 📋 Todo |
| **TSK-P5-004** | 🟡 P1 | **Unit & Integration Test Suite (`pytest`)**<br/>Create automated tests using `testcontainers-python` or embedded Kafka mock to test producer durability and consumer lag commits. | QA / CI Eng | Phase 2 | 📋 Todo |
| **TSK-P5-005** | 🟡 P1 | **Terraform GCP Pub/Sub Topic Modules**<br/>Define declarative HCL in `terraform/modules/pubsub/` for `bnk-tx-ingress-topic`, dead-letter topics, and IAM service account bindings. | Platform / DevOps | Phase 3 | 📋 Todo |
| **TSK-P5-006** | 🟡 P1 | **Pub/Sub to Kafka Streaming Bridge (Dataflow / Beam)**<br/>Implement a lightweight pipeline to stream messages from GCP Pub/Sub to Kafka while preserving `account_id` message keys. | Data Eng | Phase 3 | 📋 Todo |
| **TSK-P5-007** | 🟢 P2 | **Keycloak Auth Event Producer (Project 1 Integration)**<br/>Configure Keycloak event listener SPI to publish authentication failure and MFA telemetry to `bank.auth-events`. | Identity Eng | Phase 4 | 📋 Todo |
| **TSK-P5-008** | 🟢 P2 | **Actimize AML Engine Connector (Project 4 Integration)**<br/>Define consumer contract for Actimize fraud engine to read from `bank.transactions` and publish scores. | AML Eng | Phase 4 | 📋 Todo |
| **TSK-P5-009** | 🟢 P2 | **MuleSoft Event Gateway Mapping (Project 7 Integration)**<br/>Build DataWeave transformation flows in Project 7 to normalize third-party partner inputs and emit to Pub/Sub. | Integration Eng | Phase 4 | 📋 Todo |
| **TSK-P5-010** | 🔴 P0 | **Strimzi Kafka Operator on GKE Manifests**<br/>Create Kubernetes CRD manifests (`Kafka`, `KafkaTopic`, `KafkaUser`) managed via Project 6 (ArgoCD). | GitOps / Platform | Phase 5 | 📋 Todo |
| **TSK-P5-011** | 🔴 P0 | **SASL/SCRAM-SHA-512 & TLS 1.3 Configuration**<br/>Secure broker listeners with mutual TLS and SASL authentication; integrate secrets with GCP Secret Manager. | Security Eng | Phase 5 | 📋 Todo |
| **TSK-P5-012** | 🟢 P2 | **Prometheus JMX Exporter & Grafana Dashboards**<br/>Expose broker JMX metrics, consumer lag, and under-replicated partitions to Google Cloud Monitoring & Grafana. | Observability Eng | Phase 5 | 📋 Todo |

---

## 2. Detailed Task Breakdown & Acceptance Criteria

### TSK-P5-001: JSON Schema Validation
*   **Goal**: Ensure no malformed records enter the `bank.transactions` stream.
*   **Files**: `src/schemas/transaction_event.json`, `src/producer.py`, `src/consumer.py`
*   **Acceptance Criteria**:
    1. Schema requires `event_id`, `account_id`, `amount`, `currency`, `timestamp`, `transaction_id`, `correlation_id`.
    2. Invalid payload raises `ValidationError` and is rejected before `produce()` call.
    3. Unit test verifies invalid payload rejection.

### TSK-P5-002: Dead-Letter Queue (DLQ) Implementation
*   **Goal**: Prevent "poison pill" records from crashing consumer groups or blocking partition offsets.
*   **Files**: `src/consumer.py`, `src/dlq_handler.py`
*   **Acceptance Criteria**:
    1. Unparseable messages or business logic errors retry up to 3 times with exponential backoff (1s, 2s, 4s).
    2. If retry count exceeds 3, message is emitted to `bank.dead-letter` with headers: `x-original-topic`, `x-exception-message`, `x-retry-count`.
    3. Consumer commits offset on original partition to continue processing subsequent messages.

### TSK-P5-003: Real-Time Fraud Alert Processor
*   **Goal**: Build a streaming worker that flags suspicious transaction velocity and large amounts.
*   **Files**: `src/fraud_detector.py`
*   **Acceptance Criteria**:
    1. Consumes from `bank.transactions` (group: `fraud-detection-engine`).
    2. Flags transactions > $10,000 or > 3 transactions within 60 seconds on the same `account_id`.
    3. Produces alert to `bank.fraud-alerts` with `risk_score` and `action_required`.

---

## 3. Completed Tasks (Phase 1 Archive)

*   [x] **TSK-P5-000A**: Deploy local Apache Kafka 3.8 in KRaft mode via `docker-compose.yml`.
*   [x] **TSK-P5-000B**: Configure Kafka UI on port 8080.
*   [x] **TSK-P5-000C**: Build Python producer (`src/producer.py`) with `acks=all` and idempotent delivery.
*   [x] **TSK-P5-000D**: Build Python consumer (`src/consumer.py`) with manual offset commits.
*   [x] **TSK-P5-000E**: Write core concepts guide (`concepts/README.md`) and interview guide (`interview/kafka_interview_guide.md`).
*   [x] **TSK-P5-000F**: Create Project 5 security policy (`SECURITY.md`) and agent protocols (`AGENTS.md`).
