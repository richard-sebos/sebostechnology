---
title:  Secure ROS 2 (SROS2)
published: false
description: 
tags: 
# cover_image: https://direct_url_to_image.jpg
# Use a ratio of 100:42 for best results.
# published_at: 2025-04-14 11:35 +0000
---

- In the last post, the firewall was setup and `$PROGRAMMER_LAPTOP_IP` IP was setup to be able to SSH to the robot
- But a robot is made up nodes like base controller, camera, scanner, and movement devices just to name a few.
- How do we secure how they talk to one another.


## SROS2
- SROS2 add a level of security by using OpenSSL to encrypt what is being between nodes.
- SROS2 create keystore directory that store
    - A Certificate Authority (CA)
    - Each node's:
        - Public certificate
        - Private key
        - Signed permissions file 
- This allows the diffferent nodes to talk to each other in a secure way.

## 📜 Script Overview: `sros2_setup()`

This script is a Bash function intended to **initialize a Secure ROS 2 (SROS2) keystore and create permissions for a node named `talker`**. It is designed to be run on a Linux system with ROS 2 installed and assumes a user and workspace environment have been defined in an external script (`common.sh`).

### 🔗 Dependencies
The script sources an external file:
```bash
source ./common.sh
```
> This likely defines variables like `$ROS_USER`, `$ROS_DISTRO`, and `$ROS_WS`.

---

## 🛠️ Function: `sros2_setup`

### 1. **Install OpenSSL**
```bash
apt install -y openssl
```
- Ensures `openssl` is installed. Required for cryptographic operations during key and certificate generation.

---

### 2. **Run Setup Commands as ROS User**
```bash
sudo -u "$ROS_USER" bash -c '...'
```
- Switches to the ROS user environment to avoid running ROS setup tasks as root.

Inside this block:

#### a. **Source the ROS 2 Environment**
```bash
source /opt/ros/$ROS_DISTRO/setup.bash
```

#### b. **Create the SROS2 Keystore Directory**
```bash
mkdir -p $ROS_WS/sros2_keystore
```

#### c. **Generate the Keystore and Keys for the `talker` Node**
```bash
ros2 security create_keystore $ROS_WS/sros2_keystore
ros2 security create_key $ROS_WS/sros2_keystore talker
```
- Initializes a keystore and generates a key pair for the `talker` node.

#### d. **Create Permissions XML**
The following block creates an XML file that defines the security permissions for the `talker` node:

```xml
<permissions>
  <grant name="talker_grant" subject_name="CN=talker">
    <validity>
      <not_before>2024-01-01T00:00:00</not_before>
      <not_after>2026-01-01T00:00:00</not_after>
    </validity>
    <allow rule="ALLOW">
      <domains>
        <id>0</id>
      </domains>
      <topics>
        <topic>*</topic>
      </topics>
      <partitions>
        <partition>*</partition>
      </partitions>
    </allow>
  </grant>
</permissions>
```
- **Grants permission** to the `talker` node with:
  - Validity from Jan 1, 2024 to Jan 1, 2026.
  - Access to **domain ID 0**, all topics, and all partitions.

#### e. **Create the Signed Permission File**
```bash
ros2 security create_permission $ROS_WS/sros2_keystore talker
```
- Signs the XML using the CA and places it in the proper location for use by the DDS security layer.

---

## ✅ Summary

This function:
- Prepares a secure ROS 2 workspace.
- Generates a keystore and cryptographic identity for a node (`talker`).
- Creates and applies access control rules.
- Ensures compliance with DDS-Security as used in ROS 2.
