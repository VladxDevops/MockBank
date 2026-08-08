"""
Kafka Consumer — Bank Transaction Events
==========================================
Subscribes to the `bank.transactions` topic and processes each transaction event.
Demonstrates consumer groups, offset management, and graceful shutdown.

Usage:
    python3 src/consumer.py                              # Default consumer group
    python3 src/consumer.py --group audit-service        # Named consumer group
    python3 src/consumer.py --from-beginning             # Read all history

Key Kafka Concepts Demonstrated:
    - Consumer groups (parallel processing & load balancing)
    - Partition assignment & rebalancing
    - Offset management (auto-commit vs. manual commit)
    - Graceful shutdown and consumer cleanup
    - Deserialization of JSON messages

INTERVIEW TIP — Consumer Groups:
    If you run TWO consumers with the SAME group ID, they split the partitions
    between them (load balancing). If they have DIFFERENT group IDs, they each
    get ALL partitions (fan-out / broadcast). This is a very common interview Q.
"""

import argparse
import json
import signal
import sys
from datetime import datetime

from confluent_kafka import Consumer, KafkaError, KafkaException

# ── Configuration ─────────────────────────────────────────────────────────────

KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
TOPIC = "bank.transactions"

# ── Stats Tracking ────────────────────────────────────────────────────────────

stats = {
    "total": 0,
    "by_type": {},
    "total_amount": 0.0,
    "high_value_count": 0,   # transactions > $5000
}


def build_consumer_config(group_id: str, from_beginning: bool) -> dict:
    """
    Build Kafka consumer configuration.

    INTERVIEW TIP: Key settings to know and explain:
    - group.id: Identifies which consumer group this consumer belongs to
    - auto.offset.reset: What to do when there's no committed offset
      → 'earliest' = read from the beginning (don't miss old messages)
      → 'latest' = only read NEW messages (skip history)
    - enable.auto.commit: Whether offsets are committed automatically
      → True = simpler but risk of processing a message twice (at-least-once)
      → False = you control exactly when to commit (needed for exactly-once)
    """
    return {
        "bootstrap.servers": KAFKA_BOOTSTRAP_SERVERS,
        "group.id": group_id,
        "auto.offset.reset": "earliest" if from_beginning else "latest",

        # ── Offset Commit Strategy ────────────────────────────────────────
        # We use MANUAL commit here so you can see exactly when offsets are
        # committed. In production, you'd commit AFTER successfully processing
        # a batch of messages.
        #
        # INTERVIEW TIP: "What happens if the consumer crashes before
        # committing?" → The message will be re-delivered to another consumer
        # in the group (at-least-once delivery). Your processing logic must
        # be IDEMPOTENT to handle this safely.
        "enable.auto.commit": False,

        # How often to send heartbeats to the group coordinator.
        # If no heartbeat for session.timeout.ms, the consumer is considered
        # dead and its partitions are reassigned (rebalancing).
        "heartbeat.interval.ms": 3000,
        "session.timeout.ms": 30000,

        "client.id": f"bank-consumer-{group_id}",
    }


# ── Message Processing ───────────────────────────────────────────────────────

def process_transaction(msg) -> bool:
    """
    Process a single bank transaction message.

    Returns True if processing succeeded (safe to commit offset).
    Returns False if processing failed (should NOT commit — retry later).
    """
    try:
        # Deserialize the JSON value
        transaction = json.loads(msg.value().decode("utf-8"))
        key = msg.key().decode("utf-8") if msg.key() else "N/A"

        # Update stats
        stats["total"] += 1
        tx_type = transaction.get("type", "UNKNOWN")
        stats["by_type"][tx_type] = stats["by_type"].get(tx_type, 0) + 1
        amount = transaction.get("amount", 0)
        stats["total_amount"] += amount

        # Flag high-value transactions
        high_value = amount > 5000
        if high_value:
            stats["high_value_count"] += 1

        # ── Display ───────────────────────────────────────────────────────
        flag = " 🚨 HIGH-VALUE" if high_value else ""
        print(
            f"  📥 [{stats['total']:>4}] "
            f"partition={msg.partition()} offset={msg.offset():>6} | "
            f"{tx_type:12s} | {key} | "
            f"${amount:>10,.2f} {transaction.get('currency', '???')}"
            f"{flag}"
        )

        if high_value:
            print(
                f"       ⚠️  High-value alert: {transaction.get('merchant', 'N/A')} "
                f"in {transaction.get('location', {}).get('city', '?')}, "
                f"{transaction.get('location', {}).get('country', '?')}"
            )

        return True

    except json.JSONDecodeError as e:
        print(f"  ❌ Failed to deserialize message: {e}")
        return False
    except Exception as e:
        print(f"  ❌ Processing error: {e}")
        return False


