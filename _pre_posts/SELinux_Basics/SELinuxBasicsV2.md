
# *SELinux Basics for Secure Linux Administration*

- What if you could use a security tool developed by the NSA to secure Linux server
- A tool that not only can protect your system from melisous action to also define file protection level at an enterprise level
- What if that tool was free to use and srutimized to the Open Source commitity to ensure it was safe from goverments trying to use it to hack your devices
- would you use it?

## 🔐 Introduction to SELinux for Secure Linux Administration

SELinux (Security-Enhanced Linux) is a powerful, kernel-level security mechanism that enforces **mandatory access controls** (MAC) in Linux systems. Initially developed by the NSA and now maintained by the open-source community, SELinux restricts which users and processes can access system resources—even for users with root privileges.

## 🧱 What Is SELinux?

> **SELinux** is a MAC system built into the Linux kernel that uses a label-based policy model to enforce rules about which actions users, processes, and services can take.

Unlike traditional Linux permissions (user, group, other), SELinux can:

- Protect system resources using fine-grained policies
- Block unauthorized actions at the kernel level
- Prevent privilege escalation even by compromised services

---

## 🏷️ SELinux Contexts, Roles, and Policies (Quick Overview)

SELinux makes decisions using **security contexts**, which are applied to files, processes, and users.

Each context looks like:

```

user\:role\:type\:level

````

**Key Components:**

| Element | Description | Example |
|--------|-------------|---------|
| `user` | SELinux user identity | `system_u` |
| `role` | What actions the user can perform | `user_r`, `sysadm_r` |
| `type` | Primary enforcement unit | `httpd_t`, `sshd_t`, `user_home_t` |
| `level` | MLS/labeling level (optional) | `s0` |

Most SELinux enforcement is **type-based**, often called **Type Enforcement (TE)**. Policies control which **types** (e.g., `httpd_t`) can access other types (e.g., `httpd_sys_content_t`).


---

## 🔄 SELinux Modes

- **Enforcing**: SELinux actively enforces rules and denies access.
- **Permissive**: SELinux logs policy violations but doesn't enforce them.
- **Disabled**: SELinux is off entirely (not recommended).

Check the current status:

```bash
getenforce     # Outputs: Enforcing, Permissive, or Disabled
sestatus       # More detailed status report
````

---

## 🤷 Why Do People Disable SELinux?

You’ll often find advice online like:

> “Turn off SELinux and see if the problem goes away.”

This happens because SELinux is strict by design—and misconfigurations or unfamiliarity can make it feel obstructive. But turning it off removes a major line of defense.

> **Security Tip**: Keep SELinux enabled. Fix the policy, don’t bypass it.
---

## 🎛️ SELinux Booleans

SELinux **booleans** are toggles that adjust specific policy behaviors without editing the full policy set.

For example:

```bash
# Allow Apache to initiate network connections
sudo setsebool -P httpd_can_network_connect on
```

### Useful Commands:

| Action            | Command                  |       |
| ----------------- | ------------------------ | ----- |
| View all booleans | `getsebool -a`           |       |
| Change a boolean  | \`setsebool -P <bool> on | off\` |
| Temporary change  | \`setsebool <bool> on    | off\` |

Booleans provide a convenient and safe way to modify behavior for services like:

* Apache (`httpd_*`)
* FTP (`ftp_home_dir`)
* Samba (`samba_export_all_rw`)
* SSH (`ssh_sysadm_login`)

---
- This was design as an interduction to SELinux to help with restricting `SSH` admin users
- SELinux is a much deeper subject and a powerfull tool
- It does come preconfigured. for general-purpose protection but there are policies setup for 
    - Government, military, classified systems
    - High-security systems, research, strict compliance environments
    - Virtualized environments, containers
    - Embedded or appliance environments
- as well as vendor-specific builds or hardened environments (e.g., PCI-DSS profiles)
- SELinux is a critical tool in the secure tool box that does not get the spot light it should. 

---
**Next:** Learn how to use SELinux to restrict SSH access for administrative users in part 2 of this guide.


