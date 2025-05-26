
- In the last article we restricted access to the user account richard so it could be used as a jump account
- Now we need a security to stop admin SSH access.
- What if you could use a security tool developed by the NSA to secure Linux server
- A tool that not only can protect your system from melisous action to also define file protection level at an enterprise level
- What if that tool was free to use and srutimized to the Open Source commitity to ensure it was safe from goverments trying to use it to hack your devices
- would you use it?


## SELinux
- SELinux is that tool RHEL base distro
- There are two types of secure tools that work, ones that work behind the sense and ones that you alway see to bump into
-SELinux is the bump into kind for good reason
- Want to change the default Samba shared folders, SELinux needs to know
- Want to change the default port on SSH, SELinux needs to know
- It is suprising how many debug instruction suggest turn off SELinux and test again
- So why leave it on

## Is SELinux Really Need
- Yes, it is a great tools and I always fight when vendor or application developers want it turn off.
> SELinux is:
>
>SELinux (Security-Enhanced Linux) is a mandatory access control (MAC) system built into the Linux kernel. It enforces strict rules about which users, processes, and services can access which files, ports, and system resources, beyond traditional Linux permissions.

>Developed by the NSA and maintained by the open-source community, SELinux uses a label-based policy model that defines exactly what actions are allowed—even for root.
- In this article, I am going to use the SELinux boolean `ssh_sysadm_login` to disable users in the wheel group from login in as `SSH`

> SELinux booleans are configuration flags that enable or disable specific permissions within SELinux policies, allowing you to adjust system behavior without modifying the full policy.
- the good news, it is easy to set up

## SELinux Booleans

**SELinux booleans** are settings that let you turn specific SELinux rules on or off without changing the whole policy. They're useful for quickly adjusting security behavior for services like Apache, FTP, or Samba.

### Example

To let Apache make network connections:

```bash
setsebool -P httpd_can_network_connect on
```

### Commands

* **View all booleans**: `getsebool -a`
* **Change a boolean**: `setsebool -P <boolean_name> on|off`

### Why Use Them?

* Easy way to tweak SELinux without deep policy edits
* Quick fixes for access issues caused by SELinux
* Useful for enabling common service features safely


## Restrict Admin from SSH Login
- The first step is to ensure SELinux is running 
```bash
## check  if SELinux is in enforce mode
getenforce.  ## Return the mode 
Enforcing

## or for more information
sestatus. ## Returns the below
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
##
sudo dnf install -y policycoreutils selinux-policy-targeted policycoreutils-python-utils

```
- if it not enforced
```
sudo setenforce 1
```

- `SELinux` allows you to setup user contexts.
- I am going to add`sysadm_u` context rchamberlain 

```bash
sudo semanage login -a -s sysadm_u rchamberlain
```

- Now it is as simple as turning `ssh_sysadm_login` to stop users from login using `SSH`
```bash
## stop admin from login through ssh
sudo setsebool -P ssh_sysadm_login off
sudo getsebool ssh_sysadm_login. ## returns
ssh_sysadm_login --> off
```

- If the admin account now restricted from SSH by SELinux and have a retricted jump user that allows us to login as jump to our admin accounts, we add a layer to protect the admin accounts
-  Add the SSH Auth Key, Fail2ban and 2FA you have a solid entry point for SSH users
