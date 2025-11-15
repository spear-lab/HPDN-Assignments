#!/bin/bash

RYU_DIR="$HOME/sdn/ryu"
VENV_DIR="$RYU_DIR/ryu3.9"

echo "[*] Starting Ryu controller..."

# Ensure Ryu directory exists
if [ ! -d "$RYU_DIR" ]; then
    echo "[ERROR] Ryu directory not found: $RYU_DIR"
    exit 1
fi

# Activate venv
if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo "[ERROR] Ryu venv missing: $VENV_DIR"
    exit 1
fi

source "$VENV_DIR/bin/activate"

# Correct Ryu module name
RYU_APP="ryu.app.simple_switch_13"
PORT=6633

echo "[*] Using Ryu app: $RYU_APP"
echo "[*] Listening on port: $PORT"

ryu-manager "$RYU_APP" --ofp-tcp-listen-port "$PORT" --verbose
