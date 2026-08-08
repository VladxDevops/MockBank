# Kafka Interview Guide — Banking Domain

> This guide is organized by interview question category. Each section includes
> the question, a strong answer, and a reference to your project code so you can
> speak from experience.

---

## 🎯 How to Use This Guide

1. **Read each Q&A** — understand the concept, not just memorize the answer
2. **Run the project** — the best answers come from "I built exactly this, let me explain..."
3. **Practice out loud** — interviews reward clear, structured verbal explanations
4. **Use the STAR framework** for behavioral: Situation → Task → Action → Result

---

## Part 1: Core Concepts

### Q1: What is Apache Kafka and why would you use it?

> **Strong Answer**: Kafka is a distributed event streaming platform. It's essentially
> an append-only, partitioned, replicated commit log. You'd use it when you need:
>
> - **High-throughput** message processing (millions of events/sec)
> - **Durability** — messages are persisted to disk with configurable retention
> - **Decoupling** — producers and consumers don't need to know about each other
> - **Replayability** — unlike traditional message queues, consumers can re-read old messages
>
> *In my banking project, I use Kafka to stream transaction events between services.
> For example, the transaction service publishes to `bank.transactions`, and both the
> fraud detection service and the audit service consume from it independently.*

### Q2: What's the difference between Kafka and a traditional message queue (RabbitMQ, SQS)?

| Feature | Kafka | Traditional MQ (RabbitMQ/SQS) |
|---------|-------|-------------------------------|
| Message persistence | Retained after consumption | Deleted after consumption |
| Consumer model | Pull-based (consumer controls pace) | Push-based (broker pushes) |
| Replay | ✅ Can re-read old messages | ❌ Gone once consumed |
| Ordering | Per-partition | Per-queue |
| Throughput | Very high (100K+ msg/sec) | Moderate |
| Use case | Event streaming, logs, CDC | Task queues, RPC |

> **Key insight**: Kafka is a **log**, not a queue. Messages aren't "consumed" — they're
> read at an offset. Multiple consumer groups can independently read the same data.

### Q3: Explain topics, partitions, and offsets.

> **Strong Answer** (draw this on a whiteboard if possible):
>
> - A **topic** is a logical category (e.g., `bank.transactions`)
> - Each topic is split into **partitions** (e.g., 3 partitions)
> - Each partition is an ordered, append-only log
> - Each message in a partition has a unique **offset** (sequential ID)
> - Ordering is guaranteed **within** a partition, not across partitions
>
> *In my project, `bank.transactions` has 3 partitions. I use `account_id` as the
> message key so all transactions for one account go to the same partition, preserving
> per-account ordering.*

### Q4: How does Kafka guarantee message ordering?

> **Strong Answer**: Kafka guarantees ordering **within a single partition**. If you
> need global ordering, use a single partition (but lose parallelism). The practical
> approach is to choose a partition key that groups related messages:
>
> - Banking: partition by `account_id` → per-account ordering
> - E-commerce: partition by `order_id` → per-order ordering
>
> *See `src/producer.py` where I use `key=transaction["account_id"]`.*

### Q5: What are consumer groups? Why do they matter?

> **Strong Answer**: A consumer group is a set of consumers that cooperate to consume
> a topic. Kafka assigns each partition to exactly one consumer in the group.
>
> - **Same group** = load balancing (partitions are split among consumers)
> - **Different groups** = broadcast (each group gets all messages)
>
> If a consumer in the group crashes, its partitions are **rebalanced** to surviving
> consumers. This is Kafka's built-in fault tolerance for consumers.
>
> *In my project, I can demonstrate this by running two consumers with `--group team-a`
> and watching partitions get split between them.*

---

## Part 2: Architecture & Design Questions

### Q6: "Design a real-time fraud detection pipeline using Kafka."

> **Strong Answer** (system design format):
>
> ```
> [Transaction Service] → bank.transactions → [Fraud Detector] → bank.fraud-alerts → [Alert Service]
>                                                    ↓
>                                             bank.fraud-dlq (failed processing)
> ```
>
> 1. **Transaction Service** publishes every transaction to `bank.transactions`
>    - Key: `account_id` (ordering per account)
>    - Schema: JSON with amount, merchant, location, timestamp
>
> 2. **Fraud Detector** consumes from `bank.transactions`
>    - Checks rules: amount > $5000, unusual location, rapid succession
>    - Scores each transaction
>    - If suspicious → publishes to `bank.fraud-alerts`
>    - If processing fails → sends to `bank.fraud-dlq` (Dead Letter Queue)
>
> 3. **Alert Service** consumes from `bank.fraud-alerts`
>    - Sends notifications (SMS, email, push)
>    - Updates the account risk profile
>
> **Why Kafka over alternatives?**
> - Need to replay transactions if fraud rules change
> - Multiple consumers (fraud, audit, analytics) read independently
> - High throughput for thousands of transactions/second
> - Durability — can't afford to lose transaction data

### Q7: How would you handle exactly-once processing in a banking system?

> **Strong Answer**: Exactly-once requires three pieces working together:
>
> 1. **Idempotent Producer** (`enable.idempotence=True`) — prevents duplicate writes
>    on retry. The broker deduplicates based on producer ID + sequence number.
>
> 2. **Kafka Transactions** — atomic writes across multiple topics/partitions.
>    Producer calls `begin_transaction()`, produces messages, then `commit_transaction()`.
>
> 3. **Idempotent Consumer** — your application must handle receiving the same message
>    twice gracefully. Common patterns:
>    - Deduplicate by `transaction_id` (check if already processed)
>    - Use database upserts instead of inserts
>    - Track processed offsets in your application database
>
> *In my project, the producer uses `enable.idempotence=True` and the consumer uses
> manual offset commit after processing — achieving at-least-once delivery with
> idempotent processing logic.*

