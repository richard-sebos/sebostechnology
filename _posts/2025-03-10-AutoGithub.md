---
title: Stop Losing Code: Automate Your GitHub Backups with Bash Scripts
date: 2025-03-10 12:32 +0000
categories: [Github, Bash, Automation, DevOps Tools, Code Management]
tags: [Automation,BashScripting,DevOps,Git, Git Automation, ProductivityHacks] 
---

Are you tired of losing track of your projects and code scattered across multiple machines? You’re not alone. I used to have this bad habit of never checking in my code, which left me hunting down files across old laptops and virtual machines. That changed when I automated my GitHub workflow with simple Bash scripts. Here’s how you can **automate GitHub backups and secure your code effortlessly**.

---

## **🚀 Table of Contents**

1. [Why You Should Automate Code Backups](#why-you-should-automate-code-backups)
2. [Automating GitHub Repository Setup](#automating-github-repository-setup)
3. [Securing GitHub Authentication via SSH and API Tokens](#securing-github-authentication-via-ssh-and-api-tokens)
4. [Automating Code Sync and Git Push](#automating-code-sync-and-git-push)
5. [Final Thoughts and Next Steps](#final-thoughts-and-next-steps)

---

## **📂 Why You Should Automate Code Backups**

Manual backups fail because… well, we’re human. Automating this process ensures that your projects are always safe, versioned, and recoverable—even if your machine crashes tomorrow.

💡 **Pro Tip:** Automating GitHub repository creation and code check-ins not only saves time but also improves your DevOps hygiene.

---

## **🔧 Automating GitHub Repository Setup**

While working on my *Ethical Hacking Robot* project, I realized my code wasn’t backed up anywhere. This led me to create a **Bash script that automatically links new projects to GitHub repositories** using a configuration file.

### 🗂️ **Configuration Variables (setup\_config.sh):**

* `USERNAME` – Linux user running the project
* `GITHUB_REPO` – Target GitHub repository URL
* `GIT_USER_NAME` – GitHub account name
* `GIT_USER_EMAIL` – GitHub email
* `GITHUB_API_TOKEN` – GitHub API token (retrieved securely at runtime)

### 📄 **Sample Script:**

```bash
#!/bin/bash
source setup_config.sh
LOGFILE="/home/$USERNAME/setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

bash setup_github.sh "$USERNAME" "$GITHUB_REPO" "$GIT_USER_NAME" "$GIT_USER_EMAIL" "$GITHUB_API_TOKEN"
```

---

## **🔐 Securing GitHub Authentication via SSH and API Tokens**

Security first! Instead of hardcoding sensitive credentials, I store the GitHub API token in a secure file. The script then generates SSH keys and configures GitHub authentication automatically.

```bash
sudo -u $USERNAME ssh-keygen -t rsa -b 4096 -C "$USERNAME@$(hostname)" -f $USER_HOME/.ssh/id_rsa -N ""

echo "Host github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no" | sudo -u $USERNAME tee $USER_HOME/.ssh/config > /dev/null
```

💡 **Quick Security Tip:** Always restrict permissions on sensitive files like `.github_token` using `chmod 600`.

---

## **📦 Automating Code Sync and Git Push**

Now that authentication is set, it’s time to sync your local code with GitHub automatically.

### 📁 **Define Source and Destination Paths:**

```bash
SRC_ROS2="/home/ros2_dev/ros2_ws/src/"
SRC_NON_ROS="/home/ros2_dev/non_ros_code/"
DEST_GITHUB="/home/ros2_dev/github/dev/"
```

### 🔄 **Sync Code Using Rsync:**

```bash
rsync -av --exclude='build/' --exclude='install/' --exclude='log/' "$SRC_ROS2" "$DEST_GITHUB/src/"
rsync -av "$SRC_NON_ROS" "$DEST_GITHUB/non_ros_code/"
```

### 📤 **Automate Git Commit and Push:**

```bash
git add dev/
git commit -m "Automated backup on $(date)"
git push origin main
```

💡 **Pro Tip:** Schedule this script using `cron` for fully automated daily or hourly backups.

---

## **📅 Final Thoughts and Next Steps**

This workflow has saved me countless hours and secured my codebase across multiple projects. But it’s still a work in progress. Next, I plan to:

* Replace hardcoded paths with dynamic variables.
* Add full error handling and logging.
* Publish a fully polished version of these scripts as a public GitHub repository.

👉 **[Check out the full working scripts here!](https://github.com/richard-sebos/Ethical-Hacking-Robot/tree/main/Git-Automation)**

If you found this helpful, **share it with your network or drop a comment below!** What automation hacks are you using to improve your workflow?

