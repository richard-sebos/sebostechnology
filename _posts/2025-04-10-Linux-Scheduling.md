---
title: Level Up Your Linux Scheduling
date: 2024-10-14 17:59 +0000
categories: [Linux, DEVOPS]
tags: [Linux, systemd, scheduling, devops]
---

![Linux Scheduler Banner](assets/images/LinuxScheduling.png)
## An Intro to systemd Timers

When I first began using Linux, **crontab** was the go-to tool for scheduling tasks on Unix and Linux systems. Its flexibility in a single line of text was impressive, allowing you to create highly specific schedules. For instance, if you wanted a task to run on the 15th of each month at 5:45 am but only on Mondays, crontab could handle it effortlessly with the simple format: `45 5 15 * 1`, followed by your task command. In 2010, however, **systemd** emerged, it offering an alternative method for scheduling tasks, adding new capabilities to Linux systems.

- [Level Up Your Linux Scheduling: An Intro to systemd Timers](#level-up-your-linux-scheduling-an-intro-to-systemd-timers)
  - [What is systemd](#what-is-systemd)
  - [Difference between systemd and crontab](#difference-between-systemd-and-crontab)
  - [Times File](#times-file)
  - [Service File](#service-file)
  - [Scheduling  Timer](#scheduling--timer)


## What is systemd
**Systemd** is a service management tool that takes over once the boot process is complete, initiating and managing essential processes during system startup and throughout runtime. One of its key features is the ability to schedule tasks, similar to what crontab offers, but with additional capabilities and greater flexibility for system administrators.

## Difference between systemd and crontab

One fundamental difference between cron jobs and systemd timers is how the scheduled tasks are managed. With cron, tasks are user-specific, and identifying which user scheduled a particular job isn't always straightforward. In contrast, systemd clearly defines the user who will run a service within the **[Service]** section of the service file. 

## Times File
To schedule a process with **systemd**, you'll need two configuration files: a **timer** file and a **service** file. The timer file defines when a process will run and follows the same initialization (INI) file format as most systemd files, organized into sections. 

  - The first section, **[Unit]**
    -  describes what the process will do and may contain sequencing conditions to ensure that required processes are running before this one starts. 
 -  Next, the **[Timer]** section 
    -  specifies when the systemd process should run. This section includes functions similar to crontab, 
    -  but with additional options such as `OnBootSec=15min`, which starts the process 15 minutes after boot. 
    -  If the timer and service files have different names, the service can be referenced directly in this section. 
 - Finally, the **[Install]** section 
   - provides options for additional configurations, such as ensuring the process starts on boot or specifying the target runlevel.

## Service File
To start a process or daemon service with **systemd**, you create a **service file**. Like the timer file, the service file is organized into three main sections: **[Unit]**, **[Install]**, and **[Service]**. 
  - The **[Unit]** and **[Install]** sections function similarly to those in the timer file, handling descriptions and installation options. 
  - The **[Service]** section, however, is where the main task is defined.

Below is an example **[Service]** configuration for running an Ansible script that performs system updates:

```
[Service]
# Service call to perform updates
User=ansible_admin
WorkingDirectory=/opt/ansible/projects/
ExecStart=/usr/bin/ansible-playbook ansible_update.yml
```

This setup specifies the following:
- The **User** directive determines which user the service runs as.
- **WorkingDirectory** defines the startup directory for the process.
- **ExecStart** calls the Ansible script.
All that is needed is to start the schedule.

## Scheduling  Timer
To start and manage timers, **systemd** uses the `systemctl` command to enable, start, or disable timers. For instance, to enable and start a timer immediately, you would use:

```
systemctl enable --now <service_timer.timer>
```

You can view all scheduled timers with `systemctl --list-timers`, which displays timers currently set to run.

For the code and configuration of the systemd timer and service created to run an Ansible script for Linux updates, see [this code example](https://github.com/richard-sebos/ansible_updates.git) and read the article [here](https://dev.to/sebos/automating-server-updates-30hi).

This article provided a high-level overview of using systemd timers, though systemd offers a wide range of powerful options beyond what we've covered here.


When I first heard about systemd timers, I questioned the need to change such a reliable task scheduler as crontab. However, after experiencing systemd timers, I've become a true convert.

Have you started using systemd timers to schedule tasks? If not, what scheduling tool are you currently using?
