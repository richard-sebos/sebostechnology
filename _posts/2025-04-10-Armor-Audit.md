---
title: Securing ROS 2 with AppArmor and Auditd 
date: 2025-04-10 10:00:00 +0000
categories: [Robotics, ROS2 Install Series, Security]
tags: [ros2, robotics, cybersecurity, linux]
---
# AppArmor and Auditd

- Three Linux security softwares that don't get talk about enough are SELinux, AppArmor and Auditd.
- Like file permission and firewalls, they can  are there to keep unwanted users and processes from access resources.
- They can also report when this access is attenpted
- These allow you to create security policies that can be customized to you robots needs.
- Remember, you robot will be interacting with the real world and you will want to protect is software from it

## SELinux and AppArmor
- SELinux and AppArmor are Mandatory Access Control (MAC) security application.
- The access control is built into kernel giving great access and less chance to be bypass
- RHEL base distro normally have SELinux and  AppArmor is normally assocated with Debian and SuSe based system
- Normally you would have either SELinux or AppArmor running but not both.
- But what to do with it hand how to create policies

## Audit 
- Auditd collects security-relevant events include from SELinux and Auditd
- It also allow you to search/report on events that are happening on the system
- From a secure stand point, you would use these events to create SELinux or AppArmor to restrict or allow access to resources.

## How do they work together
- Normally you would setup SELinux or AppArmor in a very restrictive policies
- You would have them either in Enforce (stopping and report access) or Permissive (reporting only) state.
- As users are interaction with the server's reources, you would monutor the auditd records and add, change or remove security policies as needed.

## Starting AppArmor and Auditd
- Since ROS2 nornally installing on an Ubuntu system, the script for this part will work with AppArmor and Audit
- Below parts of the script lays the groundwork for:
    - **MAC enforcement** via AppArmor (though it needs real profiles to be effective).
    - **Auditing** access to ROS 2 files, code, config, and binaries.
    - Ideal for use in **secure robotics or ICS environments** where **accountability and control** are key.
---

### 🔐 1. **Enable and Start AppArmor**
```bash
systemctl enable apparmor
systemctl start apparmor
```
- **AppArmor** is a Linux kernel security module for **mandatory access control**.
- This ensures AppArmor is **enabled on boot** and starts **immediately**, enforcing any profiles that exist.

---

### 📁 2. **Create a Directory and Placeholder Profile for ROS 2**
```bash
mkdir -p /etc/apparmor.d/ros2/
echo "# Placeholder ROS2 AppArmor profile" > /etc/apparmor.d/ros2/ros2-default
```
- Prepares the system for a **custom AppArmor profile** for ROS 2.
- Right now, it’s just a placeholder (`ros2-default`)—doesn’t enforce anything yet, but sets up the structure for future enforcement.

---

### 🕵️ 3. **Configure Auditd Rules for ROS 2 Components**
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

These rules tell **auditd** to:
- **Log execution attempts** (`-p x`) for:
  - ROS binaries (`/opt/ros`)
  - Workspace build system (`colcon`)
  - Dependency tool (`rosdep`)
- **Watch for changes** (`-p wa`) in:
  - Source code (`ros2_ws/src`)
  - Configuration files (`/etc/ros2`)
  - User environment setup (`.bashrc`)

Each rule is tagged with a **key (`-k`)** for easy filtering in audit logs.

> `$ROS_USER` should be an exported environment variable or replaced with an actual username before use.

---

### 🔄 4. **Apply Audit Rules and Start Auditd**
```bash
augenrules --load
systemctl enable auditd
systemctl start auditd
```
- `augenrules --load` compiles and applies the new rules.
- `auditd` is enabled to start at boot and immediately starts collecting logs.

---
- At this point, we have a 
    - freshly installed Ubuntu
    - Update it and added a ROS2 user
    - Installed ROS2 and setup the ROS2 enviroment
    - Setup AppArmor and Audiitd to receive new policies and rules as the robot application is built.

- next we will be create firewall rules to protect the robot.



