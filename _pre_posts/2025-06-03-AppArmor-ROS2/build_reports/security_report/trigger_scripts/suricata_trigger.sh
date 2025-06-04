#!/bin/bash

TARGET_IP="127.0.0.1"
echo "[+] [Suricata] Sending test DDS UDP traffic..."
echo "Test ROS2 Traffic" | nc -w1 -u $TARGET_IP 7400

echo "[+] [Suricata] Sending ICMP ping..."
ping -c 1 $TARGET_IP > /dev/null

echo "[+] [Suricata] Completed triggers."
