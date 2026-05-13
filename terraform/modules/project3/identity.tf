terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.keycloak_admin_username
  password  = var.keycloak_admin_password
  url       = var.keycloak_url
}

resource "keycloak_realm" "mockbank_realm" {
  realm        = "MockBankRealm"
  enabled      = true
  display_name = "Mockbank Banking Realm"
  
  # Security settings aligned with the spec
  password_policy = "upperCase(1) and lowerCase(1) and digits(1) and length(32)"
}

# --- SAML Certificate Generation ---

# Generate a private key for the Teller Portal (SP)
resource "tls_private_key" "teller_portal_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a self-signed certificate using the private key
resource "tls_self_signed_cert" "teller_portal_cert" {
  private_key_pem = tls_private_key.teller_portal_key.private_key_pem

  subject {
    common_name  = "teller.altmtrk.com"
    organization = "Altmtrk Bank"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Store the certificate in Secret Manager for the Teller Portal to consume
resource "google_secret_manager_secret" "teller_portal_cert" {
  project   = var.compute_project_id
  secret_id = var.teller_portal_certificate_id
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "teller_portal_cert_version" {
  secret      = google_secret_manager_secret.teller_portal_cert.id
  secret_data = tls_self_signed_cert.teller_portal_cert.cert_pem
}

# The Retail Banking App (OIDC Client)
resource "keycloak_openid_client" "retail_app" {
  realm_id              = keycloak_realm.mockbank_realm.id
  client_id             = "retail-app"
  name                  = "Retail Banking Application"
  enabled               = true
  access_type           = "PUBLIC"
  standard_flow_enabled = true
  
  # Enforce PKCE S256 as per Project 1 Spec
  pkce_code_challenge_method = "S256"
  
  valid_redirect_uris = [
    "http://localhost:3000/*",
    "https://retail.altmtrk.com/*"
  ]

  web_origins = ["*"]
}

# Fraud Team Requirement: The 'risk' scope
resource "keycloak_openid_client_scope" "risk_scope" {
  realm_id = keycloak_realm.mockbank_realm.id
  name     = "risk"
  description = "Scope containing risk evaluation metadata for the Transaction Service"
  include_in_token_scope = true
}

# --- Legacy Teller Portal (SAML Client) ---

resource "keycloak_saml_client" "teller_portal" {
  realm_id  = keycloak_realm.mockbank_realm.id
  client_id = "teller-portal"
  name      = "Legacy Teller Portal"
  enabled   = true

  include_authn_statement = true
  sign_documents          = true
  sign_assertions         = true
  encrypt_assertions      = true

  # Keycloak uses this public cert to verify SP signatures and encrypt assertions
  encryption_certificate = tls_self_signed_cert.teller_portal_cert.cert_pem
  signing_certificate    = tls_self_signed_cert.teller_portal_cert.cert_pem

  valid_redirect_uris = [
    "https://teller.altmtrk.com/saml/consume"
  ]
}
