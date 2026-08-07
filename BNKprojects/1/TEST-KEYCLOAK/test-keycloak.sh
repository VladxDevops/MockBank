#!/bin/bash

# Altmtrk2026 Bank - Keycloak Automated Testing Script
# This script automates verification of the Identity Service on Cloud Run.

# Load environment variables if the file exists
if [[ ! -f "./test-env.sh" ]]; then
    echo -e "\e[31mERROR: Configuration file 'test-env.sh' not found.\e[0m"
    echo "This script requires an environment file to prevent hardcoded defaults."
    exit 1
fi

source ./test-env.sh

# Enforce required variables
REQUIRED_VARS=(REGION SERVICE_NAME PROXY_PORT REALM CLIENT_ID ADMIN_SECRET_NAME DB_INSTANCE_NAME VPC_CONNECTOR_NAME ADMIN_USERNAME)
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo -e "\e[31mERROR: Required variable '$var' is not set in test-env.sh.\e[0m"
        exit 1
    fi
done

# Keycloak Admin Credentials - Strictly from Secret Manager
echo "Fetching Keycloak Admin Password from Secret Manager..."
ADMIN_PASSWORD=$(gcloud secrets versions access latest --secret="$ADMIN_SECRET_NAME" 2>/dev/null)

if [[ -z "$ADMIN_PASSWORD" ]]; then
    echo -e "\e[31mERROR: Failed to retrieve secret '$ADMIN_SECRET_NAME'.\e[0m"
    echo "Ensure you are authenticated with gcloud and have secretAccessor permissions."
    exit 1
fi

check_infrastructure_health() {
    echo -e "\e[34m[PRE-FLIGHT] Checking Infrastructure Health...\e[0m"
    
    # Check Cloud SQL Instance Tier and Status
    local DB_INFO=$(gcloud sql instances describe "$DB_INSTANCE_NAME" --format="csv[no-heading](settings.tier,state)" 2>/dev/null)
    if [[ -n "$DB_INFO" ]]; then
        local TIER=$(echo $DB_INFO | cut -d',' -f1)
        local STATE=$(echo $DB_INFO | cut -d',' -f2)
        
        echo "Database Tier: $TIER"
        echo "Database State: $STATE"
        
        if [[ "$TIER" == "db-f1-micro" ]]; then
            echo -e "\e[33mWARNING: Instance is running on db-f1-micro. This tier is prone to JDBC 'Acquisition timeout' errors during peak load or cold starts.\e[0m"
        fi
        
        if [[ "$STATE" != "RUNNABLE" ]]; then
            echo -e "\e[31mERROR: Database is not in RUNNABLE state ($STATE).\e[0m"
            return 1
        fi
    fi

    # Check VPC Connector Status
    local CONN_STATE=$(gcloud compute repository-v2-vpc-access connectors describe "$VPC_CONNECTOR_NAME" --region "$REGION" --format="value(state)" 2>/dev/null || \
                       gcloud compute vpc-access connectors describe "$VPC_CONNECTOR_NAME" --region "$REGION" --format="value(state)" 2>/dev/null)
    if [[ "$CONN_STATE" != "READY" ]]; then
        echo -e "\e[33mWARNING: VPC Connector '$VPC_CONNECTOR_NAME' state is '$CONN_STATE'. Database connectivity may be unstable.\e[0m"
    else
        echo "VPC Connector: READY"
    fi
    return 0
}

check_dependencies() {
    for cmd in gcloud curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "ERROR: Dependency '$cmd' is not installed."
            exit 1
        fi
    done
}

fetch_logs() {
    echo -e "\n\e[33m--- [TROUBLESHOOTING] Fetching Cloud Run Logs (Filtering for Errors) ---\e[0m"
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
      --limit 100 \
      --format="value(textPayload)" | grep -Ei "ERROR|Exception|FATAL|Connection refused" || echo "No critical errors found in last 100 logs."
}

setup_method_a() {
    echo -e "\e[34m[METHOD A] Setting up GCloud Proxy...\e[0m"
    echo "Starting proxy on port $PROXY_PORT for $SERVICE_NAME..."
    
    # Start proxy in background
    gcloud run services proxy $SERVICE_NAME --region $REGION --port $PROXY_PORT &
    PROXY_PID=$!
    export PROXY_PID
    
    echo "Waiting for proxy to initialize (PID: $PROXY_PID)..."

    # Robust check: Wait up to 90 seconds for health endpoint
    for i in {1..90}; do
        if curl -s --max-time 2 "http://localhost:$PROXY_PORT/health/live" | grep -q "UP"; then
            echo -e "\e[32mSUCCESS: Proxy is active and Keycloak is healthy.\e[0m"
            return 0
        fi
        echo -n "."
        sleep 1
    done

    echo -e "\n\e[31mERROR: Proxy or Keycloak health check failed via proxy.\e[0m"
    fetch_logs
    return 1
}

cleanup_proxy() {
    if [[ -n "$PROXY_PID" ]]; then
        echo "Cleaning up GCloud Proxy (PID: $PROXY_PID)..."
        kill "$PROXY_PID" 2>/dev/null
    fi
}

