# 🛡️ Securing ROS2 Robotic Projects with Auditd: A Practical Guide

*Published on: April 9, 2025*
*Categories: \[Robotics, ROS2 Install Series, Security]*
*Tags: \[ros2, robotics, cybersecurity, linux]*

In our ongoing journey to secure ROS2-based robotic projects, we’ve already implemented several foundational security measures. We started with a fresh installation, configured SROS2 for secure ROS communications, enabled AppArmor and Auditd, set up a firewall, and deployed Suricata for network monitoring.

While AppArmor, Auditd, and Suricata all help define rules and profiles to protect and monitor a system, this article focuses on diving deeper into **Auditd**—a powerful auditing framework that doesn’t just monitor but provides invaluable insights into system activities.

## 📚 **Table of Contents**

1. [Introduction](#introduction)
2. [What Is Auditd?](#what-is-auditd)
3. [Why Use Auditd in Robotics Projects?](#why-use-auditd-in-robotics-projects)
4. [Auditd and Robots: Real-World Use Cases](#auditd-and-robots-real-world-use-cases)
5. [How Auditd Works: Practical Examples](#how-auditd-works-practical-examples)
6. [Monitoring ROS2 Code and Development Environments](#monitoring-ros2-code-and-development-environments)
7. [Reviewing Audit Logs Efficiently](#reviewing-audit-logs-efficiently)
8. [Conclusion](#conclusion)


---

## 🔍 **What Is Auditd?**

`auditd` is a **Linux security auditing daemon** that monitors and records critical system events, including user activities, process executions, file system accesses, and some network-related actions.

> ⚠️ **Important:** Auditd **does not prevent events**—it records and reports them for later review.

In a robotics context, where systems comprise various interconnected devices—from cameras and sensors to motor controllers—it’s challenging to define strict access controls without disrupting functionality. Auditd helps bridge this gap by providing detailed reports on interactions across device boundaries, allowing teams to make informed security decisions.

### 📌 **Key Capabilities of Auditd:**

* Monitors **file system actions** (read, write, execute, attribute changes).
* Tracks **user activities** (logins, privilege escalations, command executions).
* Captures **process actions** (process creation, exec calls).
* Observes **network-related system calls** (e.g., `connect()`, `bind()`), but is **not** a network traffic analysis tool like Suricata.
* Maintains detailed logs in `/var/log/audit/audit.log`.
* Integrates with `ausearch`, `aureport`, and `auditctl` for efficient analysis and rule management.

---

## 🤖 **Why Use Auditd in Robotics Projects?**

Security debates often center around two approaches:

* **Deny Access:** Safer but may hinder development and business operations.
* **Monitor and Audit:** Allows freedom during development but requires vigilance.

Auditd strikes a balance by enabling passive monitoring during development. Rules can be created to monitor who and what accesses sensitive areas. Then, as the project moves into production, these passive rules can transition into enforced policies using tools like AppArmor, SELinux, or Suricata.

This approach is particularly useful for robotics, where interconnected devices and unpredictable interactions make strict deny policies impractical during early stages.

---

## 🤖 **Auditd and Robots: Real-World Use Cases**

In robotics, multiple subsystems interact seamlessly—cameras send data to AI processors, controllers issue motor commands, and various sensors provide environmental feedback. But how do you ensure those communications are legitimate?

Did a wheel control signal originate from the robot’s controller or a compromised driver?

By integrating `auditd` during the development phase, you can monitor process events and establish behavioral baselines. These baselines help you define acceptable interactions, which can later be enforced to block anything outside of expected behavior.

---

## ⚙️ **How Auditd Works: Practical Examples**

Let’s create a simple `auditd` rule to monitor when `colcon`, the ROS2 build tool, is executed.

```bash
-w /usr/bin/colcon -p x -k colcon_exec
```

### 📖 **Rule Breakdown**

| Parameter        | Meaning                                                                |
| ---------------- | ---------------------------------------------------------------------- |
| `-w`             | Watch the specified file or directory (`/usr/bin/colcon`).             |
| `-p x`           | Monitor **execute** permissions (triggers when the file is run).       |
| `-k colcon_exec` | Assigns the log entry a custom key `colcon_exec` for easier searching. |

---

## 📝 **Monitoring ROS2 Code and Development Environments**

Auditd can also help secure your codebase. Here’s how you can monitor attempts to access ROS2 project files by unauthorized users:

```bash
##########################################################
# 🚀 ROS Environment and Security Audit Rules for Auditd #
##########################################################

# -----------------------------------------------------------------------------
# 🔹 Monitor execution of critical ROS-related commands to detect build and 
#    dependency management activity.
# -----------------------------------------------------------------------------
-w /usr/bin/colcon       -p x   -k colcon_exec      # Watch execution of 'colcon' (ROS workspace build tool)
-w /usr/bin/rosdep       -p x   -k rosdep_exec      # Watch execution of 'rosdep' (ROS dependency manager)

# -----------------------------------------------------------------------------
# 🔹 Monitor changes and execution within the main ROS installation and 
#    system-wide ROS configuration directories.
# -----------------------------------------------------------------------------
-w /opt/ros               -p x    -k ros_exec       # Detect execution of binaries/scripts from the core ROS installation
-w /etc/ros2              -p wa   -k ros_conf       # Monitor changes (write/attribute) to ROS2 configuration files

# -----------------------------------------------------------------------------
# 🔹 Monitor changes to the user environment configuration, specifically for 
#    modifications that may alter ROS environment variables.
# -----------------------------------------------------------------------------
-w /home/rosbot/.bashrc   -p wa   -k ros_env        # Monitor user '.bashrc' for changes that might affect environment variables

# -----------------------------------------------------------------------------
# 🔹 Monitor ROS workspace activities to detect execution of workspace scripts 
#    and modifications to source code before builds.
# -----------------------------------------------------------------------------
-w /home/rosbot/ros2_ws        -p x    -k ros_ws_exec  # Detect execution of scripts/binaries in the workspace root
-w /home/rosbot/ros2_ws/src    -p wa   -k ros_src      # Monitor changes to source code files (write/attribute changes)

##########################################################
# ✅ End of Audit Rules
##########################################################

```

> 🛡️ **Note:** Auditd doesn’t block actions—it logs them for your review.

---

## 📂 **Reviewing Audit Logs Efficiently**

To quickly search audit logs for specific keys:

```bash
ausearch -k ros_code_access -k colcon_exec
```

For a cleaner, more organized report, use the following script:

### 📄 **Script: `audit_report.sh`**

*(See [full script here](#))*

This script loops through `auditd keys`  and formats them for easy reading. It’s a great tool for ongoing monitoring or post-incident reviews.

#### 📌 **Usage Examples:**

* **Group by Audit Key:**

  ```bash
  ./audit_colcon_tracker.sh
  ```

It will create a file `/var/log/audit_ros_events.csv`
```log
"2025-05-17 12:08:53","richard"," "/usr/bin/python3" "/usr/bin/colcon" "--help"",colcon_exec
"2025-05-17 12:08:53","richard"," "/usr/bin/python3" "/usr/bin/rosdep" "--help"",rosdep_exec
"2025-05-17 12:08:53","richard"," "/bin/bash" "/opt/ros/trigger.sh"",ros_exec
"2025-05-17 12:08:53","richard"," "/bin/bash" "/home/rosbot/ros2_ws/trigger_ws.sh"",ros_ws_exe
```

This script can be run manually or scheduled via `systemd` or `cron` for regular reporting.

---

## ✅ **Conclusion**

In complex systems like robotics, security isn’t just about locking things down—it’s about understanding how your systems behave and identifying unusual activity before it becomes a problem.

By integrating Auditd into your ROS2 robotic projects early in the development lifecycle, you empower your teams to gather critical security insights without disrupting innovation. And while this article focused on robotics, the same principles and scripts apply seamlessly to general Linux environments and applications.

