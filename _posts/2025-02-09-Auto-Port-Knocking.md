---
title: Automate Port Knocking with Dynamic Port Rotation for Secure SSH Access
date: 2025-02-09 12:03 +0000
categories: [SSH, Auth Keys]
tags: [DevOps, CyberSecurity, SSH, EthicalHacking]
---


## **Introduction**  

Now that you have **Port Knocking** configured, let’s take it a step further! Instead of using a **static knocking sequence**, we will **automatically rotate** knock ports **daily** using a **systemd timer and service**.  

This enhances security by making it nearly **impossible for attackers to guess the correct knock sequence**.  

# **Table of Contents**  

1. [Introduction](#introduction)  
2. [Creating the Port Rotation Script](#creating-the-port-rotation-script)  
3. [Setting Up a Systemd Timer](#setting-up-a-systemd-timer)  
   - [Create the Service File](#create-the-service-file)  
   - [Create the Timer File](#create-the-timer-file)  
4. [Enabling the Timer](#enabling-the-timer)  
5. [Client-Side Implementation](#client-side-implementation)  
6. [Enhancing Security with Additional Measures](#enhancing-security-with-additional-measures)  
7. [Conclusion](#conclusion)  

📌 **Read Part 1: [Setting Up Port Knocking for Secure SSH Access](https://dev.to/sebos/ssh-security-boost-implementing-port-knocking-to-block-unauthorized-access-1n1n)**  

### Part of the [Ethical Hacking Robot Project](https://dev.to/sebos/hacking-robot-needed-raspberry-pi-need-not-apply-49l6)
---

## **1. Creating the Port Rotation Script**  

Create `/usr/local/bin/update_knockd_ports.sh` and add the following:  

```bash
#!/bin/bash
# Define paths
KNOCKD_MAIN_CONF="/etc/knockd.conf"
PORT_FILE="/etc/knockd_ports"

# Generate 3 unique random ports (2000-65000)
NEW_PORTS=$(shuf -i 2000-65000 -n 3 | tr '\n' ',' | sed 's/,$//')

# Store new ports
echo "$NEW_PORTS" > "$PORT_FILE"

# Update knockd configuration
cat <<EOF > "$KNOCKD_MAIN_CONF"
[options]
    UseSyslog
[openSSH]
    sequence = $NEW_PORTS
    seq_timeout = 5
    command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn
[closeSSH]
    sequence    = $(echo $NEW_PORTS | awk '{print $3","$2","$1}')
    seq_timeout = 5
    command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn
EOF

# Restart knockd to apply changes
systemctl restart knockd

# Secure files
chmod 600 "$PORT_FILE" "$KNOCKD_MAIN_CONF"
scp "$PORT_FILE" user@client-ip:~/.
echo "Knockd ports updated: $NEW_PORTS"
```  

---

## **2. Setting Up a Systemd Timer**  

### **Create the Service File**  

`/etc/systemd/system/knockd-rotate.service`  

```ini
[Unit]
Description=Rotate Knockd Ports
After=network.target

[Service]
ExecStart=/usr/local/bin/update_knockd_ports.sh
```

### **Create the Timer File**  

`/etc/systemd/system/knockd-rotate.timer`  

```ini
[Unit]
Description=Schedule Knockd Port Rotation

[Timer]
OnCalendar=*-*-* 00:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

---

## **3. Enabling the Timer**  

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now knockd-rotate.timer
```  

Check if the timer is running:  

```bash
systemctl list-timers --all
```  

---

## **4. Client-Side Implementation**  

To automate knocking from the client side, we can create a script, `/usr/local/bin/knock_server.sh`, that takes either **lock** or **unlock** as an argument to control SSH access.  

#### **Client Script: `/usr/local/bin/knock_server.sh`**  

```bash
#!/bin/bash

KNOCK_FILE="$HOME/knockd_ports"
KNOCK_SERVER="192.168.178.18"  # Change to your server's hostname or IP
SSH_PORT=22  # SSH port to check

# Read and convert the knock sequence (replace commas with spaces)
KNOCK_SEQUENCE=$(cat "$KNOCK_FILE" | tr ',' ' ')


# Determine the action
case "$1" in
    unlock)
        if is_ssh_open; then
            echo "SSH is already unlocked on $KNOCK_SERVER. No need to knock."
        else
            echo "Knocking to unlock on $KNOCK_SERVER with sequence: $KNOCK_SEQUENCE"
            knock -v "$KNOCK_SERVER" $KNOCK_SEQUENCE
        fi
        ;;
    lock)
        REVERSED_SEQUENCE=$(echo "$KNOCK_SEQUENCE" | awk '{for(i=NF; i>0; i--) printf $i" "; print ""}')
        echo "Knocking to lock on $KNOCK_SERVER with sequence: $REVERSED_SEQUENCE"
        knock -v "$KNOCK_SERVER" $REVERSED_SEQUENCE
        ;;
    *)
        echo "Error: Invalid state. Use 'unlock' or 'lock'."
        exit 1
        ;;
esac
```

This script:  
✅ **Reads the latest knock sequence** from `~/knockd_ports` (which the server updates)  
✅ **Unlocks SSH access** with the correct port knock sequence  
✅ **Locks SSH access** with the reverse sequence  

**Usage:**  
```bash
./knock_server.sh unlock  # Open SSH access  
./knock_server.sh lock    # Close SSH access  
```

---

## **5. Enhancing Security with Additional Measures**  

While Port Knocking is a powerful security feature, it should be combined with other security measures for a **truly hardened SSH setup**:  

- **SSH Key Authentication** – Disable password-based logins and use SSH keys.  
- **Fail2Ban** – Prevent brute-force attacks by banning repeated failed login attempts.  
- **Multi-Factor Authentication (MFA)** – Add an extra layer of security for SSH logins.  

---

[Code and config files available here](https://github.com/richard-sebos/Ethical-Hacking-Robot/blob/main/SSH/knockd_readme.md)  

---

## **Conclusion**  

By **automating Port Knocking**, you’ve created an **ultra-secure SSH access system** that dynamically **changes its lock combination** daily!  

🚀 **Next Steps:** Experiment with different automation intervals and explore additional SSH hardening techniques!  




