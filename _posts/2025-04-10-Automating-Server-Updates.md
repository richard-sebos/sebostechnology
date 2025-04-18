---
title: Automating Server Updates
date: 2024-10-14 17:59 +0000
categories: [ProxoxVE, Cybersecurity]
tags: [ansible, devops, Linux, cybersecurity]
---

# A Simple Yet Scalable Approach


Regular OS patching is a crucial part of maintaining cybersecurity, as it helps reduce the risk of zero-day vulnerabilities and other security issues by ensuring that patches are applied soon after they're released. However, when updates aren't automated, it leaves a window where vulnerabilities remain active, making the decision to automate or not a difficult one. In my home lab, I work with a variety of operating systems, each using different update methods, which makes finding a scalable patching solution increasingly important as my lab expands. This is why I've decided to use Ansible for managing updates—let me explain why it's the right tool for the job.

**Table of content:**
- [Automating Server Updates: A Simple Yet Scalable Approach](#automating-server-updates-a-simple-yet-scalable-approach)
  - [Understanding Ansible](#understanding-ansible)
  - [The Update Tasks](#the-update-tasks)
  - [What User Will Run the Tasks](#what-user-will-run-the-tasks)
  - [Where to Run the Playbook](#where-to-run-the-playbook)


## Understanding Ansible
Ansible is a powerful automation tool that simplifies repetitive tasks and system management. For a more in-depth overview, [click here](https://dev.to/sebos/getting-started-with-ansible-automation-meets-cybersecurity-48el). At its core, Ansible uses Playbooks to execute one or more tasks in sequence. Each task typically consists of a name, a module, arguments for that module, and—when it comes to updates—certain conditions to determine when the task should run. While Ansible offers many other advanced features, we’ll be focusing on this basic structure for now.


## The Update Tasks

In my home lab, I’m working with three different operating systems: two Linux distributions and one FreeBSD system. To handle updates for all of them, the Ansible Playbook needs to include tasks tailored to each OS. For Red Hat-based distributions like RHEL, CentOS, Rocky, and Oracle, I use the `yum` module. Debian-based systems, such as Ubuntu and Mint, require the `apt` module, and for FreeBSD, the `pkgng` module does the job. Thankfully, Ansible has built-in modules for all of these package managers, making it easy to manage updates across different platforms.

Here’s how the Playbook is structured:

```yaml
  tasks:
    # Task to update RedHat family servers (RHEL, CentOS, Rocky, Oracle)
    - name: Update RHEL family servers, including RHEL, CentOS, Rocky, Oracle...
      yum:
        name: '*'                   # Update all packages
        security: yes               # Apply security updates
        state: latest               # Ensure packages are at their latest version
      when: ansible_facts['os_family'] == 'RedHat'  # Run only on RedHat family systems

    # Task to update Debian family servers by refreshing package cache
    - name: Update Debian family servers
      apt:
        update_cache: yes           # Refresh the APT package cache
      when: ansible_facts['os_family'] == 'Debian'  # Run only on Debian family systems

    # Block to handle updates for OPNsense (FreeBSD-based system)
    - block:
        # Task to check for available updates on OPNsense
        - name: Check for updates on OPNsense
          ansible.builtin.shell: "opnsense-update -c"
          register: update_check     # Register output for conditional check
          changed_when: false        # Mark as not changed (no need to record as a change)
          ignore_errors: true        # Continue playbook if this command fails

        # Task to apply updates if updates are available
        - name: Update OPNsense if updates are available
          ansible.builtin.shell: "opnsense-update -u && opnsense-update -bk"
          when:
            - ansible_facts['os_family'] == 'FreeBSD'  # Run only on FreeBSD systems (OPNsense)
            - update_check.stdout != ""                # Ensure updates are available before proceeding
          register: update_result                      # Register result for reboot condition

        # Task to reboot OPNsense after updates
        - name: Reboot OPNsense to apply updates
          ansible.builtin.shell: "reboot"
          async: 1                                     # Run asynchronously to allow reboot
          poll: 0                                      # Detach from task immediately
          when:
            - ansible_facts['os_family'] == 'FreeBSD'  # Run only on FreeBSD systems (OPNsense)
            - update_result is defined                 # Ensure update task has a result
            - update_check.stdout != ""                # Check if updates were available
          ignore_errors: true                          # Continue playbook if reboot task fails

      when: ansible_facts['os_family'] == 'FreeBSD'    # Apply this block only on FreeBSD systems

```

Now that we know what needs to be done, the next step is figuring out under which user or permissions we’ll be executing these tasks.


## What User Will Run the Tasks

The next step is determining which user the tasks in the Playbook will run as on the remote servers. In my setup, I've already created an Ansible user on each of the remote servers, so we'll be using that user to execute the tasks.

```yaml
  become: root
  become: yes
  remote_user: ansible_admin
```

> **Note:** The `ansible_admin` user was set up in a previous article, which you can check out [here](https://dev.to/sebos/getting-started-with-ansible-automation-meets-cybersecurity-48el).

Now that we have the user sorted, the final step is deciding where to run the Playbook.

## Where to Run the Playbook

The final piece of the puzzle is deciding which servers the tasks will run on. This is defined in the Ansible hosts file, which lists all the servers to be managed. In my home lab, the Playbook runs across all servers.

```yaml
- name: Update servers in my home lab
  hosts: all
```

In a corporate environment, you would typically follow a more structured patching strategy, rolling out updates in stages. For more information on corporate patching strategies, you can learn more [here](https://dev.to/sebos/crafting-a-balanced-patching-strategy-2na).

With the Ansible Playbook in place, the next step is to set up a systemd timer to schedule the job, ensuring my servers are consistently kept up to date. While there may be cases where a reboot is necessary after applying updates, that will be addressed in a future project.

You can find the complete code for this article [here](https://github.com/richard-sebos/ansible_updates.git), including the systemd timer setup to automate the Playbook execution.

How do you manage patching to keep your servers up to date?
