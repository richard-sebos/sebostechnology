
# *SELinux Basics for Secure Linux Administration*


# 🔐 Introduction to SELinux for Secure Linux Administration

SELinux (Security-Enhanced Linux) is a powerful, kernel-level security mechanism that enforces **mandatory access controls** (MAC) in Linux systems. Initially developed by the NSA and now maintained by the open-source community, SELinux restricts which users and processes can access system resources—even for users with root privileges.

## 🧱 What Is SELinux?

> **SELinux** is a MAC system built into the Linux kernel that uses a label-based policy model to enforce rules about which actions users, processes, and services can take.

Unlike traditional Linux permissions (user, group, other), SELinux can:

- Protect system resources using fine-grained policies
- Block unauthorized actions at the kernel level
- Prevent privilege escalation even by compromised services

### Example Use Cases:
- Restrict a web server from accessing files outside its directory.
- Deny a compromised process from accessing network sockets.
- Require additional policy changes when modifying service behavior (e.g., changing SSH port or Samba paths).

## 🤷 Why Do People Disable SELinux?

You’ll often find advice online like:

> “Turn off SELinux and see if the problem goes away.”

This happens because SELinux is strict by design—and misconfigurations or unfamiliarity can make it feel obstructive. But turning it off removes a major line of defense.

> **Security Tip**: Keep SELinux enabled. Fix the policy, don’t bypass it.

## 🔄 SELinux Modes

- **Enforcing**: SELinux actively enforces rules and denies access.
- **Permissive**: SELinux logs policy violations but doesn't enforce them.
- **Disabled**: SELinux is off entirely (not recommended).

Check the current status:

```bash
getenforce     # Outputs: Enforcing, Permissive, or Disabled
sestatus       # More detailed status report
````

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

**Next:** Learn how to use SELinux to restrict SSH access for administrative users in part 2 of this guide.

````

---

