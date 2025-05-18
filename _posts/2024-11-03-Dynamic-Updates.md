---
title: Dynamic Risk-Based Updates Using Python and Excel
date: 2024-11-03 16:21 +0000
categories: [Linux, DEVOPS]
tags: [python, Ansible, Linux, Cybersecurity]
---

*Learn how to elevate your Ansible update strategy by creating a dynamic, risk-based inventory using Excel 📊 and Python 🐍. This article walks you through replacing static hosts files with a flexible, easy-to-maintain setup that prioritizes updates based on risk levels ⚠️-keeping your patching process efficient and adaptable 🚀.*

In this blog, we'll take a simple Ansible server update script and turn it into a **Risk-Based Update System**. Here, servers with the lowest risk get patched first, giving us a chance to test thoroughly before moving on to higher-priority systems.

- [Ansible Automation:](#ansible-automation)
  - [Dynamic Risk-Based Updates Using Python and Excel"](#dynamic-risk-based-updates-using-python-and-excel)
  - [Host File](#host-file)
  - [Dynamic Host List](#dynamic-host-list)
  - [Why Not Use a Hosts File?](#why-not-use-a-hosts-file)


The secret sauce? Setting up well-defined groups to make this flow seamlessly. But the real question is: can we pull this off without major changes to our Ansible script from last time? Let's find out! 

## Host File

The host file is at the heart of this change. In the last post, we used a static file grouped by server types. Now, we're adding a second layer of grouping by risk level-which does add some complexity to the host file.

But here's the twist: what if our host file could be dynamically generated from a more generic source? That would keep things flexible and save us from endless file editing!

## Dynamic Host List

Ansible can work with dynamically created host files, which gives us a more flexible way to keep track of servers. In this example, we'll use an Excel file to organize our hosts.

**Example `hosts_data.xlsx` Structure:**

| Host Name      | Server Environment | Ansible User   | Server Type | DNS                        | Notes                                      |
|:--------------:|:------------------:|:--------------:|:-----------:|:--------------------------:|:------------------------------------------:|
| mint           | dev                | richard        | desktop     | desktop.sebostech.LOCAL    | Mint desk top                              |
| ansible_node   | dev                | ansible_admin  | Ansible     | ansible_node.sebostech.local | Development server; Only updates monthly   |
| clone_master   | dev                | ansible_admin  | clone       | clone.dev.sebostech.local  | Development server; Only updates monthly   |
| mele           | staging            | richard        | nas         | nas.stage.sebostech.local  | Testing server; Used for application testing |
| pbs            | production         | root           | backup server | pbs.prod.sebostech.local  | Testing server; Used for application testing |
| pve            | production         | root           | hypervisor  | api.stage.sebostech.local  | Testing server; Used for application testing |
| samba          | production         | richard        | nas         | nas.prod.sebostech.local   | Critical server; Requires daily backup     |
| firewall       | production         | richard        | firewall    | firewall.sebostech.local   | Critical server; Requires daily backup     |



Most IT departments already have a list of servers stashed in an Excel file, so why not put it to good use? This approach makes it easy to keep our Ansible hosts organized and up-to-date without constant manual updates. 

But how does Ansible use the Excel file? Let's dive into how we can transform this data into a usable dynamic inventory!

```bash
## This will run agains all host
ansible-playbook -i dynamic_inventory.py playbook.yml
```

You can also use  `environment variables` option to target specific groups, based on `Server Environment`, `Server Type`, or even a combination of both:

```bash
## Just production
SERVER_ENVIRONMENT="production" 
ansible-playbook -i dynamic_inventory.py playbook.yml --limit "high:web"

## Just nas
SERVER_TYPE="nas" 
ansible-playbook -i dynamic_inventory.py playbook.yml --limit "high:web"

## production nas
SERVER_ENVIRONMENT="production" 
SERVER_TYPE="nas" 
ansible-playbook -i dynamic_inventory.py playbook.yml --limit "high:web"

```

Need new groups? Just update the Excel file and adjust the Python script accordingly-easy as that!

For a look at the Python code, see [here](https://github.com/richard-sebos/DynamicRisk-BasedUpdates.git).

## Why Not Use a Hosts File?

When I first started using Ansible, the hosts file was my go-to. But as I added more servers, especially ones with dual roles, that file got more and more complex.

Could you use a traditional hosts file to achieve this? Sure-but there are a few drawbacks.

With a hosts file, you'd likely end up with duplicate entries or additional variables to capture all the structure you need. An Excel file, on the other hand, provides a clean, easy-to-maintain structure that keeps things organized.

 In a corporate environment, there's a good chance there's already at least one Excel file with a server list, so why not take advantage of it?

If you'd like me to dive deeper into the Python code, just let me know!
