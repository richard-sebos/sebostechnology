---
title: Samba AD User & Group Management Guide
subtitle: Complete walkthrough for creating users, groups, OUs, and access policies in Samba Active Directory
date: 2025-12-21 09:00 +0000
categories: [Linux, Enterprise]
tags: [SambaAD, ActiveDirectory, UserManagement, GroupPolicy, LDAP, DomainJoin, AccessControl, EnterpriseLinux]
---

This guide walks through the creation and management of users, groups, organizational units (OUs), and access control policies in a Samba Active Directory (AD) environment. It's designed for IT teams supporting projects with both in-office and remote developers who require secure, centralized access to Linux servers, shared folders, and development resources.

---

## 🗺️ Forest Structure: Organizational Design

The example below shows how to logically structure a Samba AD forest for a Python development project. We separate users by **location**, group them by **function**, and define access through **security groups**.

```plaintext
DC=example,DC=local
└── OU=PythonProject
    ├── OU=Local
    │   ├── User: jsmith
    │   └── User: klee
    ├── OU=Remote
    │   ├── User: jdoe
    │   └── User: amir
    └── Groups
        ├── PythonDevs
        ├── SSHAccess
        ├── Share_DevDocs
        └── Admins_PythonProject
```

---

## 🏗️ 1. Create Organizational Units

Organizational Units (OUs) help separate user scopes by location or function:

```bash
# Top-level OU for the project
samba-tool ou create "OU=PythonProject,DC=example,DC=local"

# Sub-OUs for location-based separation
samba-tool ou create "OU=Local,OU=PythonProject,DC=example,DC=local"
samba-tool ou create "OU=Remote,OU=PythonProject,DC=example,DC=local"
```

---

## 👥 2. Create Groups for Access Control

Define groups to manage permissions and roles.

```bash
# Project-wide group
samba-tool group add PythonDevs

# Access-specific groups
samba-tool group add SSHAccess
samba-tool group add Share_DevDocs
samba-tool group add Admins_PythonProject
```

---

## 👤 3. Add Users and Assign Group Memberships

Create users and assign them to appropriate OUs and groups.

```bash
# Create a remote developer
samba-tool user create jdoe "S3cr3tPass!" --given-name=John --surname=Doe \
    --userou="OU=Remote,OU=PythonProject"

# Assign to groups
samba-tool group addmembers PythonDevs jdoe
samba-tool group addmembers SSHAccess jdoe
samba-tool group addmembers Share_DevDocs jdoe
```

Repeat for each user as needed.

---

## 📁 4. Shared Folder Access (Samba Shares)

On a file server (can be separate from the DC), configure shared folders based on AD groups.

```ini
# /etc/samba/smb.conf
[DevDocs]
   path = /srv/samba/DevDocs
   read only = no
   valid users = @Share_DevDocs
```

```bash
# Set folder permissions
mkdir -p /srv/samba/DevDocs
chown root:Share_DevDocs /srv/samba/DevDocs
chmod 2770 /srv/samba/DevDocs
```

---

## 🔐 5. Enforce Login Restrictions (e.g., SSH Access)

Control who can access servers remotely:

```bash
# /etc/ssh/sshd_config
AllowGroups SSHAccess
```

---

## 🛡️ 6. Security Policies via AD

Samba supports many domain-level policies:

* Password complexity
* Account lockout
* Expiration settings

These are configured with:

```bash
samba-tool domain passwordsettings set --min-pwd-length=12 --complexity=on
```

For more complex GPOs, use Windows RSAT tools.

---

## 🔁 7. Syncing Changes to Domain-Joined Servers

Once a Linux server is domain-joined (via `sssd` or `winbind`), user/group changes are available automatically. To force a refresh:

```bash
# For sssd
sss_cache -E

# For winbind
wbinfo -u && wbinfo -g
```

---

## 📦 8. Backup and Rebuild the Forest

For disaster recovery or redeployment, backup Samba AD:

```bash
# Offline backup
samba-tool domain backup offline --targetdir=/root/samba-backup

# Restore
samba-tool domain backup restore --backup-dir=/root/samba-backup
```

For exporting users and groups:

```bash
# List all users
samba-tool user list > users.txt

# List groups and members
samba-tool group list > groups.txt
samba-tool group listmembers PythonDevs
```

---

## 🖥️ 9. Registering Devices to the Domain

To enforce centralized access, policy control, and shared authentication, client devices must be **joined to the Samba AD domain**. This section outlines how to register both **Linux** and **Windows** devices.

---

### 🐧 Joining a Linux Client to the Samba AD Domain

#### ✅ Prerequisites

* Fully configured Samba AD Domain Controller
* DNS resolution for the domain (`example.local`) pointing to the Samba DC
* NTP synced with the DC (time drift breaks Kerberos)
* A domain account with permission to join machines (typically any authenticated user can join up to 10 machines; more requires delegation or domain admin)

#### 🔧 Installation & Configuration (Ubuntu/Debian Example)

```bash
# 1. Install required packages
sudo apt install realmd sssd sssd-tools samba-common krb5-user packagekit

# 2. Discover the domain
sudo realm discover example.local

# 3. Join the domain
sudo realm join --user=administrator example.local

# 4. Verify domain join
realm list
```

You may be prompted for the domain user password during the join process.

#### 🛠 Optional Configuration (for login control)

* Allow only domain users in specific groups to log in:

```bash
sudo realm permit -g SSHAccess
```

* Enable home directory creation on login (via PAM):

Edit `/etc/pam.d/common-session` and ensure:

```bash
session required pam_mkhomedir.so skel=/etc/skel/ umask=0022
```

---

### 🪟 Joining a Windows Client to the Domain

1. **Open** System Properties
2. Click on **Change settings** next to computer name
3. Click **Change**, then select **Domain**
4. Enter: `example.local`
5. Provide credentials of a domain user (e.g. `administrator`)
6. Restart when prompted

---

### 🔎 Post-Join Verification

#### On the Samba DC:

```bash
# Check if machine is listed
samba-tool computer list
```

#### On the client:

```bash
# On Linux
id username@EXAMPLE.LOCAL

# On Windows (CMD)
whoami /fqdn
```

---

### 📎 Notes

* Linux clients typically use `sssd` (modern) or `winbind` (legacy/compatible) to handle domain integration
* Make sure DNS settings point to the domain controller IP
* Device hostname must be unique in the domain
* For file share browsing, ensure `smbclient` is installed and test with:

```bash
smbclient -L //dc.example.local -U username
```

---

## ✅ Summary

This guide gives you a scalable, structured way to manage users, groups, and permissions in a Samba AD environment. You can:

* Organize by location and role using OUs
* Control access using AD groups
* Enforce security policies centrally
* Manage both local and remote developer access
* Support growth with automation and backups

