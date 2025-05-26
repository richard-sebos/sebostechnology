#!/bin/bash

ROS_USER="rosbot"
ROS_HOME="/home/$ROS_USER/ros2_ws"

echo "[+] [Auditd] Triggering auditd rules..."

# Ensure workspace directories exist
sudo -u "$ROS_USER" mkdir -p "$ROS_HOME/src"

# Execute monitored binaries
sudo -u "$ROS_USER" /usr/bin/colcon --help > /dev/null 2>&1
sudo -u "$ROS_USER" /usr/bin/rosdep --help > /dev/null 2>&1

# Trigger file modifications
sudo -u "$ROS_USER" touch "$ROS_HOME/src/test_trigger.cpp"
sudo mkdir -p /etc/ros2
sudo touch /etc/ros2/test_config.yaml
sudo -u "$ROS_USER" echo "export TEST_VAR=1" >> "/home/$ROS_USER/.bashrc"

echo "[+] [Auditd] Completed triggers."
