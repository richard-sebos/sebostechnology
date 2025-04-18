---
title: Automating GitHub Code Check-Ins
date: 2025-03-10 00:32 +0000
categories: [Github, Bash, Automation]
tags: [Automation,BashScripting,DevOps,Git] 
---

I have a bad habit of not checking in my code. Because of this, I’ve ended up with code scattered across multiple machines over the years. A few years back, I started using GitHub, but if I’m being honest, only about half of my code actually makes it there. This year, I want that to change.  
Here’s a Table of Contents for your article:  



## **Table of Contents**  

2. [Automating the Process](#automating-the-process)  
3. [Linking a Project to a GitHub Repository](#linking-a-project-to-a-github-repository)  
4. [Setting Up GitHub Authentication](#setting-up-github-authentication)  
5. [Checking In Code](#checking-in-code)  
6. [What’s Next?](#whats-next)  

---

This makes navigation easier, especially if you're posting it in a markdown-friendly environment like GitHub or a wiki. Let me know if you’d like any modifications! 🚀
## Automating the Process  

This morning, while creating a new directory structure for my Ethical Hacking Robot project, I realized that the code wasn’t checked in anywhere. As I designed a bash script to set up the directory structure, it seemed like the perfect time to fix this bad habit. I decided to create two additional scripts—one to link a project to a GitHub repository and another to handle syncing and pushing code automatically. After testing, both scripts worked well, and they’ve already improved my workflow.  

## Linking a Project to a GitHub Repository  

To streamline the process, I created a script that links a new project to a GitHub repository as the project directories are being set up. This script relies on a configuration file, `setup_config.sh`, which includes:  

- **USERNAME** – The local Linux system username  
- **GITHUB_REPO** – The GitHub repository URL  
- **GIT_USER_NAME** – The GitHub account name  
- **GIT_USER_EMAIL** – The email associated with the GitHub account  
- **GITHUB_API_TOKEN** – A GitHub API token for authentication  

Since storing sensitive credentials directly in the config file is a bad practice, the API token isn’t hardcoded. Instead, it’s retrieved at runtime from a secure, restricted file (`/home/richard/.github_token`). The script structure is straightforward:  

```bash
#!/bin/bash

# Load configuration variables
source setup_config.sh  # User and GitHub setup

LOGFILE="/home/$USERNAME/setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Creates project users and files
.
.
.
# Call GitHub setup script
bash setup_github.sh "$USERNAME" "$GITHUB_REPO" "$GIT_USER_NAME" "$GIT_USER_EMAIL" "$GITHUB_API_TOKEN"
```

## Setting Up GitHub Authentication  

Once the script is executed, it sets up SSH authentication for GitHub access. It generates an SSH key for the project user and updates the `.ssh/config` file to streamline authentication:  

```bash
sudo -u $USERNAME ssh-keygen -t rsa -b 4096 -C "$USERNAME@$(hostname)" -f $USER_HOME/.ssh/id_rsa -N ""

echo "Host github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no" | sudo -u $USERNAME tee $USER_HOME/.ssh/config > /dev/null
```

Next, it uses `curl` and the GitHub API token to register the SSH key with GitHub:  

```bash
curl -H "Authorization: token $GITHUB_API_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     --data "{\"title\":\"$USERNAME@$(hostname)\", \"key\":\"$SSH_KEY_CONTENT\"}" \
     https://api.github.com/user/keys
```

With authentication in place, the script configures Git global settings and either clones the repository or pulls the latest updates if it already exists:  

```bash
sudo -u $USERNAME git config --global user.name "$GIT_USER_NAME"
sudo -u $USERNAME git config --global user.email "$GIT_USER_EMAIL"

if [ -d "$USER_HOME/github/.git" ]; then
    echo "✅ Repository already exists. Pulling latest updates..."
    sudo -u $USERNAME git -C $USER_HOME/github pull origin main
else
    echo "🔹 Cloning GitHub repository..."
    sudo -u $USERNAME git clone "$GITHUB_REPO" "$USER_HOME/github"
fi
```

Since the project script creates a new Linux user to run the project under, `sudo` is necessary throughout this process.  

## Checking In Code  

Now that the project is linked to a repository, the next step is automating code check-ins. My repository stores development, staging, and production code. The check-in script specifically syncs development code with GitHub.  

First, it defines the source and destination directories:  

```bash
SRC_ROS2="/home/ros2_dev/ros2_ws/src/"
SRC_NON_ROS="/home/ros2_dev/non_ros_code/"
DEST_GITHUB="/home/ros2_dev/github/dev/"
```

Then, `rsync` is used to sync the development directory with the local Git repository while excluding unnecessary build files:  

```bash
rsync -av --exclude='build/' --exclude='install/' --exclude='log/' "$SRC_ROS2" "$DEST_GITHUB/src/"

# Sync non-ROS2 code
rsync -av "$SRC_NON_ROS" "$DEST_GITHUB/non_ros_code/"
```

Finally, the script stages, commits, and pushes the code to GitHub:  

```bash
git add dev/
git commit -m "Backup dev workspace to GitHub on $(date)"
git push origin main
```

## What’s Next?  

While this setup is a significant improvement, it’s far from perfect. Right now, there are hardcoded paths everywhere, and the process isn’t fully automated. These are the next areas I’ll be addressing.  

If you're interested in the full code, you can find it [here](https://github.com/richard-sebos/Ethical-Hacking-Robot/tree/main/Git-Automation).