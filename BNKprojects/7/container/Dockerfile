# Dockerfile for MuleSoft Mule Integration Layer (Project 7)
# This Dockerfile builds a Mule application container optimized for GCP Cloud Run deployment
# Base image: Mule Enterprise Service Edition (ESE) - uses Java 11 runtime
# Reference: https://hub.docker.com/r/mulesoft/mule

# ============================================================================
# STAGE 1: Builder (Compile and Package Mule Application)
# ============================================================================
FROM mulesoft/mule:4.4-java11-alpine AS builder

# Set working directory
WORKDIR /build

# Copy POM file for Maven builds (if using Maven-based project)
COPY pom.xml ./
COPY settings.xml* ./

# Copy application source code
COPY src/ ./src/
COPY mule-artifacts.json ./
COPY exchange-docs/ ./exchange-docs/

# Build the Mule application JAR
# This requires Maven to be pre-installed or using mule-maven-plugin
# Note: For Mule projects, the deliverable is typically an .mule file (JAR wrapper)
RUN apt-get update && apt-get install -y maven && \
    mvn clean package -DskipTests -q && \
    apt-get remove -y maven && \
    apt-get clean

# ============================================================================
# STAGE 2: Runtime Image (Mule ESE with Application)
# ============================================================================
FROM mulesoft/mule:4.4-java11-alpine

# Metadata labels for GCP and organization tracking
LABEL org.opencontainers.image.title="Mule Integration Layer"
LABEL org.opencontainers.image.description="MuleSoft Anypoint-managed integration service for Altmtrk2026(MockBank) Bank"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.vendor="Altmtrk2026(MockBank)"

# ============================================================================
# Build Arguments (can be overridden at build time)
# ============================================================================
# These are loaded from docker-compose or passed via --build-arg flag
# Example: docker build --build-arg JAVA_MAX_HEAP=2048 --build-arg LOG_LEVEL=DEBUG .
# See ../.env.example for all available variables and their defaults
#
ARG MULE_HTTP_PORT=8081
ARG MULE_MANAGEMENT_PORT=8888
ARG JAVA_MAX_HEAP=1024
ARG JAVA_MIN_HEAP=1024
ARG JAVA_GC_TYPE=G1GC
ARG LOG_LEVEL=INFO
ARG HEALTH_CHECK_INTERVAL=30
ARG HEALTH_CHECK_TIMEOUT=10
ARG HEALTH_CHECK_START_PERIOD=40
ARG HEALTH_CHECK_RETRIES=3

# Set working directory
WORKDIR /opt/mule

# Copy compiled application from builder stage
# The JAR should be placed in the 'apps' directory so Mule auto-deploys it on startup
COPY --from=builder /build/target/*.jar /opt/mule/apps/

# Copy configuration and policy files (if any)
COPY config/ /opt/mule/config/ 2>/dev/null || true
COPY policies/ /opt/mule/policies/ 2>/dev/null || true

# ============================================================================
# Runtime Configuration
# ============================================================================

# Security: Run as non-root Mule user (built into mulesoft/mule image)
USER mule

# Expose Mule HTTP listener port (from ARG or default 8081)
EXPOSE ${MULE_HTTP_PORT}

# Expose Mule management port for monitoring (optional)
# Uncomment if using Anypoint Runtime Fabric or on-premise deployments
# EXPOSE ${MULE_MANAGEMENT_PORT}

# Health check for Cloud Run startup probe
# Checks the Mule health endpoint (variables from .env)
HEALTHCHECK --interval=${HEALTH_CHECK_INTERVAL}s --timeout=${HEALTH_CHECK_TIMEOUT}s --start-period=${HEALTH_CHECK_START_PERIOD}s --retries=${HEALTH_CHECK_RETRIES} \
    CMD curl -f http://localhost:${MULE_HTTP_PORT}/api/health || exit 1

# ============================================================================
# Startup Configuration
# ============================================================================

# Environment variables for Mule runtime configuration
# These can be overridden at container startup time via Cloud Run env vars or docker -e flags
ENV MULE_HOME=/opt/mule
ENV MULE_ENV=cloud
ENV MULE_AGENT_ENABLED=false
ENV LOG_LEVEL=${LOG_LEVEL}

# Construct JAVA_OPTS from individual parameters (supports runtime tuning)
# Example: docker run -e JAVA_MAX_HEAP=2048 ...
ENV JAVA_OPTS="-server -Xmx${JAVA_MAX_HEAP}m -Xms${JAVA_MIN_HEAP}m -XX:+Use${JAVA_GC_TYPE} -XX:+UseStringDeduplication"

# Mule startup command
# The mule command starts the Mule runtime and auto-deploys applications in /opt/mule/apps
ENTRYPOINT ["/opt/mule/bin/mule"]
CMD ["-M", "-m", "mulecloud"]

# ============================================================================
# Runtime Environment Variables
# ============================================================================
# For DEV/TEST/PROD environments, pass these at runtime via:
#   - GCP Secret Manager (cloud.google.com/secret-manager)
#   - Cloud Run environment variables (gcloud run deploy --set-env-vars)
#   - Terraform (apply env vars to service spec)
#   - Docker run: docker run -e VAR_NAME=value ...
#
# Reference: See ../.env.example for all available variables
#   - ANYPOINT_ENVIRONMENT: (development, testing, production)
#   - ANYPOINT_ORGANIZATION_ID: (Anypoint org UUID)
#   - ANYPOINT_PLATFORM_BASE_URL: (https://anypoint.mulesoft.com or EU region)
#   - DB_HOST, DB_PORT, DB_PASSWORD: (via GCP Secret Manager)
#   - KAFKA_BROKERS, PUBSUB_PROJECT_ID: (for event backbone integration)
#   - KEYCLOAK_URL, KEYCLOAK_CLIENT_SECRET: (Project 1 integration)
#   - TRANSACTION_SERVICE_URL: (Project 2 integration)
#   - TLS_KEY_STORE_PASSWORD, TLS_TRUST_STORE_PASSWORD: (security)
#   - LOG_LEVEL: (DEBUG, INFO, WARN, ERROR)
# ============================================================================
