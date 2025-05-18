---
title: Reproducible and Scalable VM Cloning on Proxmox-Ansible to the Rescue!
date: 2024-11-10 16:21 +0000
categories: [Linux, DEVOPS]
tags: [homelab, vm, ansible, automation]
---


Since my teens, I've been fascinated with computers, starting with classics like the Tandy TRS-80 Pocket Computer. That curiosity evolved over the years into a passion for creating and experimenting with virtual machines (VMs). To streamline the process and reduce repetitive tasks, I developed an Ansible setup to automate VM cloning on Proxmox. This guide walks through how to do the same, making VM cloning easier, faster, and more efficient for any level of user. 

## Server to Clone
To streamline the cloning process, I keep a minimal install of Oracle Linux available, specifically set up as a "clone-ready" VM. Normally, this VM stays powered off to save resources, so the first step in cloning is to start it up. Below is an example of an Ansible task to start a Proxmox VM, with sensitive credentials (like `api_host`, `api_user`, and `api_password`) securely stored in an Ansible vault:

```yaml
tasks:
  - name: Start the VM
    community.general.proxmox_kvm:
      api_host: "{{ api_host }}"           # Your Proxmox server IP
      api_user: "{{ api_user }}"           # Accessing variables securely from the vault
      api_password: "{{ api_password }}"
      api_validate_certs: false
      node: "pensask"                      # Specify your Proxmox node name
      vmid: 120                            # VM ID to start
      state: started                       # Set VM state to 'started'
    delegate_to: localhost
```

> **Note:** To run this playbook, ensure the `proxmoxer` and `requests` Python packages are installed using `pip`.

With the VM running, I can proceed to update it. For more on automating server updates with Ansible, check out [this guide on Dev.to](https://dev.to/sebos/automating-server-updates-30hi). Once updated, I'll stop the VM with a similar Ansible task before starting the cloning process.


## Cloning a VM in Proxmox

Cloning a VM in Proxmox with Ansible is a straightforward extension of the same start/stop code used earlier. The main change is to replace the `state` attribute with cloning-specific attributes. Here's an example:

```yaml
      clone: Oracle9master.sebostech       # Source VM name to clone
      name: NewClone                       # Name for the new VM
      pool: CyberSecurity                  # Target pool for the cloned VM
      full: true                           # Use 'true' for a full clone
```

> **Note:** You can find the complete set of Ansible scripts [here](https://github.com/richard-sebos/ansible_clone.git).

Once the Ansible code is executed, a new VM named `NewClone` will appear in your Proxmox VE.

### Why Use This Approach?

At first glance, using Ansible for VM cloning might seem like overkill, especially when a few clicks in the Proxmox web interface can achieve the same result. However, with just a few more Ansible scripts, you can take this automation further.

The beauty of this approach is its repeatability and scalability. The same script used to create a development server can be repurposed to deploy a production server with consistent, reliable results. Plus, it's easily extendable, allowing you to customize additional types of servers as needed-stay tuned for more on that!

What steps are you taking to automate your VM environment?