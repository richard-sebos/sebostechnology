---
title: Setting Up a Secure ROS 2 System: Part 4 AppArmor and Auditd 
date: 2025-04-10 10:00:00 +0000
categories: [Robotics, ROS2 Install Series, Security]
tags: [ros2, robotics, cybersecurity, linux]
---

When it comes to securing your ROS 2 environment, tools like **AppArmor**, **SELinux**, and **Auditd** are often overlooked—but they’re incredibly powerful. Like traditional file permissions and firewalls, these Linux security modules help control and monitor which users and processes have access to specific resources. More than just a defense layer, they also provide detailed audit logs when access is attempted or denied, making them essential for robotics applications where software interfaces with the real world.

## Table of Contents
1. [Introduction to Linux Security Tools](#introduction-to-linux-security-tools)
2. [Understanding SELinux vs AppArmor](#understanding-selinux-vs-apparmor)
3. [Getting Started with Auditd](#getting-started-with-auditd)
4. [How AppArmor, SELinux, and Auditd Work Together](#how-apparmor-selinux-and-auditd-work-together)
5. [Setting Up AppArmor and Auditd on Ubuntu for ROS 2](#setting-up-apparmor-and-auditd-on-ubuntu-for-ros-2)
    - [Enable and Start AppArmor](#1-enable-and-start-apparmor)
    - [Create Placeholder ROS 2 AppArmor Profile](#2-create-placeholder-ros-2-apparmor-profile)
    - [Define Auditd Rules for ROS 2 Components](#3-define-auditd-rules-for-ros-2-components)
    - [Apply Auditd Rules and Enable Logging](#4-apply-auditd-rules-and-enable-logging)
6. [What’s Next?](#whats-next)

---

## Understanding SELinux vs AppArmor

Both **SELinux** and **AppArmor** are implementations of **Mandatory Access Control (MAC)**—a security framework built directly into the Linux kernel. This gives them a low-level ability to enforce strict policies and limit system access, reducing the risk of compromise.

- **SELinux** is commonly used in **Red Hat-based distributions** like CentOS and Fedora.
- **AppArmor** is more often found on **Debian-based systems**, including **Ubuntu**—which is where ROS 2 is frequently installed.

Typically, systems run either SELinux or AppArmor, not both. For ROS 2 on Ubuntu, we'll focus on AppArmor.

## Getting Started with Auditd

**Auditd** is the Linux auditing daemon. It collects logs related to system activity, including access events from SELinux and AppArmor. You can use these logs to build or refine security policies—tightening access to only what’s necessary for your robot's functionality.

With Auditd, you can track execution of binaries, changes to configuration files, and access attempts—critical information when developing in **secure robotics** or **industrial control systems (ICS)** environments.

## How AppArmor, SELinux, and Auditd Work Together

The workflow typically looks like this:
- Start with **AppArmor** (or SELinux) in **permissive** mode to log but not block activity.
- Use **Auditd** to monitor system events and understand what your robot software actually needs.
- Based on this data, create or adjust security policies.
- Once confident, switch to **enforcing mode** to actively block unauthorized actions.

This iterative approach ensures security policies are accurate without disrupting development.

---

## Setting Up AppArmor and Auditd on Ubuntu for ROS 2

Since ROS 2 is usually deployed on Ubuntu, we’ll walk through enabling **AppArmor** and **Auditd** in this context. This setup lays the foundation for secure ROS 2 development and gives visibility into how your software interacts with the system.

### 1. Enable and Start AppArmor
```bash
systemctl enable apparmor
systemctl start apparmor
```
This enables AppArmor to start on boot and begins enforcing any existing profiles.

---

### 2. Create Placeholder ROS 2 AppArmor Profile
```bash
mkdir -p /etc/apparmor.d/ros2/
echo "# Placeholder ROS2 AppArmor profile" > /etc/apparmor.d/ros2/ros2-default
```
While this profile doesn’t enforce anything yet, it sets the stage for adding real rules as development progresses.

---

### 3. Define Auditd Rules for ROS 2 Components
```bash
cat <<EOF > /etc/audit/rules.d/ros2.rules
-w /opt/ros -p x -k ros_exec
-w /home/$ROS_USER/ros2_ws -p x -k ros_ws_exec
-w /home/$ROS_USER/ros2_ws/src -p wa -k ros_src
-w /etc/ros2 -p wa -k ros_conf
-w /usr/bin/colcon -p x -k colcon_exec
-w /usr/bin/rosdep -p x -k rosdep_exec
-w /home/$ROS_USER/.bashrc -p wa -k ros_env
EOF
```

These rules log:
- **Executions** of binaries like ROS, `colcon`, and `rosdep`
- **Changes** to source files, configs, and shell environment

Use `$ROS_USER` as your development user or replace it directly.

---

### 4. Apply Auditd Rules and Enable Logging
```bash
augenrules --load
systemctl enable auditd
systemctl start auditd
```
This applies your audit rules and ensures Auditd starts automatically.

---

## What’s Next?

At this point, you have:
- A fresh Ubuntu installation with ROS 2
- A dedicated ROS user and the environment
- Auditd and AppArmor installed and configured


Next up in the series, we’ll explore how to configure **firewall rules** to further protect your robot’s communication channels and surface interfaces.

If you have questions, suggestions, or topics you’d love to see covered, drop a comment below. Let’s make robotics not just exciting and innovative—but secure as well.
