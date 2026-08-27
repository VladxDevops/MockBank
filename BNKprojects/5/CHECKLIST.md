+++
title = "Project 5: Event Streaming Platform - Implementation Checklist"
domain = "event-streaming"
topics = ["kafka", "pubsub", "checklist", "milestones", "project5", "implementation", "architecture"]
difficulty = "intermediate"
parent = "README.md"
children = []
related = [
    "README.md",
    "PROJECT5_DETAILS.md",
    "PUBSUB.md",
    "TODO.md",
    "SECURITY.md",
    "AGENTS.md",
    "Kafka_in_Banking.md"
]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/README.md)  
> **Technical Specs**: [`PROJECT5_DETAILS.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/PROJECT5_DETAILS.md)  
> **Pub/Sub Guide**: [`PUBSUB.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/PUBSUB.md)  
> **Actionable Backlog**: [`TODO.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/TODO.md)  
> **Security Directives**: [`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/SECURITY.md)

---

# Project 5: Event Streaming Implementation Checklist

**Project Status:** Active / Phase 1 Complete (Local Sandbox) — Phase 2 & 3 in Planning  
**Last Updated:** 2026-08-27  

---

## Phase 0: Architectural Design & Infrastructure Planning

### Architecture & Design Decisions
- [x] Select Kafka metadata mode (**KRaft mode** selected; Zookeeper eliminated)
- [x] Formulate Hybrid Architecture (GCP Pub/Sub at cloud edge + Kafka as central stateful event backbone)
- [x] Document key-based partition strategy (`account_id` hashing for per-account FIFO ordering)
- [x] Document delivery guarantees (`acks=all`, `enable.idempotence=true`, manual offset commit)
- [x] Define topic naming taxonomy (`bank.transactions`, `bank.accounts`, `bank.fraud-alerts`, `bank.auth-events`, `bank.dead-letter`)
- [ ] Define production cluster sizing (GKE node pool requirements, CPU/memory, SSD persistent disks)
- [ ] Finalize Schema Registry hosting strategy (Confluent Schema Registry on GKE vs GCP Pub/Sub Schema Registry)

