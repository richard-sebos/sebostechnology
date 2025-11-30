---
title: "AIDE Daily Automation Build - Checklist Your Implementation Roadmap"
subtitle: A Complete Step-by-Step Checklist for Deploying Signed, Verifiable AIDE Integrity Monitoring
date: 2025-11-29 10:15 +0000
categories: [Linux, Security]
tags: [AIDE, Checklist, Automation, GPG, FileIntegrity, Implementation, Deployment, LinuxAdmin, Security]
image:
  path: /assets/img/AIDEinMotion.png
  alt: Complete implementation checklist for AIDE daily automation with cryptographic verification
---

> This checklist is a companion to the main article, **AIDE in Motion**, and the detailed **AIDE Automation Build Guide**, which explains each step in greater depth.


# ✅ **AIDE Daily Integrity Automation — Build Checklist**

*A step-by-step checklist for creating a signed, verifiable AIDE automation workflow.*

---

## 🔧 **1. Prepare the Folder Structure**

* [ ] Create `/var/log/aide/` for daily reports
* [ ] Create `/root/.aide/` for secure storage
* [ ] Create `/root/.aide/reports/` for signatures + hashes
* [ ] Verify root-only permissions on `/root/.aide*`
* [ ] Decide retention policy (e.g., keep last 30–90 reports)

---

## 🔐 **2. Confirm Your GPG Signing Key**

* [ ] Ensure a GPG key pair exists (`gpg --list-keys`)
* [ ] Verify signing works (`gpg --detach-sign testfile`)
* [ ] Confirm public key export location (optional for auditing teams)

---

## 🛡 **3. Verify the Previous AIDE Report**

Before generating a new report:

* [ ] Identify the latest log in `/var/log/aide/`
* [ ] Find corresponding `.sig` + `.sha512` in `/root/.aide/reports/`
* [ ] Run signature verification (`gpg --verify`)
* [ ] Run hash verification (`sha512sum -c`)
* [ ] Decide failure action (stop / alert / log-only)

---

## 📝 **4. Run Today’s AIDE Check**

* [ ] Generate a timestamp (e.g., `2025-10-30_14-05-22`)
* [ ] Build log filename (`aide-check-<timestamp>.log`)
* [ ] Run: `aide --check > /var/log/aide/<file>`
* [ ] Collect exit code
* [ ] Decide notification behavior on changes (email? syslog?)

---

## 🏗 **5. Decide Baseline Policy**

* [ ] Will baseline be static, periodic, or dynamic?
* [ ] If updating baseline:

  * [ ] Run `aide --init`
  * [ ] Sign new baseline
  * [ ] Verify signature
  * [ ] Store signature under `/root/.aide/`

---

## 🧾 **6. Hash and Sign Today’s Report**

* [ ] Hash file (`sha512sum`)
* [ ] Save hash to `/root/.aide/reports/`
* [ ] Sign file (`gpg --detach-sign`)
* [ ] Save signature to `/root/.aide/reports/`
* [ ] Apply `chmod 400`
* [ ] Apply `chattr +i`

---

## 🚦 **7. Add Error Handling**

* [ ] Check for full disks
* [ ] Check for missing directories
* [ ] Check for missing GPG key
* [ ] Decide script exit behavior on failure
* [ ] Add logging (syslog or file-based)

---

## ⏱ **8. Automate the Script**

Choose one:

### Using systemd.timer

* [ ] Create service unit
* [ ] Create timer unit
* [ ] Enable + start the timer
* [ ] Check `journalctl -u service`

### Using cron

* [ ] Add entry to `/etc/cron.daily/` or crontab
* [ ] Test manual run
* [ ] Confirm log rotation behavior

---

## 🔍 **9. Test the Entire Workflow**

* [ ] Run script manually
* [ ] Force a failure (modify a file)
* [ ] Confirm AIDE detects change
* [ ] Confirm signature verification catches tampering
* [ ] Confirm timestamp rotation
* [ ] Confirm automation triggers daily
* [ ] Confirm no privileged files are world-readable

---

# 📦 **Optional: Add Enhancements**

* [ ] Email alerts
* [ ] Slack/Teams webhook notifications
* [ ] Filebeat/Splunk forwarding
* [ ] Baseline approval workflow
* [ ] Ansible deployment
* [ ] Daily diff comparison

---

# 🏁 **Done! Your AIDE Automation Workflow Is Now Verified & Hardended**

This checklist can be included as:

* A downloadable Markdown file
* A one-page PDF for sysadmins
* A GitHub Gist
* A GitHub repository asset

