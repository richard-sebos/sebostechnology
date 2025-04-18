---
title: SSH Through Firewall
date: 2024-08-25 15:40 +0000
categories: [ProxoxVE, Cybersecurity]
tags: [SSH, Security, Proxy Jump, Network,Hardening, Best Practices]
---

# Proxmox Security Series:SSH Through Firewall

In my effort to find fresh ways to improve SSH security beyond the usual tips and tricks, I looked into using the OPNsense firewall—something I already had—as a gateway for my Proxmox server. The idea was to make this firewall the main entry point for server access. This setup simplifies access but also means that if the firewall has issues, everything does. Although it was an interesting idea, I was initially unsure about how much it would really enhance security. Stay tuned as I dive deeper into this later in the article.


## SSH Authentication Keys

Prior to implementing the firewall adjustments, I generated two SSH keys: one for the connection to the firewall and another for the Proxmox server.

```bash
## Auth Keys for Proxmox Server
ssh-keygen -t ed25519 -f ~/.ssh/pve  

## Auth Keys for OPNsense Firewall
ssh-keygen -t ed25519 -f ~/.ssh/firewall
```

I admit that using two different keys might seem a bit much, and really, one key is usually enough. But I was curious—could using two separate keys actually make things more secure? I saw this as a chance to test out that idea.


## Firewall Modifications for SSH

Configuring the firewall for SSH was straightforward and could be managed entirely through the web interface. Keep in mind that different firewalls offer varying features, so the following is a high-level description of the adjustments I made:

- SSH was enabled on the LAN interface exclusively.
- Root user login was disabled to enhance security.
- Password-based login was disabled, requiring more secure authentication methods.
- A new user account was created, which required administrative privileges for SSH access.
- I selected the preferred shell for the user.
- The SSH authentication key was uploaded to ensure secure access.

These changes successfully enabled SSH access to the firewall, setting the stage for more secure operations.

## SSH Jump Command

SSH includes a useful `-J` switch, which allows routing through a jump server.

```bash
## SSH Jump Command
ssh -J <firewall_user_id>@<firewall_ip_address> <pve_user_id>@<pve_ip_address>
```

As you begin to integrate options like authentication keys, the command can become cluttered. This is where the `.ssh/config` file becomes invaluable. It allows users to assign aliases to SSH servers and specify options for each connection. For environments with multiple servers, the file can become complex. Using include files within the `.ssh/config` can help manage this complexity, keeping configurations organized and maintainable.


## Configuring SSH with .ssh/config

To streamline SSH commands using configuration files, you can create specific config files for each server, like so:

**Config File Name: firewall**
```
# Configuration file for firewall
Host firewall
    HostName 192.168.166.1
    User sebos
    IdentityFile ~/.ssh/firewall
```

**Config File Name: pve**
```
# Configuration file for Proxmox VE
Include ~/.ssh/include.d/firewall
Host pve
    HostName 192.168.167.127
    User richard
    ProxyJump firewall
    IdentityFile ~/.ssh/pve
```

**Changes to: ~/.ssh/config**
```
Include ~/.ssh/include.d/firewall
Include ~/.ssh/include.d/pve
```

With these configurations in place, connecting to your Proxmox server via the firewall jump host simplifies to a single command:
```bash
ssh pve
```

> **Note:**
>
> Storing additional configuration files in the `~/.ssh/include.d/` directory isn't mandatory but helps maintain organization and clarity in your SSH setup.
>


## Did It Enhance Security?

My assessment is affirmative. The setup resulted in some interesting outcomes:
- The Proxmox server can no longer be directly accessed via SSH without routing through the jump server—a predicted but significant tightening of security.
- Surprisingly, even from the firewall’s shell, I was unable to initiate an SSH connection to the Proxmox server.

To successfully access the Proxmox server through SSH, the following conditions must be met:
- Physical presence within my LAN network.
- Possession of both sets of my SSH keys.
- Knowledge of the user IDs and server IP addresses, though the `.ssh/config` file simplifies this aspect.

Would I extend this setup to my WiFi or WAN network? Potentially, yes—if I stored my configuration files and authentication keys within an encrypted directory secured by a password, I would consider it feasible and safe to do so.

Here’s a simpler version for a general audience:

Would I create two authentication key files again in the future? Yes, but only if I planned to store them in different places, like one on my local machine and the other on a network share within my own network.

## Can This Stop All Hackers?

No security system is perfect. Highly skilled hackers can find vulnerabilities, including Zero Day exploits, in any system. The best strategy is to minimize potential entry points and add layers of security to discourage most attackers.

I’d love to hear about your methods. How do you secure SSH in your network?