setup_method_b() {
    echo -e "\e[34m[METHOD B] Setting up IAM-Authenticated Request...\e[0m"
    
    export GCP_TOKEN=$(gcloud auth print-identity-token)
    export SVC_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')
    
    echo "Service URL: $SVC_URL"
    echo "GCP_TOKEN successfully exported."
    
    echo "Running external health check via IAM token..."
    local HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $GCP_TOKEN" "$SVC_URL/health/live")
    
    if [[ "$HTTP_CODE" == "200" ]]; then
        echo -e "\e[32mSUCCESS: Direct IAM health check passed (HTTP $HTTP_CODE).\e[0m"
        return 0
    else
        echo -e "\e[31mERROR: Direct IAM health check failed (HTTP $HTTP_CODE).\e[0m"
        fetch_logs
        return 1
    fi
}

run_internal_validation() {
    echo "Running Internal API Validation (requires Proxy)..."
    
    local MAX_RETRIES=3
    local RETRY_COUNT=0
    local TKN="null"
    
    while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
        echo "Fetching Keycloak Admin Token (Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
        local RESPONSE=$(curl -s -X POST "http://localhost:$PROXY_PORT/realms/master/protocol/openid-connect/token" \
          -d "client_id=admin-cli" \
          -d "username=$ADMIN_USERNAME" \
          -d "password=$ADMIN_PASSWORD" \
          -d "grant_type=password")
        
        TKN=$(echo "$RESPONSE" | jq -r .access_token)
        
        if [[ "$TKN" != "null" && -n "$TKN" ]]; then
            break
        fi
        
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; then
            echo -e "\e[33mToken fetch failed. Retrying in 5 seconds (Likely DB Acquisition Timeout)...\e[0m"
            sleep 5
        fi
    done

    if [[ "$TKN" == "null" || -z "$TKN" ]]; then
        echo -e "\e[31mERROR: Keycloak Admin Token fetch failed after $MAX_RETRIES attempts.\e[0m"
        echo -e "\e[33mHINT: See TROUBLESHOOTING.md Scenario I (Symptom 3). If using db-f1-micro, the tier is underpowered for current load.\e[0m"
        fetch_logs
        return 1
    fi
    echo -e "\e[32mSUCCESS: Keycloak Admin Token retrieved.\e[0m"

    echo "Verifying Realm: $REALM"
    local REALM_CHECK=$(curl -s -H "Authorization: Bearer $TKN" "http://localhost:$PROXY_PORT/admin/realms/$REALM" | jq -r '.realm // "ERROR_NOT_FOUND"')
    if [[ "$REALM_CHECK" == "$REALM" ]]; then
        echo -e "\e[32mSUCCESS: Realm '$REALM' found.\e[0m"
    else
        echo -e "\e[31mERROR: Realm '$REALM' not found. Status: $REALM_CHECK\e[0m"
        fetch_logs
        return 1
    fi

    echo "Verifying Client PKCE Policy: $CLIENT_ID"
    local PKCE_CHECK=$(curl -s -H "Authorization: Bearer $TKN" "http://localhost:$PROXY_PORT/admin/realms/$REALM/clients?clientId=$CLIENT_ID" \
      | jq -r '.[0].attributes["pkce.code.challenge.method"] // "ERROR_MISSING"')
    if [[ "$PKCE_CHECK" == "S256" ]]; then
        echo -e "\e[32mSUCCESS: Client '$CLIENT_ID' has PKCE S256 enforced.\e[0m"
    else
        echo -e "\e[31mERROR: Client '$CLIENT_ID' PKCE policy mismatch. Found: '$PKCE_CHECK'.\e[0m"
        fetch_logs
        return 1
    fi
    
    echo -e "\e[32mVALIDATION COMPLETE.\e[0m"
    return 0
}

run_comprehensive_validation() {
    echo -e "\e[35m=== STARTING COMPREHENSIVE VALIDATION ===\e[0m"
    
    # Step 1: Run Method B (Infrastructure/IAM Layer)
    if setup_method_b; then
        echo -e "\n\e[35mMethod B Passed. Proceeding to Method A (Application Layer)...\e[0m"
        # Step 2: Run Method A + Internal Validation
        if setup_method_a; then
            run_internal_validation
        fi
    else
        echo -e "\e[31mCOMPREHENSIVE VALIDATION FAILED: Method B (External IAM) returned an error.\e[0m"
        return 1
    fi
}

main_menu() {
    echo "--- Keycloak Deployment Verification ---"
        echo "1. Full Validation via GCloud Proxy (Internal Keycloak Checks)"
        echo "2. External Health Check via IAM Token (Cloud Run Layer Check)"
        echo "3. Comprehensive Validation (Run both methods)"
    echo "4. Exit"
        echo "----------------------------------------"
        read -p "Choose an option: " choice

        case "$choice" in
            1)
            if check_infrastructure_health && setup_method_a; then
                run_internal_validation
            fi
                ;;
            2)
            if check_infrastructure_health; then
                setup_method_b
            fi
                ;;
            3)
            if check_infrastructure_health; then
                run_comprehensive_validation
                fi
                ;;
        4)
                echo "Exiting."
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
}

# Global trap to ensure proxy cleanup regardless of how script was called
trap cleanup_proxy EXIT
check_dependencies

# Execution Logic: Use arguments if provided, otherwise show menu
if [[ -z "$1" ]]; then
    main_menu
else
    case "$1" in
        method-a) setup_method_a ;;
        method-b) setup_method_b ;;
        validate) run_internal_validation ;;
        all) run_comprehensive_validation ;;
        *) echo "Usage: $0 {method-a|method-b|validate|all}" ;;
    esac
fi