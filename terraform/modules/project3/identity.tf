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
  realm                = "mockbank"
  enabled              = true
  display_name         = "MockBank Digital"
  registration_allowed = true
}

resource "keycloak_openid_client" "retail_app" {
  realm_id              = keycloak_realm.mockbank_realm.id
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
  realm_id               = keycloak_realm.mockbank_realm.id
  name                   = "risk_assessment"
  description            = "Access to risk assessment services"
  include_in_token_scope = true
}