### Q8: When would you NOT use Kafka?

> **Strong Answer**: Kafka is overkill when you need:
> - Simple request/reply (use HTTP/gRPC)
> - Low message volume (<100 msg/sec) with simple routing (use RabbitMQ/SQS)
> - Short-lived task queues where message replay isn't needed
> - Strong message routing/filtering (RabbitMQ has better routing primitives)
>
> Kafka adds operational complexity (brokers, partitions, consumer groups) that
> doesn't pay off for simple use cases.

---

## Part 3: Operational Questions

### Q9: How do you monitor Kafka? What metrics matter?

> **Key metrics**:
>
> | Metric | Why it matters |
> |--------|----------------|
> | **Consumer lag** | Messages behind = processing is falling behind |
> | **Under-replicated partitions** | Replicas not in sync = data loss risk |
> | **Request latency** (p99) | Slow broker responses = bottleneck |
> | **Disk usage** | Kafka stores everything on disk |
> | **ISR shrinks** | Replicas falling out of sync |
>
> *Tools: Kafka UI (my project), Prometheus + JMX Exporter, Grafana dashboards,
> Confluent Control Center.*

### Q10: A consumer group is experiencing high lag. How do you diagnose?

> **Troubleshooting checklist**:
> 1. Check consumer group status: `kafka-consumer-groups.sh --describe --group <group>`
> 2. Is the consumer even running? Check for crashed/stuck consumers
> 3. Is processing slow? Profile the consumer's `process_transaction()` logic
> 4. Are there enough consumers? (consumers < partitions = underutilized parallelism)
> 5. Is the producer sending a burst? Compare producer rate vs. consumer rate
> 6. Network issues between consumer and broker?
>
> **Fix options**: Add more consumers to the group, increase `max.poll.records`,
> optimize processing logic, increase partition count (careful — can't decrease later!)

### Q11: How does Kafka handle broker failures?

> **Strong Answer**: Kafka replicates each partition across multiple brokers.
>
> 1. One replica is the **leader** (handles all reads/writes)
> 2. Other replicas are **followers** (replicate data from leader)
> 3. The **ISR** (In-Sync Replica set) tracks which followers are caught up
> 4. If the leader dies, a follower from the ISR is elected as new leader
> 5. Producers with `acks=all` won't lose data if at least one ISR replica survives
>
> With `replication-factor=3`, you can lose 2 brokers and still have the data.

---

## Part 4: Banking-Specific Scenarios

### Q12: How would you use Kafka for Change Data Capture (CDC) in a banking system?

> **Strong Answer**: CDC captures every insert/update/delete in a database and streams
> them as events to Kafka.
>
> - **Tool**: Debezium (open-source CDC connector for Kafka Connect)
> - **Flow**: Database → Debezium → Kafka → Downstream consumers
> - **Banking use case**: Capture account balance changes and stream to analytics,
>   audit trail, and notification services simultaneously
>
> Benefits:
> - Real-time data sync without polling
> - Complete audit trail (every change captured)
> - Downstream services stay eventually consistent
> - No changes needed to the source application

### Q13: How would Kafka fit into an anti-money laundering (AML) system?

> **Strong Answer**: (This connects to Project 4 — Actimize)
>
> 1. All financial transactions flow through `bank.transactions`
> 2. AML rules engine consumes transactions and applies pattern detection:
>    - Structuring (splitting deposits to avoid reporting thresholds)
>    - Unusual cross-border transfers
>    - Velocity checks (too many transactions in a time window)
> 3. Suspicious activities published to `bank.aml-alerts`
> 4. Alert dashboard consumes and shows cases for investigation
>
> Kafka's retention means you can reprocess historical transactions when new
> AML patterns are discovered.

---

## Part 5: Quick-Fire Questions

| Question | One-liner Answer |
|----------|-----------------|
| Max message size? | Default 1MB (`message.max.bytes`), configurable |
| Can you delete a message? | No. Use retention policy or compaction |
| What's log compaction? | Keeps only the latest value per key (like a KV store) |
| What's `acks=0`? | Fire and forget — fastest, least safe |
| What's `acks=1`? | Leader acknowledges — balanced |
| What's `acks=all`? | All ISR replicas acknowledge — safest (your project uses this) |
| What's a rebalance? | Partition reassignment when consumers join/leave a group |
| Can you decrease partitions? | No — only increase. Plan partition count carefully |
| What's the retention default? | 7 days (`log.retention.hours=168`) |
| Kafka vs. Kinesis? | Kafka = self-managed, more control. Kinesis = AWS-managed, less ops |

---

## 🗣️ How to Talk About Your Project in the Interview

> **"I built a Kafka-based event streaming platform for banking transaction processing.
> The system uses a single KRaft-mode broker with three partitioned topics:
> transactions, accounts, and fraud alerts. The producer generates realistic
> transaction events using key-based partitioning on account ID to guarantee
> per-account ordering. The consumer uses manual offset commits for at-least-once
> delivery semantics. I've configured idempotent production with acks=all for
> maximum durability. Next, I'm building a fraud detection consumer that reads
> from the transaction stream and publishes alerts to a separate topic."**

This demonstrates: hands-on experience, understanding of partitioning strategy,
delivery guarantees, and real-world application.
