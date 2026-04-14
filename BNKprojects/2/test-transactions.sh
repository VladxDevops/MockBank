#!/bin/bash

# Altmtrk2026 Bank - Transaction Service Automated Testing Script
# This script automates verification of the Transaction Journey and MongoDB Audit logging.

if [[ ! -f "./test-env.sh" ]]; then
    echo -e "\e[31mERROR: Configuration file 'test-env.sh' not found.\e[0m"
    exit 1
fi

source ./test-env.sh

check_transaction_flow() {
    echo -e "\e[34m[TEST] Validating Transaction Orchestration (Amount Threshold)...\e[0m"
    
    # Test Case 1: Standard Transaction (< 10,000)
    echo "Testing standard transaction ($500)..."
    local RESP_A=$(curl -s -X POST "$SVC_URL/transfer" -H "Content-Type: application/json" -d '{"amount": 500, "user_id": "test_user"}')
    if echo "$RESP_A" | grep -q "approved"; then
        echo -e "\e[32mSUCCESS: Standard transaction approved.\e[0m"
    else
        echo -e "\e[31mFAILURE: Standard transaction failed.\e[0m"
    fi

    # Test Case 2: Step-Up Auth Transaction (>= 10,000)
    echo "Testing step-up authentication ($15,000)..."
    local RESP_B=$(curl -s -X POST "$SVC_URL/transfer" -H "Content-Type: application/json" -d '{"amount": 15000, "user_id": "test_user"}')
    if echo "$RESP_B" | grep -q "step_up_required"; then
        echo -e "\e[32mSUCCESS: Step-up authentication triggered correctly.\e[0m"
    else
        echo -e "\e[31mFAILURE: Step-up authentication logic failed.\e[0m"
    fi
}

verify_mongodb_audit() {
    echo -e "\e[34m[TEST] Verifying MongoDB Audit Logs...\e[0m"
    # Logic to query MongoDB Atlas for the latest journey_id
    echo "Audit verification logic pending MongoDB connection string configuration."
}

echo "--- Transaction Service Verification ---"
check_transaction_flow
verify_mongodb_audit
