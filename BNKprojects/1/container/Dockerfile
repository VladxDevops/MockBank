# STAGE 1: Build optimized Keycloak server
FROM quay.io/keycloak/keycloak:24.0.1 AS builder

# Configure a database vendor for the build
ENV KC_DB=postgres
WORKDIR /opt/keycloak
# This build step creates an optimized server runtime.
RUN /opt/keycloak/bin/kc.sh build

# STAGE 2: Create the final, lighter runtime image
FROM quay.io/keycloak/keycloak:24.0.1

# Copy only the optimized server from the builder stage
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor for runtime
ENV KC_DB=postgres

# Run as non-root user for security
USER keycloak

WORKDIR /opt/keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]