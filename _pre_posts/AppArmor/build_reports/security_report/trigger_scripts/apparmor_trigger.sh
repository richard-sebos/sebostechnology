#!/bin/bash

echo "[+] [AppArmor] Attempting to trigger AppArmor denials..."

# Try to read /etc/shadow using a restricted profile (replace with actual enforced profile)
if aa-status | grep -q "colcon"; then
    sudo aa-exec -p /usr/bin/colcon -- /bin/cat /etc/shadow
else
    echo "[WARN] AppArmor profile for colcon not enforced. Skipping denial test."
fi

echo "[+] [AppArmor] Attempting to trigger denials..."

# Try to read sensitive files via bash (should be denied)
sudo aa-exec -p /usr/bin/bash -- /bin/cat /etc/shadow
sudo aa-exec -p /usr/bin/bash -- /bin/cat /etc/passwd

echo "[+] [AppArmor] Completed denial trigger test."

echo "[+] [AppArmor] Completed triggers."
