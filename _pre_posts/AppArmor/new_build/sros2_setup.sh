#!/bin/bash

source ./common.sh

sros2_setup() {
    echo "[*] Installing openssl if needed..."
    apt install -y openssl || abort_on_failure "openssl install failed"

    echo "[*] Preparing SROS2 keystore and schema validation..."

    # Place schema in ROS user's workspace, not /opt (avoids permission issues)
    SCHEMA_FILE="$ROS_WS/sros2_keystore/dds_security_permissions.xsd"
    SCHEMA_URL="https://www.omg.org/spec/DDS-Security/20170901/dds_security_permissions.xsd"

    # Download the schema if not present
    if [[ ! -f "$SCHEMA_FILE" ]]; then
        echo "[*] Downloading DDS Security schema to $SCHEMA_FILE..."
        sudo -u "$ROS_USER" bash -c "mkdir -p \"$(dirname "$SCHEMA_FILE")\" && wget '$SCHEMA_URL' -O '$SCHEMA_FILE'" \
            || abort_on_failure "Failed to download DDS Security schema to $SCHEMA_FILE"
        echo "[+] Schema downloaded successfully."
    fi

    sudo -u "$ROS_USER" env ROS_DISTRO="$ROS_DISTRO" ROS_WS="$ROS_WS" SCHEMA_FILE="$SCHEMA_FILE" bash -c '
        set -euo pipefail

        # Temporarily relax unset var check for sourcing ROS setup
        set +u
        source "/opt/ros/${ROS_DISTRO}/setup.bash"
        set -u

        KEYSTORE="${ROS_WS}/sros2_keystore"
        mkdir -p "$KEYSTORE/permissions"
        cd "$KEYSTORE"

        echo "[*] Creating keystore and enclave for /talker..."
        ros2 security create_keystore .
        ros2 security create_enclave . /talker

        # Write compliant XML policy
cat <<EOF > permissions/talker.xml
<?xml version="1.0" encoding="UTF-8" ?>
<permissions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:noNamespaceSchemaLocation="file://$SCHEMA_FILE">
  <grant name="talker_grant" subject_name="CN=/talker">
    <validity>
      <not_before>2024-01-01T00:00:00</not_before>
      <not_after>2026-01-01T00:00:00</not_after>
    </validity>
    <allow>
      <domains>
        <id>0</id>
      </domains>
      <publish>
        <topic>*</topic>
      </publish>
      <subscribe>
        <topic>*</topic>
      </subscribe>
      <partition>
        <name>*</name>
      </partition>
    </allow>
  </grant>
</permissions>
EOF

        echo "[*] Generating permission file for /talker..."
        ros2 security create_permission . /talker permissions/talker.xml
        echo "[+] SROS2 /talker enclave and permissions created successfully."
    '
}
