
# 🛡️ Strengthening ROS2 Robotic Security with AppArmor: From Passive to Enforce Mode

*Published on: May 15, 2025*
*Categories: \[Robotics, ROS2 Install Series, Security]*
*Tags: \[ros2, robotics, cybersecurity, linux, apparmor]*

---

## 📚 **Table of Contents**

1. [Introduction](#introduction)
2. [What Is AppArmor?](#what-is-apparmor)
3. [AppArmor Profiles: Complain vs Enforce Modes](#apparmor-profiles-complain-vs-enforce-modes)
4. [Use Case: Blocking Access to ROS2 Code for Testers](#use-case-blocking-access-to-ros2-code-for-testers)
5. [Implementing and Testing AppArmor in Passive Mode](#implementing-and-testing-apparmor-in-passive-mode)
6. [Transitioning to Enforce Mode](#transitioning-to-enforce-mode)
7. [Reviewing AppArmor Logs and Policy Adjustments](#reviewing-apparmor-logs-and-policy-adjustments)
8. [Conclusion](#conclusion)

---

## 📖 **Introduction**

Following our deep dive into system monitoring with **Auditd**, it's time to take the next logical step—actively enforcing security policies using **AppArmor**.

While Auditd provides invaluable insights by logging actions, AppArmor lets us define and enforce precise security boundaries for applications and users. In this guide, we’ll walk through a real-world example: restricting a **tester group** from accessing sensitive ROS2 project code, starting in **Complain (Passive) Mode** and gradually moving to **Enforce Mode** after validation.

---

## 🔍 **What Is AppArmor?**

**AppArmor** is a Linux security module that confines applications and processes by enforcing access control policies. Unlike traditional permission systems, AppArmor policies work at the application level, specifying exactly what files, capabilities, and resources an application—or user group—can access.

### 📌 **Key Features of AppArmor:**

* Application-specific security profiles.
* Two operational modes: **Complain (Passive)** and **Enforce**.
* Logs violations without blocking in Complain mode—ideal for policy tuning.
* Enforces strict access controls in Enforce mode.
* Integrates smoothly with systemd services and user-level restrictions.

---

## ⚖️ **AppArmor Profiles: Complain vs Enforce Modes**

| Mode     | Purpose              | Behavior                                         |
| -------- | -------------------- | ------------------------------------------------ |
| Complain | Testing/Passive Mode | Logs violations but doesn’t block actions.       |
| Enforce  | Production Mode      | Blocks unauthorized actions based on the policy. |

Best practice is to start in **Complain Mode** to monitor and fine-tune your policies without impacting normal operations. Once confident that the policy won’t interfere with legitimate activities, you can safely switch to **Enforce Mode**.

---

## 🧑‍💻 **Use Case: Blocking Access to ROS2 Code for Testers**

In this scenario, we have a user group called `tester_group` involved in system testing. While they need to interact with deployed applications, they **should not have direct access to the ROS2 codebase** located at `/home/rosbot/ros_wd/`.

We’ll create an AppArmor policy to restrict this access, starting in Complain Mode for observation.

---

## 🚀 **Implementing and Testing AppArmor in Passive Mode**

### 📄 **Step 1: Create the AppArmor Profile**

We’ll create a new profile named `ros_code_block` to prevent read/write access to the code directory for `tester_group`.

```bash
sudo aa-genprof /bin/bash
```

During the profiling session:

1. Simulate access attempts as a `tester_group` member.
2. AppArmor will log these events for policy generation.

Or, create a manual profile:

```bash
sudo tee /etc/apparmor.d/ros_code_block <<EOF
#include <tunables/global>

/bin/bash {
    # Allow everything except the ROS2 code directory
    /home/rosbot/ros_wd/ r,
    /home/rosbot/ros_wd/** r,
    deny /home/rosbot/ros_wd/** rwklx,

    # Allow other necessary operations
    /bin/** rmix,
    /usr/** rmix,
    /lib/** rmix,
    /dev/** rw,
    /tmp/** rw,
}
EOF
```

### 📄 **Step 2: Set Profile to Complain Mode**

```bash
sudo apparmor_parser -r /etc/apparmor.d/ros_code_block
sudo aa-complain /etc/apparmor.d/ros_code_block
```

AppArmor will now log any denied actions without blocking them, allowing the testers to continue their work uninterrupted while you analyze the logs.

---

## 📊 **Transitioning to Enforce Mode**

After monitoring for a few days or weeks:

1. Review logs in `/var/log/syslog` or via `dmesg | grep DENIED`.
2. Adjust the profile if legitimate activities are being flagged.
3. Confident the policy is correct? Switch to Enforce Mode:

```bash
sudo aa-enforce /etc/apparmor.d/ros_code_block
```

From this point forward, access attempts by `tester_group` to the ROS2 code directory will be **actively blocked**.

---

## 📂 **Reviewing AppArmor Logs and Policy Adjustments**

### 📌 **Common Log Review Commands:**

```bash
# View recent AppArmor violations
dmesg | grep "apparmor="

# Filter by profile name
grep "ros_code_block" /var/log/syslog
```

If you see legitimate operations being blocked, update the profile accordingly:

```bash
sudo aa-logprof
```

This interactive tool will guide you through resolving policy conflicts.

---

## ✅ **Conclusion**

By combining **Auditd** for monitoring and **AppArmor** for enforcement, you establish a powerful, layered security approach for your ROS2 robotic projects.

Starting in **Complain Mode** allows teams to observe and refine security policies without disrupting development or testing. And when it’s time to lock things down, switching to **Enforce Mode** provides solid protection against unauthorized access—whether accidental or malicious.

Remember, security is a process, not a one-time event. Stay vigilant, review logs regularly, and adjust policies as your projects evolve.

---

Would you like me to prepare the social media snippets for this article as well?
