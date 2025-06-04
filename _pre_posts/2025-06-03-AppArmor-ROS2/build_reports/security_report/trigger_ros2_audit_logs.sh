#!/bin/bash

# Define environment
ROS_USER="${ROS_USER:-rosbot}"
ROS_HOME="/home/$ROS_USER/ros2_ws"
AUDIT_KEYS=("ros_exec" "ros_ws_exec" "ros_src" "ros_conf" "colcon_exec" "rosdep_exec" "ros_env")

echo "[+] Triggering auditd rules..."

# Trigger file execution & access
echo "[+] Executing /usr/bin/colcon"
sudo -u "$ROS_USER" /usr/bin/colcon --help > /dev/null 2>&1

echo "[+] Executing /usr/bin/rosdep"
sudo -u "$ROS_USER" /usr/bin/rosdep --help > /dev/null 2>&1

echo "[+] Touching monitored config and source directories"
sudo -u "$ROS_USER" touch "$ROS_HOME/trigger_file.cpp"
sudo -u "$ROS_USER" echo "# Updated" >> "$ROS_HOME/src/trigger_readme.md"
sudo -u "$ROS_USER" echo "export ROS_VERSION_TEST=1" >> "/home/$ROS_USER/.bashrc"
sudo -u "$ROS_USER" mkdir -p /etc/ros2 && touch /etc/ros2/test_config.yaml
# Trigger events associated with the audit keys

# Trigger ros_exec
sudo -u "$ROS_USER" /bin/ls /opt/ros
sudo -u "$ROS_USER" /bin/ls /home/rosbot/ros2_ws
sudo -u "$ROS_USER" touch /home/rosbot/ros2_ws/src/test_trigger.cpp
sudo -u "$ROS_USER" touch /etc/ros2/test_config.yaml
sudo -u "$ROS_USER" /usr/bin/colcon --help
sudo -u "$ROS_USER" /usr/bin/rosdep --help
sudo -u "$ROS_USER" echo "export TEST_VAR=1" >> /home/rosbot/.bashrc


# Force some delays for timestamps to differ
sleep 1

# Trigger Suricata: Send UDP traffic to DDS port and ICMP
echo "[+] Triggering Suricata rules..."

TARGET_IP="127.0.0.1"

echo "[+] Sending UDP to DDS port (7400)"
echo "ROS2 DDS Test" | nc -w1 -u $TARGET_IP 7400

echo "[+] Sending ICMP ping"
ping -c 1 $TARGET_IP > /dev/null

echo "[✓] Log trigger complete. Check audit logs and Suricata alerts."
# ---------------------------
# Verification Section
# ---------------------------

echo ""
echo "[+] Verifying auditd logs for monitored keys..."

for key in "${AUDIT_KEYS[@]}"; do
    echo ""
    echo "=== [Auditd Records for Key: $key] ==="
    ausearch -k "$key" --format text | tail -n 10
done

echo ""
echo "[+] Summary Report:"
aureport --summary

echo ""
echo "[+] Checking recent Suricata alerts..."
grep -E 'DDS|ICMP' /var/log/suricata/eve.json | tail -n 10

echo ""
echo "[+] [Optional] Check AppArmor (if profiles are enforced):"
dmesg | grep DENIED | tail -n 10

echo ""
echo "[✓] Trigger and verification complete."
