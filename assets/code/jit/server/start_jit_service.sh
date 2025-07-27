#!/bin/bash

set -e

# Define project root
PROJECT_DIR="/usr/local/jit-ssh"
VENV_DIR="$PROJECT_DIR/venv"
LOG_FILE="$PROJECT_DIR/jit_service.log"
SERVICE_DIR="$PROJECT_DIR/bin"

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Switch to project directory so FastAPI can find jit_service.py
cd "$SERVICE_DIR"

# Start the FastAPI service using uvicorn
exec uvicorn jit_service:app --host 127.0.0.1 --port 8088 >> "$LOG_FILE" 2>&1

