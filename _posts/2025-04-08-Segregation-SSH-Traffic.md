---
title: Segregation SSH Traffic
date: 2024-09-08 20:48 +0000
categories: [ssh, cybersecurity]
tags: [ssh traffic, segregation, cybersecurity] 
---

# Segregation SSH Traffic
**Controlling access to SSH services is crucial** for maintaining a secure environment, and the ability to search logs for troubleshooting and security concerns is just as critical.

Many tools, like **Ansible, rsync, Terraform,** and **Docker**, generate SSH traffic as part of their operations. Segregating this traffic by using different SSH ports for various services can simplify managing:

- firewall rules,
- monitoring,
- and logging.

Let’s explore what it takes to move Ansible’s SSH traffic to a dedicated port, ensuring smoother and more secure operations.

## SSH Match Statement

To segregate SSH traffic, we need to use **conditional login** rules in the SSH configuration file. The `Match` directive allows you to apply specific settings based on various conditions.

You can use the `Match` command to define settings based on:

- **Match User:** The SSH user's username.
- **Match Group:** The SSH user's group.
- **Match Address:** The client’s IP address or subnet.
- **Match Host:** The client’s hostname (resolved by DNS).
- **Match LocalAddress:** The server's local IP address.
- **Match LocalPort:** The port the SSH server is listening on.
- **Match RemoteAddress:** The client’s remote IP address.
- **Match RemotePort:** The client’s remote port.

In my case, I wanted to split the traffic, so regular SSH user traffic would be on **port 22**, while **Ansible** traffic would run on **port 2222**. To achieve this, I used the `Match LocalPort` directive.

## Splitting the SSH Config File

To better manage and segregate SSH traffic, I split the SSH configuration into three parts:

1. The **main `sshd_config` file**, which contains the common directives shared across both configurations (example provided below).
2. A **separate configuration for regular user traffic**, containing additional directives specific to user connections.
3. A **dedicated configuration for Ansible traffic**, also with its own set of directives.

One key difference between these configurations could be logging. For example, you might set **low logging levels** for Ansible to generate fewer log entries, while keeping **high logging levels** for user traffic to enable easier debugging in case of issues.

## Splitting the SSH Config File

To better manage and segregate SSH traffic, I split the SSH configuration into three parts:

1. The **main `sshd_config` file**, which contains the common directives shared across both configurations (example provided below).
2. A **separate configuration for regular user traffic**, containing additional directives specific to user connections.
3. A **dedicated configuration for Ansible traffic**, also with its own set of directives.

One key difference between these configurations could be logging. For example, you might set **low logging levels** for Ansible to generate fewer log entries, while keeping **high logging levels** for user traffic to enable easier debugging in case of issues.

## Ansible Traffic

I moved the Ansible traffic to **port 2222** using the `Match LocalPort 2222` directive and configured it as follows:

- Granted access only to specific ansible users connecting from the **Ansible controller's IP address**.
- Set **logging** to capture errors only, reducing unnecessary log entries.
- Decreased the time between **keep-alive checks** to ensure consistent connectivity.
- Increased the number of concurrent **SSH sessions** that can be opened at once, optimizing Ansible's performance.

Next, we’ll take a look at how the configuration differs for regular users.


## Traffic on Port 22

To handle the rest of the traffic, I configured a `Match LocalPort 22` directive with the following settings:

- Allowed connections only for the **ssh-user group**, which contains the list of users permitted to access via SSH.
- Increased the time between **keep-alive checks** while reducing the number of unanswered keep-alives allowed.
- Set the logging level to **INFO** for more detailed logging of user activity.
- Limited the number of concurrent connections per user to enhance security.


By segregating SSH traffic using different ports and custom configurations, you can gain greater control over your server environment. Whether it's fine-tuning logging, managing connection limits, or tailoring firewall rules, this approach ensures that your critical tools like Ansible, alongside regular user traffic, run smoothly and securely. Taking the time to implement this type of SSH traffic management can improve both performance and security, while also simplifying troubleshooting and monitoring.

As you continue to scale your infrastructure, applying these strategies will help you maintain a more organized and secure system, tailored to meet your specific needs.

I’d love to hear how do you segregation SSH Traffic?

Below are the SSH config files

>SSH Config File:Ansible Traffic (51-ansible_admin.conf)
```
Match LocalPort 2222


    ## Limit SSH Access to Specific Users
    AllowUsers ansible_admin@192.168.167.17
    DenyGroups ssh-users

    ## Mitigate hanging or idle connections
    ClientAliveInterval 60
    ClientAliveCountMax 3

    ## Log Level
    LogLevel ERROR

    ## Limit Concurrent Sessions increased for Ansible
    MaxSessions 10
                
```

>SSH Config File:User Traffic (55-ssh-user.conf)
```
Match LocalPort 22


    ## Only users in the ssh-users group
    AllowGroups ssh-users

    # Mitigate hanging or idle connections
    ClientAliveInterval 300
    ClientAliveCountMax 0


    ## Log Level
    LogLevel INFO

    ## Limit Concurrent Sessions
    MaxSessions 10
```
> SSH Config File:sshd_config
```
## Strong SSH Key Algorithms
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512,hmac-sha2-256

PubkeyAcceptedKeyTypes ssh-rsa-cert-v01@openssh.com,ssh-ed25519

## Disable ssh protocol 1
Protocol 2

Port 22
Port 2222

## Restrict Root
PermitRootLogin no

## Restrict Auth Key location
AuthorizedKeysFile /home/%u/.ssh/authorized_keys

## Disable Password Logins
PasswordAuthentication no
PermitEmptyPasswords no

## Disable Unused Authentication Methods
GSSAPIAuthentication no
ChallengeResponseAuthentication no

## Connection setting
MaxAuthTries 3
LoginGraceTime 30s


## Disable SSH Tunneling and Forwarding 
AllowAgentForwarding no
PermitTunnel no
X11Forwarding no

## Add Port base config
Include /etc/ssh/sshd_config.d/51-ansible_admin.conf
Include /etc/ssh/sshd_config.d/55-ssh-user.conf
```
