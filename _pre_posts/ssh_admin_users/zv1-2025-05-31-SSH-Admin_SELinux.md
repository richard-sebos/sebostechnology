# ✅ *Blocking Admin SSH Logins with SELinux (`ssh_sysadm_login`)*



- In Part 1, we introduced a restricted jump user that is a non-admin account with restrict access to the Linux system.
- it is used to login the Linux server and su into other accounts that greater access but does not have SSH access
- In this article, we are going to restrict admin from logging in with SSH with SELinux boolean ssh_sysadm_login

> Not sure what SELinux and SELinux boolean are?  Checkout [SELinux Basics here]()

This adds a crucial defense-in-depth layer: **admin access is only available after logging in through a restricted jump account**.


## 🔍 Step 1: Verify SELinux is Enforcing

Ensure your system is running SELinux in `enforcing` mode:

```bash
getenforce
# Output should be: Enforcing

sestatus
# Output should show:
# SELinux status:                 enabled
# Current mode:                  enforcing
# Loaded policy name:            targeted
````

If not in enforcing mode, temporarily enable it:

```bash
sudo setenforce 1
```

Install SELinux tools if not installed:

```bash
sudo dnf install -y policycoreutils selinux-policy-targeted policycoreutils-python-utils
```
- this is needed to assign context to users.
- we will be using the predefined context `sysadm_u` which lets SELinux apply admin policies to a user
---

## 👥 Step 2: Associate Admin Users with `sysadm_u` Context

To restrict SSH for specific users via SELinux, they must be assigned the `sysadm_u` SELinux user type.

```bash
sudo semanage login -a -s sysadm_u rchamberlain
```

> Replace `rchamberlain` with your actual admin username.

---

## 🔒 Step 3: Disable `ssh_sysadm_login` Boolean

The SELinux boolean `ssh_sysadm_login` controls whether `sysadm_u` users (typically mapped to `wheel` group or elevated users) can log in via SSH.

Disable it:

```bash
sudo setsebool -P ssh_sysadm_login off
```

Verify:

```bash
getsebool ssh_sysadm_login
# Output: ssh_sysadm_login --> off
```
- Now users in the ssh_sysadm_login can not log in through SSH

---

## ✅ Outcome

With this configuration:

* Admins mapped to `sysadm_u` **cannot log in over SSH**
* Only restricted, non-privileged users (e.g., `richard`) can SSH into the system
* Admins must **switch to elevated users** *after* accessing via a secure jump account

---
## Why Not Use sshd_config 
- SSH config file can be used to allow groups are user to log into SSH
- It is a feature I use on most my Linux servers.
- But it is easy to miss configure by adding admin users to SSH groups
- the `ssh_sysadm_login` way to ensure those miss configuration do not end up providing access you don't want
- In the end, but should be used to have have a balance layered security
---

## 🛡️ Final Thoughts

This method enhances SSH hardening by:

* Reducing exposure of privileged accounts
* Requiring an additional step before escalation
* Making credential theft less effective

Combine this with:

* SSH Key Authentication
* Fail2Ban
* Two-Factor Authentication (2FA)

…and you’ll have a much stronger security posture.

---

**Looking to build secure Linux workflows for your organization?** I offer services around automation, hardening, and server security. [Get in touch](mailto:info@sebostechnology.com) or visit [sebostechnology.com](https://sebostechnology.com) to learn more.

