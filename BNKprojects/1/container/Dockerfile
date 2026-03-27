# STAGE 1: Build optimized Keycloak server
FROM quay.io/keycloak/keycloak:24.0.1 AS builder

WORKDIR /opt/keycloak

# Build-time configuration
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Create an optimized server runtime in the builder stage
RUN /opt/keycloak/bin/kc.sh build

# STAGE 2: Create the final, lighter runtime image
FROM quay.io/keycloak/keycloak:24.0.1

# Copy the optimized server from the builder stage to the final image
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Security: Configure proxy mode for Cloud Run (TLS termination at edge)
# This ensures cookies are marked 'Secure' and redirects use HTTPS.
ENV KC_PROXY=edge
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=true

# Configure a database vendor for runtime
ENV KC_DB=postgres

# Run as non-root user for security
USER keycloak

WORKDIR /opt/keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]