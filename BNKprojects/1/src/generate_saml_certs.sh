#!/bin/bash
# Generates self-signed certificates for the SAML Service Provider (SP)

CERT_DIR="$(dirname "$0")/certs"
mkdir -p "$CERT_DIR"

echo "[INFO] Generating self-signed certificates in $CERT_DIR..."

openssl req -new -x509 -days 365 -nodes \
    -out "$CERT_DIR/sp.crt" \
    -keyout "$CERT_DIR/sp.key" \
    -subj "/C=US/ST=Texas/L=Austin/O=AltmtrkBank/OU=IT/CN=localhost"