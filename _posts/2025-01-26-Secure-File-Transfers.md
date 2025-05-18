---
title: Crafting a Balanced Patching Strategy
date: 2025-01-26 22:53 16:21 +0000
categories: [Linux, DEVOPS]
tags: [CommandLine, TechTips, SysAdmin, LinuxTips]
---

SCP (Secure Copy Protocol), much like SSH, is a cornerstone technology for managing remote servers. While SSH enables access to a remote server's command line, SCP extends this functionality by allowing the transfer of files and directories to and from a remote server’s file system. The majority of SCP commands follow a straightforward syntax:

```bash
# Put a file on a remote server
scp <file name> <user>@<remote server>:<path to put file>

# Get a file from a remote server
scp <user>@<remote server>:<file with full path> <where to put it locally>
```

This simple approach is commonly used, but SCP offers a host of additional features that can make it even more versatile.
Here’s a table of contents for your polished article:

## Table of Contents

1. [Introduction](#introduction)
2. [Moving a Directory](#moving-a-directory)
3. [Bandwidth Limiting](#bandwidth-limiting)
4. [Compression](#compression)
5. [Verbose Mode](#verbose-mode)
6. [Ports, Proxies, and SSH Keys](#ports-proxies-and-ssh-keys)
7. [Preserving File Attributes](#preserving-file-attributes)
8. [Conclusion](#conclusion)



Each section heading in the article can be directly linked using the corresponding anchor tags. Let me know if you'd like help formatting the article with these links or making further adjustments!
### Moving a Directory

Sometimes, transferring entire directories—complete with their contents—is necessary. SCP supports this with the `-r` option, which recursively copies entire directories. The commands for this are similarly intuitive:

```bash
# Put a directory and its contents on a remote server
scp -r <directory> <user>@<remote server>:<path to put the directory>

# Get a directory from a remote server
scp -r <user>@<remote server>:<directory with full path> <where to put it locally>
```

### Bandwidth Limiting

A less commonly used but critical feature of SCP is its ability to limit bandwidth usage. This is particularly useful when transferring large files during business hours, as excessive network traffic can degrade performance for others. The `-l` option allows you to specify a bandwidth limit in kilobits per second, which can help mitigate such issues. For example, to limit SCP to 5 Mbps:

```bash
BITS_TO_BYTES=8
KILO_TO_MEGA=1024
SPEED_IN_MEGA=5
scp -l $((${BITS_TO_BYTES}*${KILO_TO_MEGA}*${SPEED_IN_MEGA})) <file name> <user>@<remote server>:<path to put file>
```

Additionally, SCP includes the `-B` option to adjust the buffer size, which determines how much data is read and written in a single operation. The default is 32 KB, but larger sizes can improve performance on high-speed networks, while smaller sizes may be better for low-speed or high-latency networks.

### Compression

If network performance is a concern, compression can also be employed using the `-C` option. This compresses the data during transfer, which can speed up file transfers over slower connections:

```bash
scp -C <file name> <user>@<remote server>:<path to put file>
```

### Verbose Mode

When troubleshooting SCP issues, verbose mode is invaluable. The `-v` option provides detailed output of what SCP is doing, with additional levels of verbosity available using `-vv` or `-vvv`. A common approach to debugging involves first testing connectivity with SSH, as SCP issues are often rooted in SSH configuration problems:

```bash
scp -v <file name> <user>@<remote server>:<path to put file>
```

### Ports, Proxies, and SSH Keys

SCP supports advanced options like specifying a custom port (`-P`), using proxy servers (`-o`), and providing SSH keys (`-i`). While these can be included in the SCP command, a more efficient approach is to define them in your `.ssh/config` file. This simplifies commands, documents your setup for future reference, and applies the same settings to both SCP and SSH. Here’s an example configuration:

```plaintext
Host remote
    HostName remote.example.com
    User myuser
    ProxyJump firewall_jump           ## Proxy server - defined in another SSH config
    Port 2222                         ## Port
    IdentityFile ~/.ssh/keys/auth_key ## SSH keys
```

With this configuration, the SCP command becomes much simpler:

```bash
scp <file name> <remote>:<path to put file>
```

Transferring files between two remote hosts can also benefit from this approach. Define both hosts in your `.ssh/config`, and the SCP command is just as straightforward:

```bash
scp <remote from server>:<file name> <remote to server>:<path to put file>
```

### Preserving File Attributes

When transferring files, preserving attributes such as ownership and permissions can be crucial. The `-p` option ensures these attributes remain intact, making it ideal for tasks like backups, file system migrations, and compliance:

```bash
scp -p <file name> <user>@<remote server>:<path to put file>
```

### Conclusion

This guide covered some of the most useful features of SCP, demonstrating its flexibility beyond basic file transfers. If you need to achieve something not listed here, I recommend checking the manual pages (`man scp`) or reaching out—I’d be happy to help!
