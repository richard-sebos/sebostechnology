---
title: Installing ROS 2 on Ubuntu with `ros2_install.sh`
date: 2025-04-09 17:58 +0000
categories: [Robotics, ROS2 Install Series, Security]
tags: [ros2, robotics, cybersecurity, linux]
---

Here's a polished, professional-yet-friendly article version of your script documentation. It's structured with a **Table of Contents**, clear **SEO-friendly wording**, and paragraph formatting to make it reader- and documentation-friendly.


Setting up a reliable and efficient ROS 2 development environment is a key step in any robotics or automation project. In our [previous post](#), we covered how to:

- Update a fresh Ubuntu installation.
- Create and configure a dedicated ROS 2 user.
- Prepare the system for installing ROS 2.

Now, we’ll continue that journey by walking through the `ros2_install.sh` script. This script automates the installation of ROS 2 base components and supporting tools to streamline your development setup.

> ✅ **Note:** These steps are tailored for Ubuntu 20.04 (Focal) and Ubuntu 22.04 (Jammy) systems.

---

## 📚 Table of Contents

1. [Overview of the `ros2_install.sh` Script](#overview-of-the-ros2_installsh-script)
2. [Step-by-Step Breakdown](#step-by-step-breakdown)
   - [Installing Prerequisite Packages](#installing-prerequisite-packages)
   - [Adding the ROS 2 Repository](#adding-the-ros-2-repository)
   - [Installing ROS 2 Base and Tools](#installing-ros-2-base-and-tools)
   - [Initializing rosdep](#initializing-rosdep)
   - [Setting Up the ROS 2 Environment](#setting-up-the-ros-2-environment)
3. [Next Steps](#next-steps)
4. [SEO Tags](#seo-tags)

---

## Overview of the `ros2_install.sh` Script

The `ros2_install.sh` script is designed to automate the key steps needed to install ROS 2 on a clean Ubuntu system. It handles:

- Installing all necessary system dependencies.
- Adding the official ROS 2 package repository and its GPG key.
- Installing core ROS 2 packages along with useful developer tools.
- Initializing `rosdep`, which handles ROS dependency management.

This script greatly simplifies what would otherwise be a tedious manual installation process.

---

## Step-by-Step Breakdown

### Installing Prerequisite Packages

```bash
apt install -y curl gnupg2 lsb-release software-properties-common
```

This command installs essential tools needed to add third-party APT repositories:

- `curl`: Downloads content from URLs (used to retrieve the GPG key).
- `gnupg2`: Manages GPG keys to verify repository authenticity.
- `lsb-release`: Outputs distribution codename (e.g., `focal`, `jammy`) for dynamic configuration.
- `software-properties-common`: Allows managing additional APT sources.

---

### Adding the ROS 2 Repository

#### Import the GPG Key:

```bash
curl -sSL "$ROS_KEY_URL" -o /etc/apt/trusted.gpg.d/ros.asc
```

This command downloads the ROS 2 repository's public GPG key and stores it in the system’s trusted keyring, ensuring secure installation of ROS packages.

#### Add the Repository:

```bash
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/ros.asc] $ROS_REPO_URL $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list
```

This command adds the ROS 2 repository to the system’s APT sources. It automatically uses the appropriate Ubuntu codename (e.g., `jammy`) to ensure compatibility.

#### Update APT Cache:

```bash
apt update
```

This refreshes the package index so the newly added ROS 2 repository is recognized.

---

### Installing ROS 2 Base and Tools

```bash
apt install -y ros-$ROS_DISTRO-ros-base python3-rosdep python3-colcon-common-extensions python3-argcomplete colcon
```

This installs the ROS 2 base system and essential development tools:

- `ros-$ROS_DISTRO-ros-base`: The minimal installation of ROS 2.
- `python3-rosdep`: Tool to resolve and install ROS package dependencies.
- `colcon`, `python3-colcon-common-extensions`: ROS 2’s recommended build system.
- `python3-argcomplete`: Adds command-line autocompletion for ROS CLI tools.

---

### Initializing rosdep

#### One-Time Initialization (if needed):

```bash
[ -f /etc/ros/rosdep/sources.list.d/20-default.list ] || rosdep init
```

This checks whether `rosdep` has already been initialized. If not, it runs the initialization process.

#### Update rosdep Definitions:

```bash
rosdep update
```

Downloads the latest package dependency definitions so that `rosdep` can install required system packages for ROS nodes.

---

### Setting Up the ROS 2 Environment

#### Source the Environment Manually:

```bash
source /opt/ros/<distro>/setup.bash
```

This sets up necessary environment variables (like `ROS_PACKAGE_PATH`) for ROS 2 in the current terminal session.

#### Make it Persistent for a User:

```bash
grep -q "source /opt/ros/$ROS_DISTRO/setup.bash" /home/$ROS_USER/.bashrc \
|| echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$ROS_USER/.bashrc
```

This command ensures the ROS 2 environment is automatically sourced every time the user opens a new terminal. It checks for an existing entry to avoid duplicates.

---

## Next Steps

At this point, your system should be fully prepared for ROS 2 development. Here’s what we’ve achieved so far:

- A freshly installed and updated Ubuntu system.
- A dedicated user account configured for ROS 2.
- ROS 2 base system and build tools installed and ready to use.

In the **next post**, we’ll focus on securing the ROS 2 environment using **AppArmor** and **Auditd**, adding an extra layer of protection to your robotics platform.

