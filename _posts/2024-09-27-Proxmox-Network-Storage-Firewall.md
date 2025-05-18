---
title: Proxmox Network Storage Firewall Rules
date: 2024-09-27 01:41 +0000
categories: [Proxmox, Firewall]
tags: [proxmox, NAS, storage,Firewall] 
---


# Proxmox Network Storage

So far, we've utilized a Direct Attached Storage (DAS) and a Single Board Computer (SBC) to set up a NAS (Network Attached Storage) using Samba. The next step was securing the NAS by placing it on a dedicated VLAN subnet, isolating it from other devices in my home lab. This setup effectively reduces the attack surface and limits exposure to only the systems that need access. Now, we’ll focus on configuring firewall rules to ensure secure communication between the authorized devices and the NAS.


## Firewall Aliases

When setting up firewall rules, you're assigning permissions for devices to access other devices. This can be done by specifying attributes such as MAC addresses, IP addresses, ports, and Fully Qualified Domain Names (FQDNs). However, managing these values, especially MAC addresses or IPs, can become cumbersome and difficult to remember after creating the rules.

For example, the dock for my MacBook Air has the MAC address `3A:2C:4F:5E:8B:1A`. Instead of trying to remember that, I can create an alias called `macbookair_dock` on the firewall. Now, whenever I use `macbookair_dock` in my firewall configuration, the system will recognize it as the corresponding MAC address `3A:2C:4F:5E:8B:1A`, making it easier to manage.

For this project, I’ve created the following aliases:

|Alias| Type|Value|
|-----|-----------|-----------|
|macbookair_dock|MAC address|3A:2C:4F:5E:8B:1A|
|iPad |MAC address|F2:77:3C:6D:1E:82
|iPhone|MAC address|09:AF:BA:63:92:4E|
|ProxmoxVE | Host(s)| 192.168.177.7,192.168.177.8|
|ProxmoxBS| Host(s)|192.168.177.129|
|SambaPorts|Port(s)|137,138,139,445|
|SambaPve|Host(s)|192.168.197.7|
|SambaMedia|Host(s)|192.168.198.8|



With these aliases in place, the firewall rules we create in the next section will be much clearer and easier to manage.


> **Note: MAC vs Hosts**  
> The servers on my network have static IP addresses, so using IP address would work well for them. However, many other devices do not have static IPs, making their IP addresses less reliable for identification. In these cases, using the MAC address (Media Access Control address) provides a more consistent and stable way to reference those devices.

## Proxmox Servers to NAS

The Proxmox servers will be utilizing the NAS for two main purposes:  
- ISO storage  
- Backups  

To enable this, the following firewall rules were necessary:

|#|Interface|Source|Destination|Ports|
|-|--------------|-----------|--------|----------|
|1|VLANforProxmox|ProxmoxVE  |SambaPve|SambaPorts|
|2|VLANforProxmox|ProxmoxBS  |SambaPve|SambaPorts|


### Rule 1: 
This rule permits the Proxmox servers to store ISO images on the NAS and ensures that virtual machines (VMs) can access the necessary storage resources for proper operation.

### Rule 2:  
This rule enables the Proxmox Backup Server to securely store backups on the NAS, ensuring that data is protected and recoverable as needed.

## Virtual Servers to NAS

The virtual servers will use the NAS for shared storage. To facilitate this, the following firewall rules are required:

|#|Interface|Source|Destination|Ports|
|-|--------------|-----------|--------|----------|
|1|VLANforProxmoxVM|ProxmoxVE  |SambaPve|SambaPorts|



## WiFi to Media

This setup allows my iPhone and iPad to access documents and media stored on the NAS. The following firewall rules were implemented to ensure secure access:

Since access was not granted to the entire WiFi subnet, any additional users connecting to the WiFi network will not have access to the files on the shared NAS. This ensures a higher level of security by restricting access to only authorized devices.

At this point, the Samba service has been installed, the VLANs are configured, and the firewall rules are in place. In the next article, I will cover mounting external hard drives and configuring Samba to further restrict access to the shared resources.