def print_stats():
    """Print summary statistics."""
    print("\n" + "═" * 60)
    print("📊 Session Summary")
    print("═" * 60)
    print(f"  Total messages consumed:  {stats['total']}")
    print(f"  Total transaction value:  ${stats['total_amount']:,.2f}")
    print(f"  High-value transactions:  {stats['high_value_count']}")
    print(f"  Breakdown by type:")
    for tx_type, count in sorted(stats['by_type'].items()):
        print(f"    {tx_type:15s}: {count}")
    print("═" * 60)


# ── Main Consumer Loop ───────────────────────────────────────────────────────

def consume_transactions(group_id: str, from_beginning: bool):
    """Main consumer loop — subscribe, poll, process, commit."""

    config = build_consumer_config(group_id, from_beginning)

    print(f"🏦 Kafka Bank Transaction Consumer")
    print(f"   Broker:         {KAFKA_BOOTSTRAP_SERVERS}")
    print(f"   Topic:          {TOPIC}")
    print(f"   Consumer Group: {group_id}")
    print(f"   Offset Reset:   {'earliest (from beginning)' if from_beginning else 'latest (new only)'}")
    print(f"   Auto-Commit:    {config['enable.auto.commit']}")
    print("─" * 60)
    print("   Waiting for messages... (Ctrl+C to stop)\n")

    # Create consumer instance
    consumer = Consumer(config)

    # ── SUBSCRIBE ─────────────────────────────────────────────────────────
    # subscribe() registers this consumer with the group coordinator.
    # The coordinator then ASSIGNS partitions to this consumer.
    #
    # INTERVIEW TIP: subscribe() is lazy — no connection happens until poll().
    # Also, partition assignment can CHANGE at any time (rebalancing) if
    # consumers join/leave the group.
    consumer.subscribe([TOPIC])

    # Graceful shutdown on Ctrl+C
    running = True

    def signal_handler(sig, frame):
        nonlocal running
        print("\n\n⏹️  Shutting down consumer (Ctrl+C)...")
        running = False

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    try:
        while running:
            # ── POLL ──────────────────────────────────────────────────────
            # poll() fetches a single message (or returns None on timeout).
            # The timeout (1.0s) is how long to block if no messages are
            # available. In production, you'd often use consume() to fetch
            # batches for better throughput.
            msg = consumer.poll(timeout=1.0)

            if msg is None:
                continue  # No message within timeout — poll again

            if msg.error():
                # ── PARTITION EOF ─────────────────────────────────────────
                # This isn't really an error — it means we've read to the
                # end of a partition. Kafka will send new messages as they
                # arrive.
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    print(
                        f"  ℹ️  Reached end of {msg.topic()} "
                        f"[partition={msg.partition()}, offset={msg.offset()}]"
                    )
                    continue
                else:
                    raise KafkaException(msg.error())

            # Process the message
            success = process_transaction(msg)

            if success:
                # ── MANUAL COMMIT ─────────────────────────────────────────
                # We commit the offset AFTER successful processing.
                # This means: "I have processed up to this offset — don't
                # send it to me again."
                #
                # INTERVIEW TIP: Committing BEFORE processing = at-most-once
                # (you might lose messages). Committing AFTER = at-least-once
                # (you might process duplicates). Choose based on your use case.
                # Banking usually needs at-least-once + idempotent processing.
                consumer.commit(asynchronous=False)

    except KafkaException as e:
        print(f"\n❌ Kafka error: {e}")
        sys.exit(1)

    finally:
        # ── CLOSE ─────────────────────────────────────────────────────────
        # close() triggers a final offset commit and tells the group
        # coordinator this consumer is leaving. Without close(), the
        # coordinator has to wait for session.timeout.ms before reassigning
        # partitions — causing a delay.
        print_stats()
        consumer.close()
        print("👋 Consumer closed cleanly.")


# ── CLI ───────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Bank Transaction Kafka Consumer")
    parser.add_argument(
        "--group", type=str, default="transaction-processor",
        help="Consumer group ID (default: transaction-processor)"
    )
    parser.add_argument(
        "--from-beginning", action="store_true",
        help="Read all messages from the beginning of the topic"
    )
    args = parser.parse_args()

    consume_transactions(group_id=args.group, from_beginning=args.from_beginning)
