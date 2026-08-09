"""
Kafka Producer — Bank Transaction Events
=========================================
Generates realistic mock banking transactions and publishes them to the
`bank.transactions` Kafka topic.

Usage:
    python3 src/producer.py                   # Produce 20 transactions (default)
    python3 src/producer.py --count 100       # Produce 100 transactions
    python3 src/producer.py --continuous      # Produce continuously (1 per second)

Key Kafka Concepts Demonstrated:
    - Producer configuration & instantiation
    - Message serialization (JSON)
    - Key-based partitioning (account_id → same partition = ordering guarantee)
    - Delivery callbacks for acknowledgement handling
    - Producer flushing to ensure all messages are sent
"""

import argparse
import json
import os
import random
import sys
import time
import uuid
from datetime import datetime, timezone

from confluent_kafka import Producer, KafkaError
from faker import Faker

# ── Configuration ─────────────────────────────────────────────────────────────

KAFKA_BOOTSTRAP_SERVERS = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
TOPIC = "bank.transactions"

# Producer configuration
# See: https://docs.confluent.io/platform/current/clients/confluent-kafka-python/html
PRODUCER_CONFIG = {
    "bootstrap.servers": KAFKA_BOOTSTRAP_SERVERS,

    # --- Reliability Settings ---
    # 'acks=all' means the leader waits for ALL in-sync replicas to acknowledge.
    # This is the SAFEST setting — no data loss even if the leader crashes.
    # Trade-off: slightly higher latency vs. 'acks=1' (leader only).
    "acks": "all",

    # --- Performance Settings ---
    # Batch messages for up to 100ms before sending — improves throughput.
    "linger.ms": 100,

    # Enable idempotent producer to prevent duplicate messages on retry.
    # INTERVIEW TIP: This is key to exactly-once semantics on the producer side.
    "enable.idempotence": True,

    # Number of retries for transient failures.
    "retries": 3,

    # Client ID for monitoring/debugging — shows up in broker logs & Kafka UI.
    "client.id": "bank-transaction-producer",
}

# ── Mock Data Generation ──────────────────────────────────────────────────────

fake = Faker()

TRANSACTION_TYPES = ["DEPOSIT", "WITHDRAWAL", "TRANSFER", "PAYMENT", "REFUND"]
CURRENCIES = ["USD", "EUR", "GBP", "MXN", "CAD"]
MERCHANT_CATEGORIES = [
    "GROCERY", "RESTAURANT", "GAS_STATION", "ONLINE_SHOPPING",
    "ATM", "UTILITY", "HEALTHCARE", "ENTERTAINMENT", "TRAVEL",
]


def generate_transaction() -> dict:
    """Generate a single mock bank transaction event."""
    account_id = f"ACCT-{random.randint(1000, 1099)}"  # ~100 accounts
    tx_type = random.choice(TRANSACTION_TYPES)

    # Make some transactions look suspicious for the fraud detector (Phase 2)
    is_suspicious = random.random() < 0.05  # 5% chance
    amount = round(random.uniform(5000, 50000), 2) if is_suspicious else round(random.uniform(1.00, 2500.00), 2)

    return {
        "transaction_id": str(uuid.uuid4()),
        "account_id": account_id,
        "type": tx_type,
        "amount": amount,
        "currency": random.choice(CURRENCIES),
        "merchant": fake.company(),
        "merchant_category": random.choice(MERCHANT_CATEGORIES),
        "location": {
            "city": fake.city(),
            "country": fake.country_code(),
        },
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "metadata": {
            "channel": random.choice(["MOBILE_APP", "WEB", "ATM", "BRANCH", "POS"]),
            "ip_address": fake.ipv4() if tx_type != "ATM" else None,
        },
    }


# ── Delivery Callback ────────────────────────────────────────────────────────

def delivery_callback(err, msg):
    """
    Called once per message to indicate delivery result.

    INTERVIEW TIP: This is an asynchronous callback. The producer doesn't block
    waiting for acknowledgements — it fires this callback when the broker
    responds. This is how you handle success/failure without blocking throughput.
    """
    if err is not None:
        print(f"  ❌ DELIVERY FAILED: {err}")
    else:
        # msg.partition() tells you which partition the message landed in.
        # msg.offset() is the message's position in that partition's log.
        print(
            f"  ✅ Delivered to {msg.topic()} "
            f"[partition={msg.partition()}, offset={msg.offset()}]"
        )


# ── Main Producer Loop ───────────────────────────────────────────────────────

def produce_transactions(count: int = 20, continuous: bool = False):
    """Produce mock bank transactions to Kafka."""

    print(f"🏦 Kafka Bank Transaction Producer")
    print(f"   Broker:     {KAFKA_BOOTSTRAP_SERVERS}")
    print(f"   Topic:      {TOPIC}")
    print(f"   Mode:       {'Continuous (Ctrl+C to stop)' if continuous else f'{count} messages'}")
    print(f"   Idempotent: {PRODUCER_CONFIG['enable.idempotence']}")
    print(f"   Acks:       {PRODUCER_CONFIG['acks']}")
    print("─" * 60)

    # Create the producer instance
    producer = Producer(PRODUCER_CONFIG)

    produced = 0
    try:
        while continuous or produced < count:
            transaction = generate_transaction()

            # ── KEY CONCEPT: Message Key & Partitioning ───────────────────
            # We use `account_id` as the message key. Kafka hashes the key
            # to determine the partition. This means:
            #   → All transactions for the SAME account go to the SAME partition
            #   → This guarantees ordering per account (critical in banking!)
            #
            # INTERVIEW TIP: "How do you ensure message ordering in Kafka?"
            # Answer: Use a consistent key. Ordering is guaranteed WITHIN a
            # partition, not across partitions.
            key = transaction["account_id"]
            value = json.dumps(transaction)

            # produce() is asynchronous — it queues the message in an internal
            # buffer and returns immediately. The actual send happens in the
            # background via librdkafka's I/O thread.
            producer.produce(
                topic=TOPIC,
                key=key,
                value=value,
                callback=delivery_callback,
            )

            # poll() triggers delivery callbacks for previously-produced messages.
            # Without this, callbacks would only fire on flush().
            producer.poll(0)

            produced += 1
            tx = transaction
            flag = " ⚠️ HIGH-VALUE" if tx["amount"] > 5000 else ""
            print(
                f"  [{produced}] {tx['type']:12s} | "
                f"{tx['account_id']} | "
                f"${tx['amount']:>10,.2f} {tx['currency']}{flag}"
            )

            if continuous:
                time.sleep(1)  # 1 transaction per second in continuous mode

    except KeyboardInterrupt:
        print("\n\n⏹️  Stopping producer (Ctrl+C)...")

    # ── FLUSH ─────────────────────────────────────────────────────────────
    # flush() blocks until ALL buffered messages are delivered (or timeout).
    # INTERVIEW TIP: Always flush before shutting down a producer, or you
    # WILL lose messages still sitting in the internal buffer.
    remaining = producer.flush(timeout=10)
    if remaining > 0:
        print(f"  ⚠️  {remaining} messages were NOT delivered (timeout).")
    else:
        print(f"\n✅ All {produced} transactions produced successfully.")


# ── CLI ───────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Bank Transaction Kafka Producer")
    parser.add_argument("--count", type=int, default=20, help="Number of transactions to produce (default: 20)")
    parser.add_argument("--continuous", action="store_true", help="Produce continuously (1/sec, Ctrl+C to stop)")
    args = parser.parse_args()

    produce_transactions(count=args.count, continuous=args.continuous)
