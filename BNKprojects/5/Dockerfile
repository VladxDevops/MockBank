# Multi-stage build for Kafka python clients

# ── Stage 1: Build dependencies ──────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# Install compiler tools and library dependencies needed for compiling python libraries if necessary
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment to isolate installed packages
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Stage 2: Runtime image ───────────────────────────────────────────
FROM python:3.11-slim AS runner

# Set Python environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Copy the built virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy only requirements and Python application source code 
COPY src/ /app/src/

# Create a system group and non-root system user with explicit UID/GID (10001)
RUN groupadd -g 10001 appgroup && \
    useradd -r -u 10001 -g appgroup appuser

# Set ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Default command runs the producer, can be overridden in docker compose 
CMD ["python", "src/producer.py"]
