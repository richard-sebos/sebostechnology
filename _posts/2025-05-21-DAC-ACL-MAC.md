---
title: 🛡️ How Secure Are Your Linux Files? Access Control Demystified
date: 2025-05-21 12:11 +0000
description: "Learn how to secure Linux files using DAC, ACLs, and MAC. Explore key tools like AppArmor, SELinux, and Auditd to enhance system access control and prevent unauthorized access."
image: /assets/img/DAC-ACL-MAC.png
categories: [Linux access control,Linux security, system permissions, Linux auditing]
tags: [DAC, ACLs, MAC, AppArmor, SELinux, Auditd]
---
## Introduction

At a high level, Linux file permissions seem simple. You use `ls -l` to view them, and tools like `chmod` and `chown` to change who can read, write, or execute a file. This basic model—known as Discretionary Access Control (DAC)—is where most users start.

But Linux security goes much deeper.

Beyond traditional permissions, there are advanced access control mechanisms designed for more granular and robust security. In this guide, we explore three key models:

* **Discretionary Access Control (DAC)**
* **Access Control Lists (ACLs)**
* **Mandatory Access Control (MAC)**

We’ll also examine the tools that help implement and monitor these models—**AppArmor**, **SELinux**, and **Auditd**—to give you a high-level understanding of how they work together to secure your system.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Discretionary Access Control (DAC)](#1-discretionary-access-control-dac)
3. [Access Control Lists (ACLs)](#2-access-control-lists-acls)
4. [Mandatory Access Control (MAC)](#3-mandatory-access-control-mac)

   * [AppArmor](#apparmor)
   * [SELinux](#selinux)
5. [Auditd: Monitoring Access Controls](#auditd-monitoring-access-controls)
6. [Comparison Table](#comparison-table)
7. [Conclusion](#conclusion)

---

## 1. Discretionary Access Control (DAC)

### Overview

DAC is the traditional Unix/Linux permission model, where file owners determine access rights.

### Key Features

* **Ownership**: Each file/directory has an owner and group.
* **Permissions**: Read (`r`), write (`w`), and execute (`x`) permissions for owner, group, and others.

### Example

```bash
ls -l file.txt
-rw-r--r-- 1 alice users 1024 May 21 10:00 file.txt
```

In this example:

* **Alice**: Read and write permissions.
* **Users group**: Read permission.
* **Others**: Read permission.

### Pros and Cons

* ✅ **Pros**: Simple and straightforward.
* ❌ **Cons**: Limited granularity; potential for misconfigurations.

---

## 2. Access Control Lists (ACLs)

### Overview

ACLs provide more granular permissions beyond the traditional owner/group/others model.

### Key Features

* **Fine-Grained Control**: Assign specific permissions to individual users or groups.
* **Flexibility**: Ideal for collaborative environments.

### Example

```bash
setfacl -m u:bob:rw file.txt
getfacl file.txt
```

This grants read and write permissions to user Bob on `file.txt`.

### Pros and Cons

* ✅ **Pros**: Enhanced flexibility; precise control.
* ❌ **Cons**: Can become complex to manage.

---

## 3. Mandatory Access Control (MAC)

### Overview

MAC enforces system-wide policies that users cannot override, providing robust security.

### Key Features

* **System-Enforced Policies**: Access decisions are based on predefined rules.
* **Enhanced Security**: Limits the potential impact of compromised accounts or applications.

### AppArmor

AppArmor uses path-based profiles to restrict program capabilities.

#### Example Profile

```text
/usr/sbin/nginx {
  /var/www/** r,
  /etc/nginx/** r,
  /etc/shadow r,
}
```

This profile restricts `nginx` to read-only access on specified directories.

### SELinux

SELinux employs label-based policies, assigning security contexts to files and processes.

#### Example

```bash
ls -Z /var/www/html/index.html
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 index.html
```

The security context ensures only authorized processes can access the file.

### AppArmor vs. SELinux

| Feature       | AppArmor            | SELinux                           |
| ------------- | ------------------- | --------------------------------- |
| Policy Type   | Path-based          | Label-based                       |
| Ease of Use   | Easier to configure | More complex, granular control    |
| Default in    | Ubuntu, SUSE        | RHEL, Fedora, CentOS              |
| Configuration | `/etc/apparmor.d/`  | `/etc/selinux/`, `semanage` tools |

---

## Auditd: Monitoring Access Controls

### Overview

Auditd is the Linux auditing system, logging access attempts and policy violations.

### Key Features

* **Comprehensive Logging**: Tracks access events, denials, and policy breaches.
* **Integration**: Works seamlessly with AppArmor and SELinux.

### Example Logs

**AppArmor Denial**

```
audit[1234]: apparmor="DENIED" operation="open" profile="/usr/sbin/nginx" name="/etc/shadow"
```

**SELinux Denial**

```
type=AVC msg=audit(1623046567.583:107): avc:  denied  { read } for  pid=1327 comm="nginx" name="shadow"
```

### Setting Audit Rules

To monitor access to `/etc/passwd`:

```bash
auditctl -w /etc/passwd -p wa -k passwd_watch
```

Retrieve logs with:

```bash
ausearch -k passwd_watch
```

---

## Comparison Table

| Feature            | DAC          | ACLs                         | MAC (AppArmor/SELinux)  |
| ------------------ | ------------ | ---------------------------- | ----------------------- |
| Control Level      | User-defined | User-defined with exceptions | System-enforced         |
| Granularity        | Basic        | Fine-grained                 | Very fine-grained       |
| User Modifiable    | Yes          | Yes                          | No                      |
| Complexity         | Low          | Medium                       | High                    |
| Audit Capabilities | Limited      | Limited                      | Extensive (with Auditd) |

---

## Conclusion

Implementing robust access controls is vital for Linux system security:

* **DAC**: Suitable for simple permission models.
* **ACLs**: Offer enhanced flexibility for complex environments.
* **MAC**: Provide stringent, system-enforced security policies.
* **Auditd**: Essential for monitoring and auditing access events.

By understanding and appropriately applying these mechanisms, administrators can significantly enhance the security posture of their Linux systems.

