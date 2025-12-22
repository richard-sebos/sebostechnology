---
title: Samba AD – Technical Considerations and Common Questions
subtitle: Answers to practical deployment questions about SSH access, password policies, and domain integration
date: 2025-12-21 09:30 +0000
categories: [Linux, Enterprise]
tags: [SambaAD, ActiveDirectory, SSH, PasswordPolicy, PAM, SSSD, LinuxSecurity, DomainIntegration]
image:
---

This document provides answers to common technical questions and caveats when working with a Samba Active Directory (AD) environment. Whether you're integrating Linux systems, managing domain policies, or securing user access, this guide addresses real-world concerns that come up during deployment and administration.

---

## 🔐 Can Active Directory be used to restrict SSH access for Linux servers?

Not directly through AD alone. To restrict SSH access based on AD users or groups, you must configure the SSH daemon on each Linux server (usually in `/etc/ssh/sshd_config`) using directives like:

```bash
AllowGroups SSHAccess
```

If your server is properly joined to the domain using `sssd` or `winbind`, these group names can reference AD groups. AD defines the identity and group structure, but **access control enforcement still happens at the system level**, ideally via configuration management (e.g., Ansible, Puppet, or SaltStack).

---

## 🔑 Do SSH key-based logins still work with AD users?

Yes, **but they require extra setup**. AD users do not natively store SSH keys in the domain. You can still use public key authentication, but you’ll need to:

* Manually manage `~/.ssh/authorized_keys` for each AD user on each server, **or**
* Use LDAP attributes with `sssd` to store SSH keys centrally (requires schema extension), **or**
* Distribute keys via configuration management tools

Public key authentication works just as it does for local users, provided that the user's home directory and SSH configuration are in place and accessible.

---

## 🧑‍💻 Does `su -l` work with AD users?

Yes, assuming the following conditions:

* The system is successfully joined to the Samba AD domain
* The AD user account exists and is permitted to log in
* The shell (e.g., `/bin/bash`) is defined in the AD attributes or overridden locally
* PAM is correctly configured for domain authentication

However, because AD users are not local, `su -l` requires a **valid domain password** or an active **Kerberos ticket**. This works the same way as with local users, but relies on domain credentials.

---

## 🔄 Does Samba AD override local Linux password policies?

Yes, **domain-level password policies override local PAM settings** in most domain-joined configurations.

This includes:

* Password length and complexity
* Password expiration
* Account lockout after failed attempts

Domain-wide settings are typically managed using:

```bash
samba-tool domain passwordsettings set --min-pwd-length=12 --complexity=on
```

Local PAM modules (e.g., `pam_pwquality`) may be bypassed unless specifically configured to work with `sssd` and LDAP. Centralization ensures consistency but reduces host-level flexibility unless otherwise designed.

---

## 📁 Can shared folders "follow" users across devices (like roaming profiles)?

Not automatically, but this behavior can be configured:

### For Windows Clients

* Samba supports **home shares** and **roaming profiles**
* Requires enabling and mapping `\\server\homes` or `\\server\profiles` via AD attributes or logon scripts

### For Linux Clients

* No native roaming profiles
* You can simulate this by:

  * **Automounting SMB or NFS shares** based on login
  * Using LDAP attributes like `homeDirectory`
  * Automating with tools like `autofs`, `sssd`, or configuration management tools

This approach allows users to access the same home directory or workspace regardless of which domain-joined machine they log into.

---

## 🧰 Summary

| Topic                  | Samba AD Behavior                                   |
| ---------------------- | --------------------------------------------------- |
| **SSH Access Control** | Enforced via local SSH config referencing AD groups |
| **SSH Key Auth**       | Requires manual or automated key setup              |
| **`su -l` Support**    | Works with valid credentials and proper PAM         |
| **Password Policy**    | Enforced by AD; overrides local settings            |
| **Shared Folders**     | Can be automounted or mapped; not automatic         |


