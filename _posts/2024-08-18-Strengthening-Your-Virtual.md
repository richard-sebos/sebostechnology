---
title: Strengthening Your Virtual Environment
date: 2024-08-18 12:27 +0000
categories: [ProxoxVE, Cybersecurity]
tags: [proxmox, vm, servers, security]
---
## Proxmox:Baby steps to Increase Security

Proxmox is an open-source virtual environment tool for creating and managing virtual machines and containers. Currently a niche solution in a growing market, Proxmox is  used  by companies and educational institutions as an alternative to VMware ESXi, Proxmox offers robust features at a lower to no cost.  However, since it is built on a Linux system, additional security measures are necessary to protect your environment.

One crucial aspect of securing Proxmox is controlling who has access and what actions they can perform, such as starting, stopping, deleting, or modifying virtual machines. In this series of articles, I will guide you through a series of steps to add layers of security to your Proxmox server.

We'll start with the simpler tasks, gradually moving to more advanced security configurations. In this first article, we'll focus on creating and managing user permissions within Proxmox to ensure that only authorized personnel can access and control your virtual environment.

## Proxmox Users

To get started, we'll create a few users based on their specific needs. These users will be set up with Proxmox VE authentication server logins:

- **Bob**:  
  Bob is the Proxmox Administrator for multiple teams. He is responsible for creating, maintaining, and backing up virtual servers, as well as managing the Proxmox server itself.

- **Betty**:  
  Betty works on external-facing web pages. She needs to monitor the status of the servers and occasionally use the web console for her tasks.

- **Jim**:  
  Jim focuses on internal-facing web pages. Like Betty, he needs to check the status of the servers and occasionally access the web console.

- **Nancy**:  
  Nancy is the Team Manager for the Web Programmers. Betty and Jim report to her when there are issues with the virtual servers. While she has the ability to reboot the VMs, she contacts Bob if more significant action is required.

![Proxmox Users](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/onfdxm0rz6ac6cmjmkol.png)

> **Note**: The permissions discussed in this article are for  accessing Proxmox, not the operating systems of the virtual machines themselves.

## Proxmox Pools

One of the powerful features in Proxmox is the ability to organize VMs into Pools, essentially creating groups of VMs based on their function or purpose. In our example, we’ll create two sets of VMs:

- **ExtWebSer**:  
  This pool will contain external web servers.

- **IntWebSer**:  
  This pool will contain internal web servers.
![Proxmox Pools](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yoezqu2uat0lvenmmbaw.png)

In this setup, 

- **Nancy and Betty:**:  
  Will be assigned to the **ExtWebSer** pool

- **Nancy and JIM:**:  
  Will be assigned to the **IntWebSer** pool 

## Proxmox Privileges and Roles

Proxmox uses roles to assign a set of predefined privileges to users or groups. These roles are  fixed but can be customized by creating additional roles based on the available privileges. We’ll apply these roles to our users based on their specific needs.

- **Bob**:  
  Bob is assigned the **Administrator** role, which is a predefined role with comprehensive privileges.

- **Betty and Jim**:  
  Betty and Jim are assigned a new role called **WebDev**, which includes the privileges **Mapping.Audit** **VM.Audit**, VM.Console**, and **VM.Monitor**. This role is tailored to their needs for monitoring and occasional access.

- **Nancy**:  
  Nancy is assigned a new role called **WebAppManager**, which includes the privileges **Mapping.Audit**, **VM.Audit**, **VM.Monitor**, and **VM.PowerMgmt**. This role allows her to oversee the web application servers and perform basic management tasks like rebooting VMs.

![Proxmox Roles](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/c9q1necm2quh4outdecw.png)

> **Note**:  Note: A complete listing of Proxmox privileges can be found [here](https://pve.proxmox.com/wiki/User_Management#pveum_permission_management).


To ensure that users with the **WVWebDev** and **WebAppManager** roles can view these pools in Proxmox, the **Pool.Audit** permission must be added to their roles.

## Proxmox Permissions

Proxmox pools created the assocations between user, roles and resources, in our case, pools. Premission defind what access a users has to what resource.

- **Bob**:
    Has access to / (all)  as Adminstrator
- **Betty**:
    Has access to /pool/ExtWebSer as WVWebDev
- **Jim**:
    Has access to /pool/IntWebSer as WVWebDev
- **Nancy**:
    Has access to /pool/ExtWebSer as WebAppManager
    Has access to /pool/IntWebSer as WebAppManager

![Proxmox Permissions](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/90o2ekz9hitofg586h9f.png)

## Why Do This?

In a larger organization, there could be tens or even hundreds of VMs. The teams managing these VMs, along with the critical applications running on them, need appropriate access to perform their duties. By restricting access based on roles and pools, you can secure critical servers, such as those used for HR, strategic planning, and accounting, as well as others ensuring that only authorized personnel have access.

## What the users see

- **Betty** 
![Betty's Pools](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ps7c9kd83bqfzb715bkg.png)

- **Jim** 
![Jim's Pools](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/izettwani1ul9vhq7q3e.png)

- **Nancy**
![Nancy's Pools](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yjuhszwdofi58fwnh5q7.png)

In the next article, we will explore how to restrict root access on the Proxmox server itself, adding another layer of security to your environment.

I hope you found this article valuable, and I appreciate the time you took to read it. If you have any questions or suggestions, please feel free to reach out. When it comes to securing a virtual host, what steps would you consider taking?
