---
title: "Build Your Own AIDE Automation - Guide"
subtitle: Learn to Design and Implement Custom AIDE Automation with Cryptographic Verification from First Principles
date: 2025-11-29 10:20 +0000
categories: [Linux, Security]
tags: [AIDE, Automation, Bash, Scripting, GPG, FileIntegrity, SystemD, LinuxAdmin, Security, Tutorial]
---

> This guide accompanies the main article, **[AIDE in Motion: Automating and Signing System Integrity Checks](https://richard-sebos.github.io/sebostechnology/posts/AIDE-in-Motion/)**, and pairs with the **AIDE Daily Integrity Checklist** for a concise, printable summary of the workflow.

This section walks you through **how to build your own automation script**, step by step. Instead of copying a pre-made solution, you’ll learn how each component fits together so you can adapt it to your environment, strengthen the workflow, or extend it with your own logic.

Your final script will do four major things:

1. Verify the last report
2. Run a new AIDE check
3. (Optionally) update the baseline
4. Hash and sign the new report

Let’s walk through how to build each part.

---

## 🧩 **Step 1 — Create a Safe Working Layout**

Before writing any code, decide where the script lives and where evidence files will be stored.

You will need:

* A location for the script (example: `/usr/local/sbin/aide-daily-check.sh`)
* A log directory:

  * `/var/log/aide/`
* A secure directory for signatures and hashes:

  * `/root/.aide/reports/`

Ask yourself:

* Should the script be root-owned and root-only?
* Should signatures be immutable (`chattr +i`)?
* Does your environment require retention limits (e.g., 30 days of reports)?

Once you understand the layout, you're ready to build.

---

## 🧩 **Step 2 — Verify the Previous Report**

Before generating a new AIDE report, your script should confirm that the *last* one is still trustworthy.

To design this section, think through:

* How do you find the *latest* log in `/var/log/aide/`?
* How do you match it to the signatures/hashes in `/root/.aide/reports/`?
* What should happen if the verification fails?

  * Log it?
  * Email an alert?
  * Stop the script?

This step ensures your integrity chain is **continuous and unbroken**.

---

## 🧩 **Step 3 — Run a New AIDE Check**

Next, the script runs:

```bash
aide --check
```

To build this section:

* Create a timestamp (example: `2025-10-29_14-30-05`)
* Build the log filename (`aide-check-<timestamp>.log`)
* Redirect all output to `/var/log/aide/<filename>`
* Capture the exit code of `aide --check`

  * Should the script behave differently if AIDE finds changes?

Decide whether your script:

* Logs only to file
* Logs to both file and syslog
* Emails the results if AIDE reports modifications

This is where you tailor behavior to your organization’s needs.

---

## 🧩 **Step 4 — (Optional) Rebuild the Baseline**

Some security teams want:

* A static baseline (never updated)
* A periodic baseline (monthly/quarterly)
* A dynamic baseline (after successful verification)

Ask yourself:

* Should this script ever run `aide --init`?
* If so, how will you sign the new baseline?
* Should the script require manual approval for baseline updates?

This decision depends entirely on your change-control policy.

---

## 🧩 **Step 5 — Hash and Sign the New Report**

Now your script must make the new log tamper-evident.

You’ll create:

* A SHA-512 hash
* A detached GPG signature
* Both stored under `/root/.aide/reports/`

Ask yourself:

* Should you name the hash and signature after the timestamp?
* Should you lock them down with `chmod 400` and `chattr +i`?
* Should the script rotate old signatures?

This is the key security step: your logs become independently verifiable.

---

## 🧩 **Step 6 — Add Error Handling and Flow Control**

Every security automation script needs guardrails:

* What happens if GPG fails?
* What happens if `/var/log/aide` is full?
* What happens if the signature directory is read-only?
* Should the script stop on any error?
* Should it send an alert?

This is where you harden your workflow.

---

## 🧩 **Step 7 — Wrap It into a Daily Automation**

Finally, decide how the script will run daily:

### Option A — `systemd.timer`

* More modern
* Adds better logging and control
* Works well on servers

### Option B — `cron.daily`

* Simple
* Widely understood
* Less flexible

Your guide should show the high-level logic but let the reader implement the actual systemd/cron unit.

---

## 🧩 **Step 8 — Test Your Build**

Before deploying, walk users through:

* Running it manually
* Forcing failure conditions
* Checking logs
* Verifying signatures
* Ensuring timestamps rotate correctly
* Confirming safeguards work

This helps them develop confidence and prevents false positives later.

---

## 🧱 **End Result**

By the end of this build guide, the user will have:

* A custom Bash script
* A reproducible daily integrity-checking workflow
* A protected chain of signed AIDE reports
* A foundation they can automate, harden, or commercialize


