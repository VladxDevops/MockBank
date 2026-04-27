#!/bin/bash
# Automates the setup of the Python virtual environment and launches the Identity Service.

set -e

PROJECT_DIR="/home/pochitawork/InterviewCloud Projects/Altmtrk2026/Bank/BNKprojects/1"

echo "Entering project directory..."
cd "$PROJECT_DIR"

if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found!"
    echo "Please run 'cp .env.example .env' and configure your variables before starting."
    exit 1
fi

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

echo "Ensuring pip-tools is installed..."
pip install --quiet pip-tools

echo "Synchronizing dependencies with requirements.txt..."
pip-sync requirements.txt

echo "Starting the application..."
python src/app.py