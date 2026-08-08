# Kafka Core Concepts — Learning Notes

> These notes are tied to your hands-on project code. Each concept includes a pointer
> to where you can see it in action.

---

## 1. Broker

A Kafka **broker** is a single Kafka server process. It receives messages from producers,
stores them on disk, and serves them to consumers.

- Your project runs **1 broker** via Docker → see `docker-compose.yml` (`kafka` service)
- Production clusters typically run 3–5+ brokers for fault tolerance
- Each broker is identified by a unique `KAFKA_NODE_ID`

**Interview phrasing**: *"A broker is a single node in a Kafka cluster responsible for
storing partitions and serving client requests."*

---

## 2. Topic

A **topic** is a named, logical stream of messages. Think of it as a "category" or
"channel" that producers write to and consumers read from.

- Your project creates 3 topics: `bank.transactions`, `bank.accounts`, `bank.fraud-alerts`
- See the `init-topics` service in `docker-compose.yml`
- Topics are **append-only logs** — messages are never modified, only added

---

## 3. Partition

Each topic is divided into one or more **partitions**. A partition is an ordered,
immutable sequence of messages.

- `bank.transactions` has **3 partitions** (see `docker-compose.yml`)
- **Ordering is guaranteed WITHIN a partition** but NOT across partitions
- This is why the producer uses `account_id` as the key → all transactions for the
  same account land in the same partition → ordering is preserved per account

**See it in action**: `src/producer.py` → the `key=transaction["account_id"]` line

**Interview phrasing**: *"Partitions are Kafka's unit of parallelism. More partitions =
more consumers can read in parallel. Ordering is per-partition only."*

---

## 4. Producer

A **producer** publishes messages to a topic. The producer decides:
- **Which topic** to write to
- **Which key** to use (determines partition assignment)
- **Which serialization** format (JSON, Avro, Protobuf)

Key producer settings to know:
| Setting | What it does | Your project |
|---------|-------------|--------------|
| `acks=all` | Wait for ALL replicas to acknowledge | `producer.py` |
| `enable.idempotence=True` | Prevent duplicate messages on retry | `producer.py` |
| `linger.ms=100` | Batch messages for 100ms before sending | `producer.py` |

**See it in action**: `src/producer.py` — entire file

---

## 5. Consumer & Consumer Groups

A **consumer** reads messages from topic partitions. Consumers are organized into
**consumer groups**.

### Key rules:
1. Each partition is assigned to **exactly one consumer** within a group
2. If you have 3 partitions and 2 consumers in the same group → one consumer gets 2 partitions, the other gets 1
3. If you have 3 partitions and 4 consumers → one consumer sits idle (more consumers than partitions = waste)
4. Two consumers in **different** groups each get ALL partitions (broadcast pattern)

**See it in action**: `src/consumer.py` → `--group` argument

**Try it yourself**:
```bash
# Terminal 1: Start consumer in group "team-a"
python3 src/consumer.py --group team-a --from-beginning

# Terminal 2: Start ANOTHER consumer in same group → partitions split!
python3 src/consumer.py --group team-a --from-beginning

# Terminal 3: Start consumer in DIFFERENT group → gets ALL messages
python3 src/consumer.py --group team-b --from-beginning
```

---

## 6. Offset

An **offset** is a sequential ID number assigned to each message within a partition.
It represents the message's position in the partition log.

- Offsets start at 0 and increment by 1 for each new message
- Consumers track their position by **committing offsets**
- If a consumer crashes and restarts, it resumes from its last committed offset

### Commit strategies:
| Strategy | Risk | When to use |
|----------|------|-------------|
| Auto-commit | May reprocess messages (at-least-once) | Simple, non-critical workloads |
| Manual commit AFTER processing | May reprocess on crash (at-least-once) | Most production use cases |
| Manual commit BEFORE processing | May lose messages (at-most-once) | When losing is acceptable |

**See it in action**: `src/consumer.py` → `consumer.commit(asynchronous=False)`

---

## 7. KRaft vs. Zookeeper

Historically, Kafka depended on **Zookeeper** for cluster metadata and leader election.
**KRaft** (Kafka Raft) is the new built-in consensus protocol that replaces Zookeeper.

- Your project uses **KRaft** → see `KAFKA_PROCESS_ROLES: broker,controller` in `docker-compose.yml`
- KRaft is simpler (fewer moving parts), faster recovery, and the future of Kafka
- Zookeeper support is being removed in Kafka 4.0

**Interview phrasing**: *"KRaft is Kafka's built-in metadata management protocol that
replaces Zookeeper. It simplifies the architecture by eliminating the need for a
separate coordination service."*

---

## 8. Replication

Each partition can have multiple **replicas** spread across different brokers.
One replica is the **leader** (handles all reads/writes), the rest are **followers**
(stay in sync for failover).

- Your project uses `replication-factor=1` (single broker, so no replication)
- Production should use `replication-factor=3` (tolerates 2 broker failures)
- **ISR** (In-Sync Replicas) = the set of replicas that are caught up with the leader

**Interview phrasing**: *"Replication provides fault tolerance. The ISR (in-sync
replica) set determines which replicas are eligible to become leader if the current
leader fails."*

---

## 9. Delivery Guarantees

| Guarantee | Description | How to achieve |
|-----------|-------------|----------------|
| At-most-once | Messages may be lost, never duplicated | Commit offset before processing |
| At-least-once | Messages never lost, may be duplicated | Commit offset after processing (your consumer) |
| Exactly-once | Messages never lost, never duplicated | Idempotent producer + transactions + idempotent consumer |

**See it in action**:
- Producer: `enable.idempotence=True` in `src/producer.py`
- Consumer: manual commit after processing in `src/consumer.py`

---

## 10. Common CLI Commands

```bash
# List all topics
docker exec kafka-bank /opt/kafka/bin/kafka-topics.sh \
  --list --bootstrap-server localhost:9092

# Describe a topic (partitions, replicas, ISR)
docker exec kafka-bank /opt/kafka/bin/kafka-topics.sh \
  --describe --topic bank.transactions --bootstrap-server localhost:9092

# Read messages from console
docker exec kafka-bank /opt/kafka/bin/kafka-console-consumer.sh \
  --topic bank.transactions --from-beginning --bootstrap-server localhost:9092

# Check consumer group lag
docker exec kafka-bank /opt/kafka/bin/kafka-consumer-groups.sh \
  --describe --group transaction-processor --bootstrap-server localhost:9092
```
