---
title: 🛡️ Blocking Admin SSH Logins with SELinux (`ssh_sysadm_login`)
date: 2025-06-01 12:11 +0000
description: "In this guide, you’ll learn how to use SELinux to block direct SSH access for privileged users, enforcing access through a restricted jump account instead. By disabling the ssh_sysadm_login boolean and mapping users to the sysadm_u role, you gain a policy-enforced control point that hardens your system against misconfiguration, privilege abuse, and lateral movement.

Because true security doesn’t just start at the login prompt—it controls who gets there in the first place."
image: /assets/img/SSH-SELinx.png
categories: [Linux Security, SSH Hardening, System Administration, Server Security, User Management]
tags: [SSH security, restricted SSH user, rbash Linux, secure SSH login, Linux sysadmin tips, SSH hardening practices, limiting SSH access, two-account SSH model, secure Linux configuration, SSH restricted shell]
---

Preventing direct administrative SSH access is a vital component of any defense-in-depth strategy. In this guide, we’ll explore how to restrict privileged users from logging in via SSH using SELinux’s `ssh_sysadm_login` boolean. This ensures that administrative access is only available **after** connecting through a restricted, non-privileged jump account — a critical safeguard against misconfiguration and privilege abuse.

---

## 📚 Table of Contents

1. [Overview: Why Restrict Admin SSH Access](#overview-why-restrict-admin-ssh-access)
2. [Step 1: Ensure SELinux is in Enforcing Mode](#step-1-ensure-selinux-is-in-enforcing-mode)
3. [Step 2: Associate Admin Users with `sysadm_u`](#step-2-associate-admin-users-with-sysadm_u)
4. [Step 3: Disable `ssh_sysadm_login`](#step-3-disable-ssh_sysadm_login)
5. [Why Not Just Use `sshd_config`](#why-not-just-use-sshd_config)
6. [Final Thoughts & Additional Hardening Tips](#final-thoughts--additional-hardening-tips)

---

## 🧭 Overview: Why Restrict Admin SSH Access

In [Part 1 of this series](https://richard-sebos.github.io/sebostechnology/posts/Restricted-Access/), we set up a **restricted jump user** — a non-privileged account used to SSH into a Linux server. This user can then escalate privileges locally (e.g., using `su`) but **cannot SSH directly as root or another admin**.

In this part, we take the next step: **blocking direct SSH logins for admin-level users** using SELinux. Specifically, we’ll manipulate the `ssh_sysadm_login` boolean to enforce this restriction.

This method provides a powerful control point that can’t be bypassed by misconfigured SSH settings alone.

> **New to SELinux?** Learn the basics in our [SELinux Primer](https://richard-sebos.github.io/sebostechnology/posts/SELinux-Basics/)

---

## 🔍 Step 1: Ensure SELinux is in Enforcing Mode

To apply SELinux policies, your system must be running in `enforcing` mode:

```bash
getenforce
# Output should be: Enforcing

sestatus
# Look for:
# SELinux status:                 enabled
# Current mode:                  enforcing
# Loaded policy name:            targeted
```

If SELinux is not enforcing, enable it temporarily:

```bash
sudo setenforce 1
```

Install required SELinux tools:

```bash
sudo dnf install -y policycoreutils selinux-policy-targeted policycoreutils-python-utils
```

These packages are essential for managing SELinux users and applying policy contexts — especially the `sysadm_u` context used in the next step.

---

## 👥 Step 2: Associate Admin Users with `sysadm_u`

To restrict specific users via SELinux, you must assign them to the SELinux user `sysadm_u`. This context is tied to elevated privilege policies — and SELinux uses it to gate SSH access when `ssh_sysadm_login` is disabled.

Example:

```bash
sudo semanage login -a -s sysadm_u rchamberlain
```

> Replace `rchamberlain` with the actual username of your administrative user.

You can confirm the mapping with:

```bash
semanage login -l | grep sysadm_u
```

---

## 🔒 Step 3: Disable `ssh_sysadm_login`

The SELinux boolean `ssh_sysadm_login` determines whether users mapped to `sysadm_u` are allowed to SSH into the system.

To disable this access:

```bash
sudo setsebool -P ssh_sysadm_login off
```

Verify the change:

```bash
getsebool ssh_sysadm_login
# Output: ssh_sysadm_login --> off
```

At this point, any users associated with `sysadm_u` are **fully blocked from SSH login** — regardless of their group membership or presence in `sshd_config`.

---

## 🧱 Why Not Just Use `sshd_config`?

The SSH configuration file (`/etc/ssh/sshd_config`) allows administrators to permit or deny login access for specific users or groups.

While useful, this method alone is **highly susceptible to misconfiguration**:

* Admin users might be unintentionally included in allowed groups.
* Changes to group memberships might reintroduce access inadvertently.
* There's no enforcement context beyond simple group/user rules.

By contrast, the SELinux-based approach:

✅ Adds a **mandatory access control** layer
✅ Functions independently of SSH group settings
✅ Prevents privilege escalation through SSH, even if SSH settings are misconfigured

> For best results, use both approaches together — but never rely solely on `sshd_config` for critical access restrictions.

---

## 🛡️ Final Thoughts & Additional Hardening Tips

Using SELinux to disable `ssh_sysadm_login` is a powerful, low-level hardening strategy that:

* Forces administrative access to go through controlled entry points
* Reduces the attack surface of privileged accounts
* Prevents SSH misuse due to config drift or accidental group changes

For a more secure Linux SSH workflow, combine this method with:

* 🔐 **SSH Key Authentication**
* 🚫 **Fail2Ban for brute force protection**
* 🔐 **Two-Factor Authentication (2FA)**
* 📜 **Audit logging and centralized monitoring**

---

**Need Linux expertise?** I help businesses streamline servers, secure infrastructure, and automate workflows. Whether you're troubleshooting, optimizing, or building from scratch—I've got you covered.  

📬 Drop a comment or [email me](mailto:info@sebostechnology.com) to collaborate. For more tutorials, tools, and insights, visit [sebostechnology.com](https://sebostechnology.com).