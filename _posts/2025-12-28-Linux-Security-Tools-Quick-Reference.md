---
title: "Linux Security Tools Quick Reference"
subtitle: Brief descriptions of security tools mentioned in Linux for Business - Exploring Enterprise Security
date: 2025-12-28 09:00 +0000
categories: [Linux, Security]
tags: [DAC, ACL, MAC, SELinux, AppArmor, Auditd, Ansible, SambaAD, CUPS, Reference]
---

> **Companion Guide:** Quick reference for tools mentioned in [Linux for Business - Exploring Enterprise Security at Small Business Scale](#).

---

## Access Control Mechanisms

**DAC (Discretionary Access Control)**
Traditional Unix file permissions using owner, group, and others with read, write, and execute permissions. Managed with `chmod`, `chown`, and `chgrp`.

**ACL (Access Control Lists)**
Extended permissions that allow granting access to specific users and groups beyond the basic owner/group/others model. Managed with `setfacl` and `getfacl`.

**MAC (Mandatory Access Control)**
System-wide security policies enforced at the kernel level that cannot be overridden by users, even root. Implemented by SELinux or AppArmor.

---

## Mandatory Access Control Systems

**SELinux (Security-Enhanced Linux)**
MAC system that uses security contexts (labels) on files and processes to enforce policies. Used on RHEL, CentOS, Fedora, and Rocky Linux.

**AppArmor**
MAC system that uses path-based profiles to confine programs. Simpler than SELinux, used on Debian, Ubuntu, and SUSE distributions.

---

## Authentication and Directory Services

**Samba Active Directory**
Linux-based Active Directory Domain Controller providing centralized user authentication, LDAP directory services, Kerberos SSO, and Group Policy support for Windows and Linux clients.

---

## Monitoring and Auditing

**Auditd (Linux Audit Daemon)**
Kernel-level auditing framework that tracks security events including file access, system calls, user actions, and configuration changes. Required for compliance monitoring.

**journalctl**
Query tool for systemd's journal that provides centralized log management for all services, applications, and the kernel with powerful filtering and search capabilities.

---

## Infrastructure Services

**CUPS (Common UNIX Printing System)**
Centralized print server providing network-accessible print queues, driverless printing with IPP Everywhere, and web-based administration on port 631.

**SSH (Secure Shell)**
Encrypted remote access protocol for secure system administration, file transfers, and port forwarding. Uses public key authentication for enhanced security.

**Ansible**
Agentless automation platform using SSH to deploy configurations and manage systems at scale through YAML playbooks and infrastructure-as-code.

---

## How They Work Together
* **Authentication:** Samba AD provides centralized user management and single sign-on
* **Authorization:** DAC and ACL control file access permissions
* **Protection:** MAC (SELinux/AppArmor) enforces mandatory security policies
* **Monitoring:** Auditd tracks security events, journalctl centralizes logs
* **Infrastructure:** CUPS manages printing, SSH enables remote access
* **Automation:** Ansible deploys and maintains consistent security configurations

---

## Defense-in-Depth Layers

1. **Authentication** - Samba AD (who are you?)
2. **Authorization** - DAC/ACL (what can you access?)
3. **Confinement** - MAC/SELinux (what can processes do?)
4. **Monitoring** - Auditd/journalctl (what happened?)
5. **Network** - Firewall/SSH (how do you connect?)
6. **Management** - Ansible (consistent configuration)

---

**For detailed information, see:** [Linux Security Tools Reference Guide](#)

---