### Security & Governance Foundations
- [x] Define Level 3 Security Policy ([`SECURITY.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/SECURITY.md))
- [x] Establish zero-trust private VPC isolation rules (no public IPs on Kafka brokers)
- [x] Define PII log sanitization requirements (PAN masking, SSN redaction, crypto-shredding)
- [ ] Define GCP IAM service accounts and roles for Kafka / Pub/Sub workloads
- [ ] Setup Workload Identity Federation (WIF) bindings for GKE / Cloud Run consumers

---

## Phase 1: Local Development & KRaft Broker Sandbox

### Infrastructure as Code (Local Stack)
- [x] Create `docker-compose.yml` with single-node KRaft broker (`apache/kafka:3.8.0`)
- [x] Configure Kafka UI (Provectus) for visual inspection on port `8080`
- [x] Create automated topic initialization service (`init-topics` container)
- [x] Create `.dockerignore` and `.gitignore` to prevent credential leakage
- [x] Create multi-stage container build definition ([`Dockerfile`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/Dockerfile))

### Python Application Layer
- [x] Define client dependencies in `requirements.txt` (`confluent-kafka`, `faker`)
- [x] Build mock transaction event producer ([`src/producer.py`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/src/producer.py))
- [x] Implement idempotent publishing logic with delivery callback verification
- [x] Build transaction event consumer ([`src/consumer.py`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/src/consumer.py))
- [x] Implement manual synchronous offset commit (`commit(asynchronous=False)`)

### Core Documentation & Education
- [x] Document Kafka core concepts ([`concepts/README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/concepts/README.md))
- [x] Build technical interview preparation guide ([`interview/kafka_interview_guide.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/interview/kafka_interview_guide.md))
- [x] Create Project 5 Master Readme ([`README.md`](file:///home/pochitawork/InterviewCloudProjects/Altmtrk2026/Bank/BNKprojects/5/README.md))

---

## Phase 2: Schema Governance, Serialization & Dead-Letter Queues

### Schema Management
- [ ] Define JSON Schema definitions for `bank.transactions`, `bank.accounts`, and `bank.fraud-alerts`
- [ ] Create Avro schema definitions (`.avsc`) for high-throughput production serialization
- [ ] Implement schema validation in Python producer and consumer pipelines
- [ ] Add schema compatibility checking (Backward / Forward / Full compatibility tests)

### Error Handling & Dead-Lettering (DLQ)
- [ ] Implement retry loop with exponential backoff for transient processing failures
- [ ] Implement Poison Pill isolation: forward unparseable messages to `bank.dead-letter`
- [ ] Create DLQ consumer utility with diagnostic inspection and replay capabilities
- [ ] Add automated alerts on DLQ queue depth > 0

### Real-Time Fraud Alert Topology
- [ ] Build Python stream processor evaluating real-time transaction velocities
- [ ] Trigger automated alert events to `bank.fraud-alerts` upon anomaly detection (e.g. > $10,000 or rapid velocity)
- [ ] Verify single-partition total ordering for fraud alerts

---

## Phase 3: GCP Pub/Sub Ingestion Gateway & Bridge Tier

### Pub/Sub Infrastructure (Terraform)
- [ ] Create Terraform module for GCP Pub/Sub topics (`bnk-tx-ingress-topic`, `bnk-partner-ingress-topic`)
- [ ] Configure Dead Letter Topics (`-dlt`) with max delivery attempts = 5
- [ ] Create BigQuery Direct Streaming Subscription for financial analytics
- [ ] Create Push Subscriptions for Cloud Run webhook consumers

### Hybrid Streaming Bridge
- [ ] Implement Cloud Dataflow (Apache Beam) pipeline streaming from Pub/Sub to Kafka
- [ ] Alternatively, configure Kafka Connect with Google Cloud Pub/Sub Source & Sink Connectors
- [ ] Implement key preservation (`account_id`) during Pub/Sub $\to$ Kafka transfer
- [ ] Validate end-to-end latency (< 500ms from edge Pub/Sub publish to Kafka consumer receipt)

---

## Phase 4: Banking Microservices Integration

### Project 1 (Keycloak Identity Service)
- [ ] Stream authentication events, failed logins, and MFA triggers to `bank.auth-events`
- [ ] Implement consumer detecting credential stuffing / brute-force patterns

### Project 2 (Core Banking & Transaction Service)
- [ ] Implement transactional outbox pattern or CDC (Debezium) from MongoDB/PostgreSQL
- [ ] Stream settled transaction events to `bank.transactions`
- [ ] Ensure idempotency deduplication on consumer side

### Project 4 (NICE Actimize AML & Fraud Engine)
- [ ] Connect Actimize real-time event listener to `bank.transactions`
- [ ] Implement AML compliance alert publisher emitting to `bank.fraud-alerts`

### Project 7 (MuleSoft API Gateway)
- [ ] Configure MuleSoft Kafka Connector / Pub/Sub Connector in Anypoint Studio
- [ ] Normalize external partner payloads via DataWeave before publishing to `bnk-partner-ingress-topic`

---

## Phase 5: Production Hardening & Operational Excellence

### Kubernetes Deployment (GKE & ArgoCD)
- [ ] Deploy Strimzi Kafka Operator to GKE via Project 6 (ArgoCD) GitOps
- [ ] Configure 3-node KRaft Kafka Cluster CRD with dedicated SSD persistent volumes
- [ ] Configure anti-affinity rules across GKE availability zones

### Security Hardening
- [ ] Enable SASL/SCRAM-SHA-512 authentication on all external and internal listeners
- [ ] Provision TLS 1.3 certificates using cert-manager or Google Cloud Certificate Manager
- [ ] Apply Kafka ACLs with default-deny policy
- [ ] Store SASL passwords and TLS keystores in GCP Secret Manager

### Observability & Chaos Testing
- [ ] Expose JMX metrics via Prometheus JMX Exporter
- [ ] Integrate with Google Cloud Monitoring & Cloud Trace via OpenTelemetry Collector
- [ ] Build Grafana dashboards for Broker CPU, Consumer Group Lag, and Partition Under-Replication
- [ ] Perform chaos test: simulate broker node termination and verify zero message loss and seamless leader failover
