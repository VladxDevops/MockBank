terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}


# --- Workload Identity Federation for GitHub Actions ---
# These require a running Keycloak instance to be managed via the Keycloak provider.

# ARCHITECTURAL DECISION:
# This platform is designed as a cloud-native greenfield deployment. There is no requirement 
# to support legacy systems, applications, or services. As such, OIDC is the primary 
# authentication protocol, and there is no implementation of legacy SAML support.

resource "keycloak_realm" "mockbank_realm" {
  count = var.enable_keycloak_identity_config ? 1 : 0

  realm                = "Mockbankrealm"
  enabled              = true
  display_name         = "MockBank Digital"
  registration_allowed = true
}

resource "keycloak_openid_client" "retail_app" {
  count = var.enable_keycloak_identity_config ? 1 : 0

  realm_id              = keycloak_realm.mockbank_realm[0].id
  client_id             = "retail-app"
  name                  = "Retail Banking Application"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "http://localhost:3000/*",
    "https://retail-app.mockbank.com/*"
  ]
}

resource "keycloak_openid_client_scope" "risk_scope" {
  count = var.enable_keycloak_identity_config ? 1 : 0

  realm_id               = keycloak_realm.mockbank_realm[0].id
  name                   = "risk_assessment"
  description            = "Access to risk assessment services"
  include_in_token_scope = true
}

#Habia una vez un barco chiquito...
