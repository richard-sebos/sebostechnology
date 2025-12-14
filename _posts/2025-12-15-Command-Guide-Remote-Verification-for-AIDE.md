---
title: "AIDE Remote Aggregation - Command Reference"
subtitle: Essential Commands for Secure Remote AIDE Verification and Distributed Integrity Monitoring
date: 2025-12-14 09:00 +0000
categories: [Linux, Security]
tags: [AIDE, CommandReference, Rsync, SSH, RemoteBackup, FileIntegrity, LinuxAdmin, Security, CheatSheet]
image:
  path: /assets/img/AIDE-Command-Reference.png
  alt: AIDE remote aggregation command reference with SSH security and rsync configuration
---

> **Note:** This reference provides the key commands and concepts for building a remote AIDE verification system. For a complete, production-ready implementation with automation scripts, monitoring, and enterprise-grade security hardening, [contact me for consulting](https://sebostechnology.com).

---

## 🔐 SSH Key Setup

Generate a dedicated SSH key for AIDE synchronization:

```bash
# Ed25519 (recommended for modern systems)
ssh-keygen -t ed25519 -f /root/.ssh/id_ledger_push -C "AIDE sync"

# Set restrictive permissions
chmod 600 /root/.ssh/id_ledger_push
```

**Key concept:** Use a purpose-specific key, not your general SSH key. This limits exposure if compromised.

---

## 🛡️ Secure the Remote Server

On the remote server, restrict what the SSH key can do:

```bash
# In the remote user's ~/.ssh/authorized_keys file:
command="/path/to/wrapper-script.sh",no-pty,no-port-forwarding ssh-ed25519 AAAA...
```

**Key restrictions:**
- `command="..."` — Forces execution of specific script only
- `no-pty` — Prevents interactive shell access
- `no-port-forwarding` — Blocks tunneling

**Why this matters:** Even if someone steals your SSH key, they can't get a shell or run arbitrary commands.

**Wrapper script concept:** A simple bash script that validates the rsync command and destination path, rejecting everything else. This prevents the key from being used for anything except the intended data transfer.

---

## 📤 Sync AIDE Data

Use rsync with filters to transfer only what matters:

```bash
rsync -avz --timeout=60 \
  --include-from=/etc/ledger-push-filters.txt \
  -e "ssh -i /root/.ssh/id_ledger_push" \
  /var/lib/system_metrics/ \
  remote-user@remote-server:/path/to/incoming/
```

**Filter file example** (`/etc/ledger-push-filters.txt`):
```text
+ .c         # Ledger chain
+ .l/***     # Logs
+ .h/***     # Hashes
+ .s/***     # Signatures
- *          # Everything else
```

**Pro tip:** Remove the `--delete` flag to prevent attackers from destroying remote evidence.

---

## ✅ Verify Remote Integrity

On the remote server, compare incoming data against archived baselines:

```bash
# Create baseline archive (first time)
tar -czf baseline_$(date +%Y%m%d).tar.gz /path/to/incoming/

# Verify ledger chain integrity
diff archived/.c incoming/.c

# Create new archive after verification
tar -czf archive_$(date +%Y%m%d).tar.gz /path/to/incoming/
```

**What to look for:**
- New entries at end of ledger chain = ✅ Normal
- Changes to historical entries = 🚨 **Tampering detected**

---

## 🔒 Security Enhancements

### Make Archives Immutable

```bash
chattr +i /path/to/archive.tar.gz
```

Prevents deletion or modification, even by root.

### Restrict Network Access

```bash
# Example firewall rule (firewalld)
firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4"
  source address="YOUR_SOURCE_IP/32"
  port protocol="tcp" port="22" accept'
```

Only allow SSH from your monitored systems.

---

## 🛠️ Key Paths

| Location | Purpose |
|----------|---------|
| `/root/.ssh/id_ledger_push` | SSH private key for sync |
| `/etc/ledger-push-filters.txt` | Rsync filter rules |
| `/var/lib/system_metrics/` | Source AIDE artifacts |
| `/path/to/incoming/` | Remote incoming directory |
| `/path/to/archives/` | Remote archive storage |

---

## 📊 What's Missing from This Guide?

This reference shows the **core concepts** and **key commands**, but a production implementation requires:

- ✅ **Automated sync scripts** with error handling and logging
- ✅ **GPG signature verification** for incoming data
- ✅ **Systemd timers** for scheduled synchronization
- ✅ **Monitoring and alerting** for failed verifications
- ✅ **Archive retention policies** to manage disk space
- ✅ **Disaster recovery procedures** for compromised systems
- ✅ **Complete wrapper scripts** with path validation
- ✅ **Remote server setup** with proper user accounts and permissions

**Need a turnkey solution?** I offer consulting services for implementing production-ready AIDE infrastructure with:
- Complete automation and monitoring
- Security hardening and compliance alignment
- Custom integration with your existing systems
- Ongoing support and maintenance

[Contact me for infrastructure consulting](https://sebostechnology.com)

---

## 🧩 Related Articles

1. **[AIDE - File Integrity Monitoring for System Security](https://richard-sebos.github.io/sebostechnology/posts/AIDE-Overview/)**
2. **[AIDE in Motion: Automating and Signing System Integrity Checks](https://richard-sebos.github.io/sebostechnology/posts/AIDE-in-Motion/)**
3. **[AIDE Automation Framework: From Integrity Checks to Self-Verification](https://richard-sebos.github.io/sebostechnology/posts/Chaining-Logs/)**

---

**More guides:** [sebostechnology.com](https://sebostechnology.com)
**Need help with your infrastructure?** I offer consulting for server automation, security hardening, and infrastructure optimization.
