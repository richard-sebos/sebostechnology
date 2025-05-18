---
title: Securing Root Access
date:  2024-08-25 00:35 +0000
categories: [ProxoxVE, Cybersecurity]
tags: [proxmox, vm, servers, security]
---
Continuing our series on securing your Proxmox server, this article focuses on an essential aspect: securing root access. Like many other systems, Proxmox requires an administrator account to perform critical operations, and it uses the Linux root account by default. However, leaving this root access open presents significant security vulnerabilities, such as:

- **Unrestricted access to the web-based root console**
- **Direct root access via SSH**

The good news is that these vulnerabilities are easy to address. Even after implementing these security measures, you'll still retain the necessary root access to manage your Proxmox environment securely.



## Install `sudo`

Before disabling root access, it's crucial to create a new administrative user with restricted privileges. To manage administrative tasks without using the root account, we'll need to install `sudo` on the Proxmox server. You can do this by accessing the server either through the web console as root or by connecting via SSH. First, update the server's packages, then install `sudo` using the following commands:

```bash
# Update the server first
apt update && apt upgrade -y

# Install sudo
apt install sudo
```

With sudo installed, we can create an administrative account.

## Create a New System User

Creating a new user on Linux is straightforward using the `adduser` command. This user will differ from the standard user account (like "bob" we created in a previous article) as it will have administrative privileges rather than just access to the Proxmox web interface. In this example, we’ll create a new user named “Richard” to replace the root user for administrative tasks.

### Steps to Create a New System User

1. **Create the user account**:
   Use the `adduser` command to create a new user with a specified home directory.

   ```bash
   # Create a new user with a home directory
   adduser --home /home/richard richard
   ```

2. **Create a new group for system administrators**:
   If you don’t already have a group for administrative users, you can create one. This group can be used to manage permissions more efficiently.

   ```bash
   # Create a system admin group
   addgroup system-admin
   ```

3. **Grant sudo and group access**:
   Add the new user to the newly created `system-admin` group.
   ```
   # Add the new user to the system admin group
   gpasswd --add richard system-admin
   ```

Next, we will create a custom sudoers file to further secure the server and fine-tune the permissions for our new administrative user.



## Configure the `sudoers` File for Richard

The `sudoers` file allows you to specify which commands a sudo user can execute, providing granular control over administrative permissions. You can create user aliases or assign permissions directly to existing system accounts. Since I often reuse my `sudoers` files across multiple servers, I prefer to use aliases for better management and scalability.

In this section, we'll create a list of command aliases that define what actions Richard can perform and assign these command aliases to his user group.

### Steps to Configure the `sudoers` File

1. **Define user aliases**: First, create a user alias for the `system-admin` group. This makes it easy to manage permissions for all users in this group.

   ```bash
   # Sudoers file for admin
   User_Alias SYSTEM_ADMIN = %system-admin
   ```

2. **Create command aliases**: Define command aliases for specific tasks Richard and other system administrators need to perform. This restricts the commands they can run with `sudo` and enhances security.

   ```bash
   # Allow system updates
   Cmnd_Alias UPDATE_CMDS = /usr/bin/apt update, /usr/bin/apt upgrade

   # Check error logs
   Cmnd_Alias LOG_CMDS = /usr/bin/tail -f /var/log/*, /usr/bin/journalctl, /bin/grep sshd /var/log/auth.log

   # Restricted Vim (rvim) to edit files without dropping to a shell
   Cmnd_Alias RVIM = /usr/bin/rvim
   ```

3. **Assign command aliases to the user group**: Finally, assign these command aliases to the `SYSTEM_ADMIN` user alias. This allows members of the `system_admin` group to run the specified commands without a password prompt.

   ```bash
   SYSTEM_ADMIN ALL=(ALL) NOPASSWD: UPDATE_CMDS, LOG_CMDS, RVIM
   ```

Root access can be restricted now that we have an additional SSH account.

## Restricting Root Access from SSH

Creating an additional user account on the server allows us to restrict root access through SSH while still maintaining SSH access for administrators. To enforce this, we'll use the `ssh-users` group to control who can access the server via SSH. While this might seem like overkill for a Proxmox server with just one user-level account, it's a best practice for securing all servers that use SSH.

### Steps to Restrict Root SSH Access

1. **Create an SSH access group**: First, create a new group named `ssh-users` and add the new administrative user, Richard, to this group.

   ```bash
   # Create an SSH access group
   addgroup ssh-users

   # Add the new user to the SSH access group
   gpasswd --add richard ssh-users
   ```

2. **Edit the SSH configuration file**: Next, edit the SSH daemon configuration file (`sshd_config`) to disable root login and allow only users in the `ssh-users` group to connect via SSH.

   ```bash
   # Disable root login
   PermitRootLogin no

   # Allow only specific groups to access SSH
   AllowGroups ssh-users
   ```

> **Note**: If neither `AllowGroups` nor `AllowUsers` is specified, any new user could potentially access the server through SSH. Defining these parameters helps to restrict access to only those users explicitly allowed.

3. **Restart the SSH service**: To apply these changes, restart the SSH service.

   ```bash
   # Restart SSH service
   systemctl restart sshd
   ```

> Note:
>
>In a future article, we will cover additional steps to further >secure the SSH daemon beyond just restricting root access.

With these SSH security measures in place, we’ve significantly reduced the attack surface by restricting root access and controlling who can access the server. Next, we will focus on restricting access to the Proxmox web shell.


## Add System Admin to Proxmox

The `richard` system account we created earlier does not automatically appear in the Proxmox web interface. To grant the `richard` account administrative access, we need to manually add it as an Administrator within Proxmox.


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/zf53f63qpcwjqkfwjpgk.png)
> Add the richard user to Proxmox


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/61dpdwzy7afell79duq1.png)
> Add administrator the richard

By doing this, Richard will have the necessary permissions to manage all aspects of the Proxmox environment, allowing us to disable the root account safely. Once root is disabled, the server console will require a password for login instead of automatically providing root access.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/v1jxicxhkd7rlzyxkrb1.png)
> password is needed on node web console

### Benefits of Replacing Root with Richard

By configuring Richard as the sole user with SSH access and limiting the commands executable with `sudo`, we've effectively secured SSH access. As Richard has Administrator privileges in Proxmox, any tasks that cannot be performed through SSH can still be handled through the Proxmox web interface.

Additionally, if the web interface is ever unavailable, you can still access the server directly with physical access. This setup ensures robust security while maintaining the flexibility needed to manage the Proxmox environment effectively.
