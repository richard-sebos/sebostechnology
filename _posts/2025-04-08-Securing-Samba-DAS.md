---
title: Proxmox NAS Storage - Securing a Samba DAS
date: 2024-09-29 21:22 +0000
categories: [Proxomx, NAS, Samba]
tags: [samba, cybersecurity, NAS,linux] 
---

With the network and firewall rules configured, there are just a few final tasks to complete on the Samba server:

- Enhance Samba security
- Mount the DAS volumes on the server

While this may seem redundant given the firewall settings, the next step adds an extra layer of protection. We’ll limit access to the Samba server by specifying allowed hosts directly in the Samba configuration file. This ensures that only designated servers can connect, further tightening security.


### Finalizing Samba Security

When we first set up the Samba server, we configured allowed users and set the minimum SMB protocol. Now, it’s time to finish securing the server by restricting which computers can access it using the `hosts allow` directive in the Samba configuration.

Here’s how I’ve set up host access control:

> Proxmox Share the Samba config file:

```
# 192.168.177.129 - Proxmox Backup Server
# 192.168.177.7 - Proxmox Server Management Port
# 192.168.178.0/24 - Proxmox VM Netork
# This also keeps my laptops off this share 192.168.166.0/24
hosts allow = 192.168.177.129 192.168.177.7  192.168.178.0/24
```
This configuration ensures that only the necessary servers can access the Samba pbe share. It also prevents my personal laptop, which are on the **192.168.166.0/24** subnet, from accessing these shares.


> Media Share the Samba config file:

```
## 192.168.168.0/24 - Allow device on WI-FI to access media
## 192.168.166.66 - Allow personal desktop but stop work laptop access
## Proxmox server do not have access
 hosts allow = 192.168.168.0/24 192.168.166.66
```


This configuration ensures that only the Wi-Fi devices can access the Samba media share, while also allowing my personal laptop to share access to the media.

Now, let’s move on to mounting the DAS volumes and securing them.

### Mounting DAS Drives

The DAS has five bays, and two of the drives are being mounted for Samba use. Since these drives were previously used on a Linux server and already contain data, there's no need for partitioning or formatting.

#### Information Needed to Mount the Drives

To mount a drive on a Linux system using the `/etc/fstab` file, you’ll need the following details:

- **What is being mounted** – The device name or UUID of the drive
- **Where it is being mounted** – The target directory (mount point)
- **File system type** – The type of file system (e.g., ext4, xfs)
- **Mount options** – Specific options for mounting (e.g., defaults, noatime)
- **Dump** – Whether the filesystem should be backed up by the `dump` command
- **Pass** – The order in which filesystems should be checked by `fsck` (file system check)

To mount the drives correctly, I needed to gather some essential information, such as the UUID and file system type (FSTYPE) of the drives. Here's how I did it:

#### Identifying the Drives and File System Types

I used the `lsblk` (list block devices) command to display the hard drives and their details, including the UUID and file system type. Here’s an example of the output:

```
lsblk -f  # returns the following
NAME         FSTYPE FSVER LABEL    UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda                                                                                    
sdb                                                                                    
sdc                                                                                    
sdd                                                                                    
└─sdd1       ext4   1.0            3208c81f-0714-42bb-a8fc-adfbfc4ca336                
sde                                                                                    
└─sde1       ext4   1.0            65a350ce-4548-4ef1-86bb-e48965924224 
```

> **Note:** This project uses UUIDs instead of device names for added stability and security.
>
> Drives can be mounted using either the device name (e.g., `/dev/sdd1`) or the UUID (e.g., `3208c81f-0714-42bb-a8fc-adfbfc4ca336`). However, device names are assigned at boot and can change if new disks or partitions are added or removed. 
>
> The UUID, on the other hand, is a unique identifier assigned to a partition and only changes when the partition is recreated. This ensures that even if partitions or disks are added or removed, the UUID remains the same.
>
> Additionally, using the UUID ensures that if a drive is removed from the DAS and replaced with a different one, the system will not automatically load the new drive. While this adds a layer of security, it also means that the system won’t support hotswapping drives without further configuration.


### Setting Up Mount Point Options

Now, let’s configure the options for the mount points. Since this system will be used as storage for a NAS and is non-production, I’ve opted for security over performance. After reviewing the available options, the following settings seem to fit the requirements:

- **atime**: Ensures file access timestamps are updated. This can improve security by tracking file access but may impact performance in some cases.
- **noexec**: Prevents the execution of binaries on this mount, adding an extra layer of security.
- **nodev**: Disallows the creation or usage of device files, which enhances security on the storage volume.
- **errors=remount-ro**: If any errors are detected on the filesystem, this option automatically remounts the filesystem as read-only, preventing further issues.

Finally, the seutp for dump and pass



### Configuring Dump and Pass

Since the `dump` command is not installed on the server, I’ve set the dump value to `0`, meaning the filesystem will not be included in backup routines via `dump`.

For the `pass` value, I’ve chosen to set it to `2`, which ensures that the mounted filesystems will be checked during boot. While this will slightly slow down the boot process, it’s acceptable for a back-end system that isn’t rebooted frequently.

The possible values for `pass` are:

- **0**: Do not check the filesystem at boot.
- **1**: Check the filesystem first, typically used for the root (`/`) filesystem.
- **2**: Check the filesystem after the root filesystem has been checked.


### Updating the fstab File

During boot, Linux systems reference the `/etc/fstab` file to mount additional hard drives. To finalize this project, let’s bring everything together and add the appropriate entries to the `fstab` file.

Here’s how we’ll define the lines based on the information we’ve gathered:

```
## From DAS bay 1
UUID=3208c81f-0714-42bb-a8fc-adfbfc4ca336 /srv/nas_storage/media ext4 atime,atime,nodev,noexec,errors=remount-ro 0 0

## From DAS bay 2
UUID=65a350ce-4548-4ef1-86bb-e48965924224 /srv/nas_storage/pve ext4  atime,nodev,noexec,commit=600,errors=remount-ro 0 0
```

With all the changes in place, I rebooted the server and tested the mounts—they all worked perfectly.

Looking back, if I were to do this again, I might choose a different device than the Orange Pi 5 Pro. The version of Debian available for it doesn't support Logical Volume Manager (LVM), which would have allowed me to combine the hard drives into a single large logical volume for better storage flexibility.

While the initial NAS setup took a few steps, adding additional shared folders in the future will be much simpler.

If you had a NAS, how would you use it?

