#!/usr/bin/env bash

set -euo pipefail

echo "Searching for GEMMA directory..."

mapfile -t GEMMA_DIRS < <(find . -type d -name "GEMMA")

if [ ${#GEMMA_DIRS[@]} -eq 0 ]; then
    echo "ERROR: No GEMMA directory found."
    exit 1
fi

if [ ${#GEMMA_DIRS[@]} -gt 1 ]; then
    echo
    echo "Multiple GEMMA directories found:"
    echo

    for i in "${!GEMMA_DIRS[@]}"; do
        printf "[%d] %s\n" "$((i+1))" "${GEMMA_DIRS[$i]}"
    done

    echo
    read -rp "Select the GEMMA directory to use: " choice

    GEMMA_DIR="${GEMMA_DIRS[$((choice-1))]}"
else
    GEMMA_DIR="${GEMMA_DIRS[0]}"
fi

echo
echo "Using GEMMA directory:"
echo "$GEMMA_DIR"
echo

create_dir() {
    if [ -d "$1" ]; then
        echo "[EXISTS] Directory: $1"
    else
        mkdir -p "$1"
        echo "[CREATED] Directory: $1"
    fi
}

create_file() {
    if [ -f "$1" ]; then
        echo "[EXISTS] File: $1"
    else
        touch "$1"
        echo "[CREATED] File: $1"
    fi
}

#########################################
# Root files
#########################################

create_file "$GEMMA_DIR/bootstrap.md"
create_file "$GEMMA_DIR/repository-knowledge.md"
create_file "$GEMMA_DIR/evaluation.md"
create_file "$GEMMA_DIR/changelog.md"

#########################################
# Skills
#########################################

create_dir "$GEMMA_DIR/Skills"

create_file "$GEMMA_DIR/Skills/cloud-engineering-assistant.md"
create_file "$GEMMA_DIR/Skills/software-engineering-assistant.md"
create_file "$GEMMA_DIR/Skills/terraform-reviewer.md"
create_file "$GEMMA_DIR/Skills/kubernetes-reviewer.md"
create_file "$GEMMA_DIR/Skills/security-auditor.md"

#########################################
# Tests
#########################################

# Reuse existing TESTS directory if present
if [ -d "$GEMMA_DIR/TESTS" ]; then
    TEST_DIR="$GEMMA_DIR/TESTS"
elif [ -d "$GEMMA_DIR/Tests" ]; then
    TEST_DIR="$GEMMA_DIR/Tests"
else
    TEST_DIR="$GEMMA_DIR/TESTS"
    mkdir -p "$TEST_DIR"
    echo "[CREATED] Directory: $TEST_DIR"
fi

create_file "$TEST_DIR/01_repository_awareness.md"
create_file "$TEST_DIR/02_documentation_grounding.md"
create_file "$TEST_DIR/03_security.md"
create_file "$TEST_DIR/04_architecture.md"
create_file "$TEST_DIR/05_terraform.md"
create_file "$TEST_DIR/06_kubernetes.md"
create_file "$TEST_DIR/07_gitops.md"
create_file "$TEST_DIR/08_cloud_build.md"
create_file "$TEST_DIR/09_code_review.md"
create_file "$TEST_DIR/10_hallucination.md"
create_file "$TEST_DIR/scorecard.md"

#########################################
# Reports
#########################################

create_dir "$GEMMA_DIR/Reports"

create_file "$GEMMA_DIR/Reports/baseline.md"
create_file "$GEMMA_DIR/Reports/v0.2.md"
create_file "$GEMMA_DIR/Reports/v0.3.md"
create_file "$GEMMA_DIR/Reports/v0.4.md"
create_file "$GEMMA_DIR/Reports/v1.0.md"

#########################################
# Prompts
#########################################

create_dir "$GEMMA_DIR/Prompts"

for i in $(seq -w 1 10); do
    create_file "$GEMMA_DIR/Prompts/stage${i}.md"
done

#########################################
# Scripts
#########################################

create_dir "$GEMMA_DIR/Scripts"

create_file "$GEMMA_DIR/Scripts/repository_inventory.py"
create_file "$GEMMA_DIR/Scripts/build_context.py"
create_file "$GEMMA_DIR/Scripts/evaluate.py"
create_file "$GEMMA_DIR/Scripts/scorecard.py"
create_file "$GEMMA_DIR/Scripts/generate_report.py"

#########################################
# Pipelines
#########################################

create_dir "$GEMMA_DIR/Pipelines"

create_file "$GEMMA_DIR/Pipelines/bootstrap.sh"
create_file "$GEMMA_DIR/Pipelines/improve_gemma.sh"
create_file "$GEMMA_DIR/Pipelines/evaluate_gemma.sh"

chmod +x "$GEMMA_DIR/Pipelines/"*.sh 2>/dev/null || true

echo
echo "======================================="
echo "Gemma framework initialized successfully."
echo "======================================="
