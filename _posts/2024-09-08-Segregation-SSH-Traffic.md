---
title: Mastering SSH Traffic Segregation - Enhance Security and Performance 
date: 2024-09-08 20:48 +0000
categories: [ssh, cybersecurity]
tags: [ssh traffic, segregation, cybersecurity] 
image: 
  path: /assets/img/SSH-Segregation.png
  alt: "Mastering SSH Traffic"
---

In today’s fast-paced, automation-driven environments, **SSH traffic** is the backbone of countless administrative and deployment tasks. From powerful tools like **Ansible**, **rsync**, and **Terraform** to container platforms like **Docker**, these services generate a significant amount of SSH traffic.

If this traffic isn’t properly managed, it can lead to security blind spots, noisy logs, and operational inefficiencies. That’s why **segregating SSH traffic by service and user type** is a simple yet highly effective way to improve both security and performance.

In this guide, you’ll learn how to:

* Separate SSH traffic using different ports.
* Apply advanced SSH configuration with the `Match` directive.
* Optimize firewall rules and logs for easier management.
* Improve Ansible automation performance with connection tuning.

---

## 📚 **Why Segregate SSH Traffic?**

Segregating SSH traffic allows you to:

* **Implement tighter access controls.**
* **Streamline firewall configurations.**
* **Enhance monitoring and log analysis.**
* **Improve automation tool performance.**

For example, you may want regular user traffic on **port 22** while directing automation tools like **Ansible** through **port 2222**. This way, you can apply different security settings and logging levels to each traffic type without conflict.

---

## 🔧 **Using the SSH Match Statement**

The `Match` directive in `sshd_config` allows you to apply specific configurations based on conditions such as:

* `Match User` – Match specific SSH users.
* `Match Group` – Apply settings based on user groups.
* `Match Address` – Filter by client IP address.
* `Match Host` – Filter by hostname.
* `Match LocalPort` – Apply settings based on the SSH port.
* `Match RemoteAddress` – Filter based on the client’s IP.
* `Match RemotePort` – Filter based on the client’s connection port.

In our scenario, we’ll use `Match LocalPort` to separate traffic across ports **22** and **2222**.

---

## 🗂️ **Organizing SSH Configuration Files**

To make management easier, we’ll split the SSH configuration into separate files:

1. **Main `sshd_config`** – Common global settings.
2. **User Traffic Config (`55-ssh-user.conf`)** – Rules for human users.
3. **Ansible Traffic Config (`51-ansible_admin.conf`)** – Optimized for Ansible and automation tools.

This modular approach helps you maintain clean and targeted configurations without cluttering a single config file.

---

## 🚀 **Optimizing Ansible Traffic on Port 2222**

Ansible traffic typically generates many SSH sessions during playbook execution. You can improve both security and performance by:

* Restricting access to specific users and IP addresses.
* Setting **LogLevel** to `ERROR` to reduce log noise.
* Lowering `ClientAliveInterval` for faster detection of dropped sessions.
* Increasing `MaxSessions` to allow more parallel SSH connections.

### ➤ **Example: `51-ansible_admin.conf`**

```ssh
Match LocalPort 2222
    AllowUsers ansible_admin@192.168.167.17
    DenyGroups ssh-users
    ClientAliveInterval 60
    ClientAliveCountMax 3
    LogLevel ERROR
    MaxSessions 10
```

---

## 👤 **Managing User Traffic on Port 22**

For regular user SSH sessions, security and detailed logging take priority:

* Restrict SSH access to the `ssh-users` group.
* Increase `ClientAliveInterval` to reduce keep-alive traffic.
* Enable **INFO-level logging** for better activity tracking.
* Limit concurrent sessions to prevent resource abuse.

### ➤ **Example: `55-ssh-user.conf`**

```ssh
Match LocalPort 22
    AllowGroups ssh-users
    ClientAliveInterval 300
    ClientAliveCountMax 0
    LogLevel INFO
    MaxSessions 10
```

---

## 📄 **Main SSH Configuration: `sshd_config`**

```ssh
# Strong SSH Key Algorithms
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512,hmac-sha2-256

PubkeyAcceptedKeyTypes ssh-rsa-cert-v01@openssh.com,ssh-ed25519
Protocol 2

# Listening on Multiple Ports
Port 22
Port 2222

PermitRootLogin no
AuthorizedKeysFile /home/%u/.ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
GSSAPIAuthentication no
ChallengeResponseAuthentication no

MaxAuthTries 3
LoginGraceTime 30s

AllowAgentForwarding no
PermitTunnel no
X11Forwarding no

# Include Custom Configurations
Include /etc/ssh/sshd_config.d/51-ansible_admin.conf
Include /etc/ssh/sshd_config.d/55-ssh-user.conf
```

---

## 📈 **Benefits of SSH Traffic Segregation**

* ✅ Simplifies **firewall rule management**.
* ✅ Helps **reduce log clutter** by customizing log levels.
* ✅ Improves **security** with tailored access controls.
* ✅ Enhances **Ansible performance** through optimized SSH parameters.
* ✅ Makes **troubleshooting easier** by filtering logs based on port usage.

---

## 📖 **FAQ: SSH Traffic Segregation**

**Q1: Is changing the SSH port enough to improve security?**
While changing the port isn’t a complete security measure, it reduces automated bot attacks and, when combined with proper controls, strengthens your SSH defense.

**Q2: Can I apply similar segregation for other tools?**
Yes! This method works for any tool using SSH, including rsync, Git over SSH, and custom scripts.

**Q3: Does this affect my existing Ansible playbooks?**
No. You simply need to update the Ansible inventory to specify the new port using `ansible_port=2222`.

---

## 📢 **Final Thoughts**

Segregating SSH traffic is a low-cost, high-reward strategy that makes managing a secure and high-performance environment easier. Whether you’re optimizing for automation tools like Ansible or ensuring detailed logging for user activities, this approach gives you granular control over how SSH connections are handled.

---

🛡️ **New to SSH Security? Start Here!**
Kick off your SSH hardening journey with [Your First Steps to a Hardened SSH Server](https://dev.to/sebos/your-first-step-to-a-hardened-ssh-server-49mj).

**Need Linux expertise?** I help businesses streamline servers, secure infrastructure, and automate workflows. Whether you're troubleshooting, optimizing, or building from scratch—I've got you covered.  
📬 Drop a comment or [email me](mailto:info@sebostechnology.com) to collaborate. For more tutorials, tools, and insights, visit [sebostechnology.com](https://sebostechnology.com).

---

☕ **Did you find this article helpful?**  
Consider supporting more content like this by buying me a coffee:  
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow)](https://www.buymeacoffee.com/sebostechnology)  
Your support helps me write more Linux tips, tutorials, and deep dives.

[https://www.buymeacoffee.com/sebostechnology](https://www.buymeacoffee.com/sebostechnology)
