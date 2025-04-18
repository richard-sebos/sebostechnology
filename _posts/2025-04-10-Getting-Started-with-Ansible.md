---
title: Getting Started with Ansible - Automation Meets Cybersecurity
date: 2024-10-14 17:59 +0000
categories: [ProxoxVE, Cybersecurity, Ansible]
tags: [Linux, Ansible, Cybersecurity, Automation]
---

#  Ansible Setup 

In this article, I will walk you through setting up the Ansible Control server.  

In future articles,we will create Ansible playbooks to deploy Zero Trust Access (ZTA) principles across my home lab environment.  

So, what exactly is Ansible?

**Table of content:**
 - [What is Ansible](#item-one)
 - [The Chicken-and-Egg Problem ](#item-two)
 - [Building the Control Server](#item-three)
 - [Getting Hostnames Using Ansible](#item-four)

 <a id="item-one"></a>
## What is Ansible
Ansible is an automation tool used to execute tasks on remote servers. It relies on YAML-formatted files, known as Playbooks, to define these tasks, which are then pushed and executed on the remote servers using SSH.

At its core, a Playbook is a simple list of tasks that are run against a set of servers by a specified user.

 <a id="item-two"></a>
## Where to Start: The Chicken-and-Egg Problem  

Setting up the Ansible Control server with Zero Trust Access (ZTA) in mind requires a few additional steps:  
- Creating a VLAN for the Ansible server  
- Configuring the network settings on the Ansible server  
- Setting firewall rules to allow access  
- Creating and managing users for the Ansible server  
- And a few other tasks along the way  

The big question is: Do I set everything up manually, including ZTA changes, or do I first set up a basic Ansible server and use it to automate the migration to a ZTA model? 

Time to build

 <a id="item-three"></a>
## Building the Control Server  

I have decided to go with the latter approach since it aligns with the philosophy of building cybersecurity into the process from the start. Here is how I set up the Ansible Control server on a fresh installation of Oracle Linux 9.  

### Step 1: Install Ansible on Oracle Linux 9  
First, ensure your system is up to date:  
```
# Check for updates first  
sudo dnf update  
```  

Next, install Ansible:  
```
# Install Ansible  
sudo dnf install ansible  
```  

To confirm the installation, run the following command:  
```
# Test if Ansible is installed  
ansible  
```  

### Step 2: Add an Ansible Admin User  
We need to create an admin user for Ansible:  
```
# Create a user with sudo privileges for Ansible on remote servers
sudo useradd ansible_admin  
```  

### Step 3: Grant Sudo Access to the Ansible User  
To allow the `ansible_admin` user to run commands with sudo privileges without entering a password, we will modify the sudoers file. Depending on the system, hereis where you can find the file:  
- **OPNsense**: `/usr/local/etc/sudoers`  
- **RHEL, Debian**: `/etc/sudoers`  

Add the following line near the bottom of the file:  
```
## Grant sudo access without a password to the Ansible user  
ansible_admin ALL=(ALL) NOPASSWD: ALL  
```  

> **Note:**  
> In the future, I'll be setting up multiple Ansible users with more granular permissions to enhance server security.  

### 4: Create the Ansible Hosts File  
The Ansible hosts file defines the servers you want to manage. There are several places where you can store this file, but I'll use the main configuration:  
```
# Edit the main hosts file  
sudo nano /etc/ansible/hosts  
```  

Below is the content I used for my setup:  
```ini
[firewall]  
# OPNsense Firewall  
Firewall  

[proxmox]  
# Proxmox VE and Backup Server  
PVE  
PBS  

[nas]  
# Orange Pi NAS  
NAS  

[ansible_node]  
# Local Control Node  
control_node  
```  

Now That the Build is Complete, Let's Test It Out  
 <a id="item-four"></a>
## Getting Hostnames Using Ansible  

With Ansible installed and the servers configured, let's test it by running a simple playbook that gathers the hostname and OS type from all the connected servers.  

### Step 1: Create the Ansible Playbook  

1. Start by creating a new file called `system_info.yml`:  
   ```
   nano system_info.yml  
   ```  

2. Add the following lines to the file and save:  
   ```yaml
   ---  
   - name: Gather hostname and OS type from all hosts  
     hosts: all  
     gather_facts: yes  
     tasks:  
       - name: Get hostname and OS type  
         ansible.builtin.debug:  
           msg: "Host: {{ ansible_hostname }}, OS: {{ ansible_os_family }}"  
   ```  

### Step 2: Run the Playbook  

To execute the playbook, use the following command:  
```
ansible-playbook system_info.yml  
```  

### Step 3: Review the Output  

Ansible can be quite verbose, but the key part of the output will look like this:  
```
TASK [Get hostname and OS type] **********************************************************************************************************************************************
ok: [firewall] => {  
    "msg": "Host: firewall, OS: FreeBSD"  
}  
ok: [pve] => {  
    "msg": "Host: pensask, OS: Debian"  
}  
ok: [pbs] => {  
    "msg": "Host: bkp1, OS: Debian"  
}  
ok: [ansible] => {  
    "msg": "Host: stock, OS: RedHat"  
}  
ok: [samba] => {  
    "msg": "Host: orangepi5plus, OS: Debian"  
}  
```  

### Step 4: Final Thoughts  

Some of the hostnames could use a bit of work, but no worries-Ansible can help streamline those details later. This playbook confirms that the servers are reachable and that Ansible is properly configured to gather system information from all the hosts.

With Ansible up and running, the next step is to start adding additional layers of security to the remote servers using Ansible. Stay tuned-there's more to come!

Ansible is a powerful automation tool that simplifies complex tasks, making server management more efficient.  If you had an automation tool like Ansible, what tasks would you automate?