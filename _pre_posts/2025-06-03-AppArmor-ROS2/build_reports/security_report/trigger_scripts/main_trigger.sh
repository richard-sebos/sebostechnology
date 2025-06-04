#!/bin/bash

echo "[*] Starting Modular Security Event Triggers..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/auditd_trigger.sh"
bash "$SCRIPT_DIR/suricata_trigger.sh"
bash "$SCRIPT_DIR/apparmor_trigger.sh"

echo "[✓] All triggers completed. You can now run the report."
