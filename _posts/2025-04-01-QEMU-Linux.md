---
title: How to Use QEMU to Run Linux VMs in Minutes
date: 2025-04-01 14:39 +0000
categories: [linux, virtualization, sysadmin, devops]
tags: [linux, virtualization, sysadmin, devops]
---

If you read my last post, you’ll remember we explored QEMU from a high-level perspective. Today, let’s roll up our sleeves and dive into how you can quickly get a Linux VM up and running using QEMU. We'll cover both graphical and console-based virtual machines, using **Kali Linux** and **Fedora Server** as examples. Once QEMU is installed, you can have a fully functional Linux VM within minutes.

> ✅ [Install QEMU](https://www.qemu.org/download/) if you haven't already.

---

## Table of Contents
1. [Running Kali Linux with GUI in QEMU](#running-kali-linux-with-gui-in-qemu)
2. [QEMU Command Breakdown (Kali)](#qemu-command-breakdown-kali)
3. [Running Fedora Server in Console Mode](#running-fedora-server-in-console-mode)
4. [QEMU Command Breakdown (Fedora)](#qemu-command-breakdown-fedora)
5. [Why Use QCOW2 Images?](#why-use-qcow2-images)
6. [Final Thoughts](#final-thoughts)

---

## Running Kali Linux with GUI in QEMU

Kali Linux is one of the most well-known distributions in the cybersecurity world—loved by blue teamers, pen-testers, and hackers alike. While you might be familiar with the live ISO, there's also a maintained **QEMU-ready version** of Kali that makes spinning up a VM super easy.

Once you've downloaded the QEMU `.qcow2` image of Kali, you can launch it with a few simple options. Here's a typical configuration I use for GUI-based Kali setups:

- **4 GB RAM**
- **2 virtual CPUs**
- **Virtual hard drive (QCOW2)**
- **NAT networking**
- **Virtio networking for better performance**
- **Graphical window with visible cursor**
- **Custom name: “Kali VM”**

This setup is ideal for local penetration testing labs or blue team sandboxing.

---

## QEMU Command Breakdown (Kali)

### **Run Kali Linux GUI:**
```bash
qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -hda kali-linux-2025.1a-qemu-amd64.qcow2 \
  -cpu max \
  -display default,show-cursor=on \
  -device virtio-net,netdev=net0 -netdev user,id=net0 \
  -name "Kali VM"
```

### **Explanation of Options:**
- `qemu-system-x86_64`: Launch QEMU for 64-bit x86 systems.
- `-m 4096`: Assigns 4 GB of RAM.
- `-smp 2`: Enables 2 virtual CPU cores.
- `-hda`: Mounts the Kali `.qcow2` disk image as the primary drive.
- `-cpu max`: Uses all available host CPU features for better guest performance.
- `-display default,show-cursor=on`: Opens a graphical window with visible mouse cursor.
- `-device virtio-net,netdev=net0`: Adds a fast virtual NIC using virtio.
- `-netdev user,id=net0`: Enables NAT (user-mode networking).
- `-name`: Gives the VM a name for identification.

📥 [Download Kali Linux QEMU image](https://www.kali.org/get-kali/#kali-virtual-machines)

---

## Running Fedora Server in Console Mode

While GUIs are great, sometimes you just want to get straight into the terminal—especially on servers. Running QEMU in **console mode** is resource-efficient and better suited for headless setups or SSH-based management.

Fedora offers pre-built `.qcow2` images that work perfectly with this style of virtualization. Here’s a minimal setup I use:

- **4 GB RAM**
- **2 CPU cores**
- **Max CPU feature exposure**
- **QCOW2 virtual drive**
- **No graphical interface**
- **Console and QEMU monitor output to terminal**

---

## QEMU Command Breakdown (Fedora)

### **Run Fedora Server Console:**
```bash
qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -cpu max \
  -hda Fedora-Server-KVM-41-1.4.x86_64.qcow2 \
  -nographic \
  -serial mon:stdio
```

### **Explanation of Options:**
- qemu-system-x86_64: Launches QEMU with 64-bit x86 emulation.

- -m 4096: Allocates **4 GB of RAM** to the VM.

- -smp 2: Uses **2 virtual CPUs**.

- -cpu max: Enables **all CPU features** available to the host for optimal performance in the guest.

- -hda Fedora-Server-KVM-41-1.4.x86_64.qcow2: Uses this **QCOW2 disk image** (Fedora Server) as the main virtual hard drive.

- -nographic: **Disables the graphical display** (no window will pop up), and instead routes VM output to the terminal. Ideal for **server environments** or SSH-only VMs.

- -serial mon:stdio: Redirects the **serial console and QEMU monitor** to your **terminal** (STDIO), so you interact with the VM as if it were a headless physical server via serial console.

📥 [Download Fedora Server QEMU image](https://fedoraproject.org/server/download)

---

## Why Use QCOW2 Images?

The `.qcow2` format is incredibly convenient—it’s a pre-installed, ready-to-boot Linux environment in a single file. Unlike Live ISOs, changes to the system are **persistent**, which is ideal for testing and development.

> ⚠️ Note: These images might include default user credentials. Make sure to change the password or, better yet, create your own user immediately after boot.

QCOW2 images are perfect for:
- Rapid Linux prototyping
- Security testing environments
- Script and automation testing
- Isolated lab setups

---

## Final Thoughts

Whether you're prototyping, testing scripts, or building a home lab, QEMU with ready-made QCOW2 images is a powerful and fast way to get Linux up and running. In just a few minutes, you can launch a GUI-driven Kali instance or a lean Fedora Server terminal—all without touching VirtualBox or VMware.

> If you could get **any Linux distro** running in just a couple of minutes, what would you use it for?

Have questions about Linux or virtualization? Drop a comment or reach out—always happy to chat!



