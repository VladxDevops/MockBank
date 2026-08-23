+++
title = "Redis Cache External Integration Guide"
domain = "database"
topics = ["redis", "memorystore", "caching", "integration", "gateway"]
difficulty = "intermediate"
parent = "../README.md"
related = ["internal/redis/README.md"]
updated_by = "AI Context Specialist"
version = "1.1"
+++

> **Parent**: [`../README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/README.md)  
> **Internal Guide**: [`internal/redis/README.md`](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/Documentation/internal/redis/README.md)

---

# Redis Cache External Integration Guide

This document defines the configuration, client connection guidelines, and access patterns for microservices consuming the caching and session-store services on the Altmtrk2026("MockBank") Bank Platform.

---

## ⚙️ Connection Configuration

For security and networking consistency, all services must bind to the standard Redis configuration environment variables.

### Environment Variable Standards
| Variable | Description | Default Value (Local Dev) | Production Standard |
|---|---|---|---|
| `REDIS_HOST` | Redis Server Hostname/IP | `localhost` | GCP Memorystore IP (Private VPC) |
| `REDIS_PORT` | Redis TCP Port | `6379` | `6379` (Forced) |
| `REDIS_SSL` | Enable TLS/SSL Connection | `false` | `true` |
| `REDIS_PASSWORD` | Access credential (AUTH) | *None* | Google Secret Manager Ref |
| `REDIS_TIMEOUT_MS`| Read/Write timeout in milliseconds | `500` | `1000` |
| `REDIS_DB` | Logical database partition | `0` (Sessions) | `0` (Sessions) / `1` (App Cache) |

---

## 🔌 Connection Management Best Practices

### 1. Connection Pooling
Microservices must utilize connection pools instead of opening/closing socket connections for each command. This reduces TCP handshake overhead.

* **Python (redis-py) Example:**
```python
import os
import redis

# Initialize connection pool globally (thread-safe)
redis_pool = redis.ConnectionPool(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    db=int(os.getenv("REDIS_DB", 0)),
    password=os.getenv("REDIS_PASSWORD", None),
    ssl=os.getenv("REDIS_SSL", "false").lower() == "true",
    socket_timeout=1.0,      # 1 second timeout
    decode_responses=True    # Auto-decode bytes to string
)

def get_redis_client():
    return redis.Redis(connection_pool=redis_pool)
```

### 2. Graceful Error Handling & Fallback
Redis caches must be treated as **volatile stores**. Applications must handle cache offline events gracefully and fall back directly to primary databases.

* **Fail-Safe Pattern:**
```python
def get_user_session(user_id):
    try:
        r = get_redis_client()
        session = r.get(f"session:{user_id}")
        if session:
            return session
    except redis.RedisError as e:
        # Log the connection warning to Cloud Logging
        print(f"Warning: Redis cache connection failure: {e}")
        # Fall back to database query
        return fetch_session_from_db(user_id)
```

---

## 📈 Health Checking & Monitoring

API gateways and orchestration engines (like Kubernetes or Cloud Run) must query the Redis health check to monitor service health.

1. **Liveness Probe CLI Probe:**
   ```bash
   redis-cli -h $REDIS_HOST -p $REDIS_PORT ping
   # Expected response: PONG
   ```
2. **Prometheus Exporter Output:**
   Expose Redis metrics (memory usage, connected clients, hit/miss ratio, blocked clients) on `/metrics` via the standard Redis Prometheus exporter.

---

<!-- AI RETRIEVAL HINTS
- Purpose: Redis integration guide for external clients/microservices.
- Questions Answered: How are environment variables named for Redis client connection? How is connection pooling structured?
- When to Retrieve: Setting up connections to Redis caches from core microservices, setting up liveness/readiness health probes.
- When NOT to Retrieve: When studying internal security details (refer to Documentation/internal/redis/README.md) or checking Kafka message routing (refer to Project 5).
-->
