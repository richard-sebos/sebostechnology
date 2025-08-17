---
title: Streamlining SSH Key Management
date: 2024-10-13 19:12 +0000
categories: [SSH, Auth Keys]
tags: [ SSH, servers, cybersecurity]
image: 
  path: /assets/img/KeyManagement.png
  alt: "Bash script to help generate SSH keys" 
---

## Introduction  

When working with multiple servers, **SSH keys** are indispensable for secure authentication. Early in my workflow, I relied on a single key pair reused across all systems. While convenient, this practice introduces a major security risk: if that key is compromised, every connected server is at risk.

## Table of Contents
1. [Introduction](#introduction)  
2. [The Role of `.ssh/config`](#the-role-of-sshconfig)  
3. [How the Script Works](#how-the-script-works)  
   - [1. Server Directory](#1-server-directory)  
   - [2. File Permissions](#2-file-permissions)  
   - [3. Generating the Keys](#3-generating-the-keys)  
   - [4. Creating the Config File](#4-creating-the-config-file)  
   - [5. Linking to `.ssh/config`](#5-linking-to-sshconfig)  
   - [6. Testing the Connection](#6-testing-the-connection)  
4. [Example Run](#example-run)  
5. [Why This Matters](#why-this-matters)  
6. [Next Steps](#next-steps)  

---

A safer approach is to generate **unique key pairs per server**. The challenge, however, is that managing dozens of keys can quickly clutter your `.ssh` directory. To solve this, I created a **Bash script** that automates key generation, keeps configurations organized, and makes connecting to servers seamless.

---

## Leveraging the `.ssh/config` File

The `.ssh/config` file defines how you connect to different servers. Some of the most common parameters include:

* **Host** – The alias you’ll use for quick access.
* **HostName** – The server’s IP address or DNS record.
* **User** – The login username.
* **IdentityFile** – The private key file for authentication.

By splitting configurations into **include files**, SSH setups become easier to manage. My script automates this by generating per-server config files and linking them back to your main `.ssh/config`.

---

## How the Script Works

The script takes three inputs—**hostname**, **IP address**, and **username**—and handles everything else automatically:

1. Creates a secure directory for keys and configuration.
2. Generates a new SSH key pair.
3. Copies the public key to the target server.
4. Builds a dedicated config file.
5. Updates the main `.ssh/config` to include the new entry.
6. Tests the connection.

---

### 1. Server Directory

Each server gets its own folder under `~/.ssh/include.d/` for keys and configs:

```bash
config_directory=/home/${local_user}/.ssh/include.d/${host_name}
mkdir -p ${config_directory}
```

---

### 2. File Permissions

Security starts with proper permissions. The script enforces strict ACL rules to keep your keys safe:

```bash
setfacl -d -m u::rw,g::-,o::- ${config_directory}
```

---

### 3. Generating the Keys

It then creates a new **ed25519 key pair** (with no passphrase by default) and pushes the public key to the remote server:

```bash
ssh-keygen -t ed25519 -f ${config_directory}/${host_name} -N ""
ssh-copy-id -i ${config_directory}/${host_name}.pub ${user}@${ip_address}
```

---

### 4. Creating the Config File

Next, a lightweight config file is generated for the server:

```bash
cat <<EOL > ${config_directory}/config
Host ${host_name}
     HostName ${ip_address}
     User ${user}
     IdentityFile ${config_directory}/${host_name}
EOL
```

---

### 5. Linking to `.ssh/config`

The script ensures your main config file includes the new entry automatically:

```bash
echo "Include ${config_directory}/config" | cat - ~/.ssh/config > temp_file && mv temp_file ~/.ssh/config
```

---

### 6. Testing the Connection

Finally, it validates the setup by attempting a login:

```bash
ssh ${host_name}
```

If successful, you can now connect to the server with a simple:

```bash
ssh <hostname>
```

---

## Example

Running:

```bash
create_ssh_login.bash proxmox 192.168.177.7 richard
```

Produces the following structure:

```
~/.ssh
├── config
├── include.d/
│   └── proxmox/
│      ├── proxmox
│      ├── proxmox.pub
│      ├── config
```

---

## Why This Matters

This script makes it easy to:

* Improve SSH key security by using **unique keys per server**.
* Keep the `.ssh` directory neat and manageable.
* Simplify connections with one-line `ssh <alias>` commands.

For the full script, visit [GitHub: Streamlining-SSH-Key](https://github.com/richard-sebos/Streamlining-SSH-Key).

