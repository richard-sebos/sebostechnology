---
title: Implementing VLANs for Proxom and NAS
date: 2024-09-22 23:56 +0000
categories: [ProxoxVE, Cybersecurity, NAS]
tags: [proxmox, nas, VLAN, security]
---
**Proxmox: Network for NAS**

In the previous post, we completed the Samba server setup, though the network connection strategy was still in development. Now, it’s time to explore how the Samba server will be integrated into the network to fulfill various roles:

- **Proxmox VE/Backup Server (BS):** Providing dedicated storage for backups and ISO images
- **Proxmox VMs:** Enabling shared storage for virtual machines in the Proxmox environment
- **Personal Use:** Serving as a central hub for managing documents and media

In this post, I'll guide you through setting up the network for this homemade NAS, ensuring it's ready to meet the needs of both your Proxmox environment and personal use.



## Bridging vs. VLAN

When setting up the Samba server, I had two network cards at my disposal. Initially, I considered bridging the connections, with one card linked to the Proxmox network and the other connected to WiFi. However, I wanted to isolate the networks for better security, but I ran into a limitation—there weren’t enough physical ports.

That’s where VLANs came in.

Between the two options, VLANs offered a more secure and scalable solution. Ultimately, I chose VLANs to segment and secure the network effectively.



## VLAN

The simplest way to understand VLANs is to think of them as virtual networks that share the same physical network interface but remain logically separated. Through a process called "tagging," VLANs add an identifier to each network packet, ensuring that data is routed only to the devices within the same VLAN. This isolation boosts security and improves traffic management, especially in environments with multiple devices and different access requirements.

In my case, I created two VLANs on two of the four LAN ports on my firewall to segment the traffic:

- **VLAN Tagging:** Each network packet is tagged with a VLAN ID, ensuring it stays within its designated network, preventing interference with other VLANs.
- **Improved Security and Control:** VLANs allow me to separate traffic, ensuring that my Proxmox network, personal devices, and other systems are isolated from each other. This limits access and reduces the risk of unauthorized traffic.
- **Efficient Use of Hardware:** Instead of needing multiple physical network interfaces for each network, VLANs enable me to use a single interface to handle multiple networks, maximizing the efficiency of my existing hardware.

Here’s how I set up VLANs in my configuration:

## Network Isolation

To enhance the security and organization of my Proxmox servers and NAS, I created four VLANs on my OPNsense firewall to ensure each component of the infrastructure is properly isolated:

- **VLAN 10 - Proxmox Management**
  - Used for accessing the Proxmox web interface
  - Handles backup traffic between Proxmox VE and Proxmox Backup Server
- **VLAN 20 - Proxmox VMs**
  - A dedicated subnet for virtual machines
- **VLAN 30 - NAS for Personal Use**
  - Designed for managing personal documents and media
- **VLAN 40 - NAS for Proxmox**
  - Reserved for backups and ISO storage
  - Used by VMs to access common files

With these VLANs in place, I ensured that each type of traffic is isolated, improving both security and performance. The next step was configuring the servers to access their respective VLANs.


## Configuring the Physical Servers

Next, I configured the Proxmox VE, Proxmox Backup Server (BS), and Orange Pi 5 Pro to use the VLANs. Interestingly, while all of these systems are based on Debian, the configuration process differed for each.

### Proxmox Backup Server (BS)

Proxmox Backup Server was the simplest to configure since it only required a single connection to the NAS for storing backups. The VLAN setup was straightforward, as it primarily handled backup traffic without any complex routing needs.

```
auto lo
iface lo inet loopback

# Management network (VLAN 10, 192.168.177.0/24)
auto eno1.10
iface eno1.10 inet static
    address 192.168.177.129
    netmask 255.255.255.0
    gateway 192.168.177.1
    vlan-raw-device eno1
```
> This configure the backup server to use VLAN 10
>


### Orange Pi NAS

Since the Orange Pi 5 Pro has two network interfaces, I had a few options for configuring the VLANs:

- **Option 1:** Set up VLANs on one network card and dedicate the other for administrative access.
- **Option 2:** Create a redundant network setup using both interfaces for failover and load balancing.
- **Option 3:** Separate the VLANs across both network cards, which is the approach I chose.

This setup allows for better network segmentation and isolation between traffic types. Below are the configuration files I used to implement this setup:

> 10-enP3p49s0.network
```
[Match]
Name=enP3p49s0

[Network]
VLAN=vlan30

```

> 10-enP4p65s0.network
```
[Match]
Name=enP4p65s0

[Network]
VLAN=vlan40
```

> 20-vlan30.network
```
[Match]
Name=vlan30

[Network]
Address=192.168.198.8/24
Gateway=192.168.198.1
DNS=8.8.8.8 8.8.4.4
```
> 20-vlan30.netdev
```
[NetDev]
Name=vlan30
Kind=vlan

[VLAN]
Id=30
```

> 20-vlan40.network
```
[Match]
Name=vlan40

[Network]
Address=192.168.197.7/24
Gateway=192.168.197.1
DNS=8.8.8.8 8.8.4.4
```
> 20-vlan40.netdev
```
[NetDev]
Name=vlan40
Kind=vlan

[VLAN]
Id=40

```
### Proxmox VE

Similar to the Orange Pi 5 setup, the Proxmox VE server also has two network cards. I decided to separate the VLANs, assigning each VLAN to its own network interface for better isolation and performance. Below is the configuration file for this setup:

```
auto lo
iface lo inet loopback

auto enp11s0
iface enp11s0 inet manual

auto vmbr0
iface vmbr0 inet static
        bridge-ports enp11s0
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094

auto vmbr0.10
iface vmbr0.10 inet static
	address 192.168.177.7/24
	gateway 192.168.177.1

auto ens5
iface ens5 inet manual

auto vmbr1
iface vmbr1 inet static
        bridge-ports ens5
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094

auto vmbr1.20
iface vmbr1.20 inet static
        address 192.168.178.8/24
        gateway 192.168.178.1
```

Now that the Samba server and network setup is complete, in the next post, I’ll be covering the firewall rules that control access to the NAS. These rules will ensure that each system can access the NAS as needed while maintaining proper security and isolation.
