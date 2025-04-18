---
title: 🛡️ Setting Up a Secure ROS 2 System Part 1 – Updating Ubuntu and Creating a ROS User
date:  2025-04-09 13:06 +0000
categories: [Robotics, ROS2 Install Series, Security]
tags: [ros2, robotics, cybersecurity, linux]
---


## Introduction

Welcome to the first post in my series on setting up a secure ROS 2 system on Ubuntu. In this part, we're going to lay the groundwork by updating the operating system and setting up a dedicated user for ROS 2. These initial steps might seem routine, but they're crucial for building a system that’s stable, maintainable, and secure.

## Table of Contents
1. [Introduction](#introduction)
2. [Modular Bash Script for Setup](#modular-bash-script-for-setup)
3. [Making the Script Re-Runnable](#making-the-script-re-runnable)
4. [Setting the Timezone, Updating Ubuntu, and Creating the ROS User](#setting-the-timezone-updating-ubuntu-and-creating-the-ros-user)
5. [Next Steps](#next-steps)
6. [SEO Keywords](#seo-keywords)

---

To make the process repeatable and reliable, I’m using a modular Bash script. Throughout this series, I’ll be adding functionality to this script so that by the end, you’ll be able to start from a fresh Ubuntu install and fully configure your ROS 2 system with automation and security best practices baked in.

Let’s dive in and start crafting the setup script.

---

## Modular Bash Script for Setup

To keep things organized, I’ve broken the script into logical modules. This makes it easier to maintain, debug, and extend. At the core, there's a `common.sh` script where shared variables and functions live. Here's an overview of what's included:

```bash
#!/bin/bash

# Shared configuration and utility functions

TIMEZONE="UTC"                           # System timezone
ROS_DISTRO="jazzy"                       # ROS 2 distribution
ROS_USER="rosbot"                        # Local ROS user
ROS_WS="/home/$ROS_USER/ros2_ws"        # Development workspace

# ROS repository and key
ROS_KEY_URL="https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc"
ROS_REPO_URL="http://packages.ros.org/ros2/ubuntu"

# IPs of other ROS nodes in the system
ROS_NODE_IPS=("192.168.1.10" "192.168.1.11")
```

This file will be sourced by each module, ensuring all scripts have access to shared settings and configuration values.

---

## Making the Script Re-Runnable

One important design goal is that the script should be safe to re-run. Whether you're tweaking things during development or reinstalling on a new version of Ubuntu, being able to resume where you left off is essential.

Each task in the script is wrapped in a `run_step` function, which checks whether that step has already completed. If it has, it skips it. If not, it runs and logs the result.

```bash
STATE_FILE="/var/log/ros2_setup_state"

log_step() { echo "$1" >> "$STATE_FILE"; }

has_run() { grep -q "$1" "$STATE_FILE" 2>/dev/null; }

abort_on_failure() { echo "[-] ERROR: $1"; exit 1; }

run_step() {
    local STEP_NAME="$1"
    shift
    if ! has_run "$STEP_NAME"; then
        echo "[*] Running: $STEP_NAME..."
        "$@" || abort_on_failure "$STEP_NAME failed"
        log_step "$STEP_NAME"
    else
        echo "[✓] Skipping: $STEP_NAME (already completed)"
    fi
}
```

This approach ensures robustness and resilience as you build out more complex setups.

---

## Setting the Timezone, Updating Ubuntu, and Creating the ROS User

The first actual setup script we'll use is `system_setup.sh`. This assumes you're starting from a clean Ubuntu install and performs the following:

- Sets the system timezone
- Updates and upgrades all system packages
- Installs commonly needed software tools
- Creates a dedicated user for running ROS 2

Here’s the relevant snippet:

```bash
#!/bin/bash

source ./common.sh

timezone_and_update() {
    timedatectl set-timezone "$TIMEZONE"
    apt update
    apt full-upgrade -y
    apt install -y curl gnupg2 lsb-release software-properties-common ufw apparmor apparmor-utils auditd vim nano
}
```

And for setting up the user:

```bash
create_ros_user() {
    id -u "$ROS_USER" &>/dev/null || (
        adduser --disabled-password --gecos '' "$ROS_USER"
        usermod -aG sudo "$ROS_USER"
    )
}
```

With these two functions, we begin the process of hardening the base system and preparing a clean, controlled environment for running ROS 2.

While these steps might seem a bit mundane, they are foundational. A secure system is built in layers, and that starts with good hygiene: consistent configuration, up-to-date software, and properly scoped user permissions.

---

## Next Steps

In the next post, we’ll continue building the script to install ROS 2 itself, configure the environment, and begin applying security tools such as firewalls and intrusion detection systems.

Security doesn’t come from one magic tool — it’s a layered approach that begins at the OS level. With the base system updated and a dedicated user in place, we’re ready to move on to more exciting territory.

Stay tuned!
