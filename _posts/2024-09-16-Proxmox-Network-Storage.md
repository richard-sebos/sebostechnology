---
title: Proxmox Network Storages
date: 2024-09-16 01:11 +0000
categories: [Proxmox, Samba]
tags: [proxmox, NAS, storage] 
---

When I imagine the future of my home lab, I envision it filled with professional-grade equipment—a sleek server rack, servers humming away, and network switches blinking behind a perforated door. However, like many enthusiasts, my current setup is a bit more modest, made up of a mix of end-of-life workstations and desktops.

But that's part of the fun, right? Taking bits and pieces of hardware and transforming them into something practical and useful. That’s the beauty of a home lab.

In this article series, I’ll walk you through how I built a Network Attached Storage (NAS) solution using a DAC (Direct Access Storage) and a Single Board Computer (SBC). While this may not be the most conventional approach, it was certainly a fun and rewarding experience!


## The SBC NAS

At its core, a NAS (Network Attached Storage) is simply a device that shares storage across a network. For my setup, I had an Orange Pi 5 Pro that I’d been experimenting with, and since it features two network interfaces, it was a perfect candidate for the NAS device to connect to the DAC.

One network interface would serve Proxmox, acting as the NAS for my virtual environment, while the other would be dedicated to my personal media storage. I set up the Orange Pi with a headless Debian server and connected it to the DAC, using Samba to share the storage across the network.

And just like that, I had something that was *almost* a fully functional NAS!


## To Bridge or Not to Bridge

The Orange Pi 5 Pro comes with two network interfaces, and when I first envisioned this project, I considered bridging them. However, bridging the two would essentially connect two subnets that are normally separated by a firewall, bypassing that isolation.

This led to an important question: did I really want to bridge these two networks on a Debian SBC? After weighing the pros and cons, I had to carefully consider whether merging these networks would compromise the structure and security of my home lab.


## Security Concerns with the Bridge

Although my home lab isn’t a production-level environment, I try to approach it with the same security considerations. By bridging the networks, I realized a couple of important access concerns:

- **From a Proxmox and personal device perspective**, bridging effectively gave both access to the NAS.
- **From a NAS perspective**, it now had access not only to the Proxmox server and VMs running on it, but also to any personal devices I use to access media.

This raised a significant question: was I compromising security by bridging these networks?

In my next post, I’ll walk through the steps I took to secure access to the NAS and maintain proper isolation.


> /etc/samba/smb.conf
>
```
[global]
    workgroup = sebos
    log file = /var/log/samba/smb.log
    max log size = 10000
    log level = 1
    server string = sebos nas %v
    security = user
    min protocol = SMB2

    # Include additional configuration files
[media]
    include = /etc/samba/smb.d/media.conf
[pve]
    include = /etc/samba/smb.d/pve.conf

```

> /etc/samba/smb.d/media.conf
>
```
    comment = home media server
    path = /srv/nas_storage/media
    browseable = yes
    writable = yes
    guest ok = no
    create mask = 0664
    directory mask = 0775
    force user = samba_media
    force group = samba_admin_media
    valid users = samba_media
```

> /etc/samba/smb.d/pve.conf
>
```
    comment = pve storage
    path = /srv/nas_storage/pve
    browseable = yes
    writable = yes
    guest ok = no
    create mask = 0664
    directory mask = 0775
    force user = samba_pve
    force group = samba_admin_pve
    valid users = samba_pve
```