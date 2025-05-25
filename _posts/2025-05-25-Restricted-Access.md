---
title: 🔐 Restricting SSH Access with a Limited User Account
date: 2025-05-25 12:11 +0000
description: "Secure your Linux systems by using a restricted user for SSH access and separating admin privileges. Learn how to configure rbash, limit executable commands, and enhance server security with this practical guide for sysadmins."
image: /assets/img/Restricted-Access.png
categories: [Linux Security, SSH Hardening, System Administration, Server Security, User Management]
tags: [SSH security, restricted SSH user, rbash Linux, secure SSH login, Linux sysadmin tips, SSH hardening practices, limiting SSH access, two-account SSH model, secure Linux configuration, SSH restricted shell]

---

Securing SSH access is one of the most important steps a Linux administrator can take to harden a system. SSH is used daily by sysadmins, but if not configured carefully, it can expose powerful admin accounts to unnecessary risk—especially when used from remote laptops or devices that might be lost or compromised.

In this article, we explore a simple but powerful concept: **using a restricted user for SSH logins** and switching to your administrative account only after establishing a secure connection. This practice adds another layer of protection to your systems and can help reduce your attack surface significantly.

---

## 📚 Table of Contents

1. [Why Use Two User Accounts for SSH?](#why-use-two-user-accounts-for-ssh)
2. [Setting Up a Restricted User with rbash](#setting-up-a-restricted-user-with-rbash)
3. [Restricting Executable Commands](#restricting-executable-commands)
4. [Is This Overkill or Just Smart Security?](#is-this-overkill-or-just-smart-security)
5. [Final Thoughts](#final-thoughts)

---

## 🧑‍💻 Why Use Two User Accounts for SSH?

I recently started configuring my Linux systems with **two separate user accounts**:

* A restricted account named `richard`
* An admin account named `admin_richard`

The `richard` account is limited to its home directory and a minimal set of commands. It can log in via SSH, but **has no admin privileges**. On the other hand, `admin_richard` has full sudo rights—but is explicitly **blocked from logging in over SSH**.

This model protects the administrative account from direct remote access and makes it much harder for an attacker to gain privileged access, even if an SSH key or laptop is compromised.

Let’s walk through how to set it up.

---

## 🛡️ Setting Up a Restricted User with rbash

Many Linux distributions include `rbash` (restricted Bash), which limits what a user can do with their shell.

### Step 1: Check for `rbash`

```bash
which rbash
```

If it’s not available, create a symlink to Bash:

```bash
which bash     # typically /usr/bin/bash
sudo ln -s /usr/bin/bash /usr/bin/rbash
```

Even though it points to the same binary, Linux enforces restricted behavior when invoked as `rbash`.

### Step 2: Set `rbash` as the User Shell

```bash
sudo usermod -s /usr/bin/rbash richard
```

Now, when `richard` logs in, their shell will be restricted. They won’t be able to change directories out of their home, use `cd`, set environment variables, or execute arbitrary commands.

---

## 🧰 Restricting Executable Commands

Next, let’s limit which commands `richard` can use by creating a custom `bin` directory.

### Step 1: Create and Lock Down a Custom Command Directory

```bash
sudo mkdir /home/richard/.bin
sudo chown root:root /home/richard/.bin
```

This ensures `richard` can’t add new commands.

### Step 2: Symlink Only Safe Commands

```bash
sudo ln -s /bin/ls /home/richard/.bin/ls
sudo ln -s /bin/su /home/richard/.bin/su
sudo ln -s /bin/clear /home/richard/.bin/clear
```

These links expose only the commands you choose.

### Step 3: Set a Safe PATH and File Permissions

Edit `.bashrc`:

```bash
sudo nano /home/richard/.bashrc
```

Add:

```bash
export PATH=$HOME/.bin
umask 077
```

Then lock down the file:

```bash
sudo chown root:richard /home/richard/.bashrc
```

This setup ensures that even if someone uploads a malicious file via SCP, it won’t be executable—and `richard` won’t have access to anything outside `.bin`.

---

## 🤔 Is This Overkill or Just Smart Security?

Security often feels like overkill—until it’s not.

By creating this restricted user workflow, you’re building another layer of defense. Combined with tools like **SSH key authentication**, **Fail2Ban**, and **2FA**, this approach:

* Limits exposure of your admin account
* Slows down attackers
* Encourages better compartmentalization of privileges

Cybersecurity isn’t about one perfect solution—it’s about stacking defenses so that even if one layer is breached, others remain intact.

---

## ✅ Final Thoughts

Setting up a restricted SSH user may feel like extra work up front, but it pays dividends in security. You minimize the risk of exposing your admin credentials and give yourself time to respond in the event of a breach attempt.

In the next article, I’ll show how to **block admin users from logging in via SSH altogether**, making your privileged accounts even safer.

---
**Need Linux expertise?** I help businesses streamline servers, secure infrastructure, and automate workflows. Whether you're troubleshooting, optimizing, or building from scratch—I've got you covered.  
📬 Drop a comment or [email me](mailto:info@sebostechnology.com) to collaborate. For more tutorials, tools, and insights, visit [sebostechnology.com](https://sebostechnology.com).
