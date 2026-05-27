# identity.tf
# Part of the consolidated Foundation Infrastructure.
# Manages Keycloak Realm and OIDC configuration.
terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
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
  realm_id               = keycloak_realm.mockbank_realm.id
  name                   = "risk"
  description            = "Scope containing risk evaluation metadata for the Transaction Service"
  include_in_token_scope = true
}