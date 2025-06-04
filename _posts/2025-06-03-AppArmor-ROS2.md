---
title: 🔐 AppArmor and ROS2 – The Article I Tried Not to Write
date: 2025-06-03 12:11 +0000
description: "Discover why AppArmor may not be ideal for ROS2 development with colcon. Learn from real-world insights comparing AppArmor, SELinux, and Oracle Linux in robotics system security."
image: /assets/img/Apparmor-ROS2.png
categories: [Robotics, ROS2 Install Series, Security,Robotics Security,Linux System Hardening, ROS2 Development, Cybersecurity Best Practices, Open-Source Security Tools, Industrial IoT Security, DevSecOps for Robotics]
tags: [ROS2 Security, Auditd Linux, Robotics Cybersecurity, Secure ROS Communications,Linux Auditing Tools, ROS2 Hardening, AppArmor and Auditd, Network Monitoring in Robotics, Robot Security Frameworks, SROS2 Configuration, ROS2 Development Security, Linux System Monitoring, ROS2 Build Security, Suricata IDS, Auditd Rules Examples, ROS2,]
---

## Introduction

When I began my ROS2 integration project, AppArmor wasn't even on my radar. My background included years of experience with RHEL and Oracle Linux, and I had developed a solid understanding of SELinux. Initially, I attempted to make ROS2 work on Oracle Linux, expecting a straightforward integration. However, after several days of troubleshooting and configuration tweaks, I was still encountering persistent issues.

Next, I shifted my focus to using SELinux on Ubuntu. Unfortunately, this too presented complications that weren't worth resolving at the time. Although both SELinux and Oracle Linux theoretically support ROS2, the practical reality was too time-consuming to justify. On the other hand, I knew that AppArmor was the default MAC (Mandatory Access Control) system on Ubuntu and had proven compatibility with ROS2. That’s when I decided to explore AppArmor more deeply.

---
## Table of Contents

1. [Introduction](#introduction)
2. [Mandatory Access Control in Linux](#mandatory-access-control-in-linux)
3. [Why AppArmor Didn't Work for My Use Case](#why-apparmor-didnt-work-for-my-use-case)
4. [Is AppArmor the Wrong Tool for ROS2 and `colcon`?](#is-apparmor-the-wrong-tool-for-ros2-and-colcon)
5. [Would I Still Use AppArmor?](#would-i-still-use-apparmor)
6. [Conclusion and Next Steps](#conclusion-and-next-steps)
---

## Mandatory Access Control in Linux

Linux supports multiple types of access control mechanisms, such as:

* **DAC (Discretionary Access Control)**: The traditional file permission system based on user and group ownership.
* **ACL (Access Control Lists)**: More fine-grained controls layered on top of DAC.
* **MAC (Mandatory Access Control)**: A system-enforced security layer that restricts program capabilities beyond user-level permissions.

[Learn more about DAC, ACL, and MAC](https://richard-sebos.github.io/sebostechnology/posts/DAC-ACL-MAC/)

Both **AppArmor** and **SELinux** fall under the MAC category but operate in fundamentally different ways. AppArmor is path-based and easier to configure, making it attractive for developers who want a quicker security solution. It works by defining what specific programs can do with files and directories, thereby extending the traditional DAC model to provide stricter access policies.

---

## Why AppArmor Didn't Work for My Use Case

A prime example of AppArmor's limitations came up with the `colcon` command, which is essential for building ROS2 packages. From a security standpoint, I only wanted `colcon` to have access during controlled build and deployment phases, such as during UAT or production deployments.

In theory, blocking `colcon` from accessing certain directories should have prevented execution. However, the reality was more complex. `colcon` launched a Python subprocess that failed due to denied permissions, yet some parts of the `colcon` process still executed. This partial execution created a domino effect, requiring a growing list of subprocesses and tools to be explicitly added to the AppArmor policy—a time-consuming and error-prone effort.

---

## Is AppArmor the Wrong Tool for ROS2 and `colcon`?

In many cases, AppArmor works exactly as designed—but not necessarily as expected. Its job is not to prevent a program from running entirely, but to restrict what it can access once it's running. As a result, a program like `colcon` can still execute and must handle permission errors internally. AppArmor applies these rules system-wide, across all users.

In the context of ROS2 development tools like `colcon`, AppArmor simply isn't granular or dynamic enough to offer the kind of control required during various development and deployment stages. For this reason, I would not recommend using AppArmor as the primary access control mechanism for ROS2 build tools.

---

## Would I Still Use AppArmor?

Yes, I would still use AppArmor—just not for development tools like `colcon`. I put AppArmor in the same category as **UFW (Uncomplicated Firewall)**: easy to use, effective in specific contexts, and suitable when paired with other security layers.

However, in the case of robotics systems, where the device and its controller must directly interact with hardware and have minimal external layers, these limitations become more noticeable. At this juncture, I’m exploring whether it's more viable to get **Oracle Linux** working with **ROS2** or to invest time in enabling **SELinux** and **Firewalld** on **Ubuntu**.

---

## Conclusion and Next Steps

While AppArmor provides a convenient and reliable form of MAC for many use cases, it's not the ideal fit for every scenario—especially those involving complex, multi-stage build tools like `colcon`. Its compatibility with Ubuntu and simplicity make it a solid default, but its limitations become clear in advanced ROS2 development environments.

Moving forward, I’m evaluating whether continuing with Oracle Linux and ROS2 integration is worth the investment, or if I should double down on Ubuntu and invest in hardening it with SELinux and Firewalld. Your feedback and suggestions on this are welcome.

> Learn more about [SELinux here](#) *(link to be updated)*

---
*Looking to learn more about ROS2 security, SROS2 node permissions, or robotic system hardening? Bookmark this [series](https://dev.to/sebos/secure-ros2-setup-hardening-your-robot-project-from-the-start-448a) and follow along as we secure each layer of our Linux-based robotic system.*
---
**Need Linux expertise?** I help businesses streamline servers, secure infrastructure, and automate workflows. Whether you're troubleshooting, optimizing, or building from scratch—I've got you covered.  

📬 Drop a comment or [email me](mailto:info@sebostechnology.com) to collaborate. For more tutorials, tools, and insights, visit [sebostechnology.com](https://sebostechnology.com).