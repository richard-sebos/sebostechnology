---
title: Enhancing Code Reusability in Robotics - A Modular WiFi Scanner with ROS2 & Systemd
date: 2025-02-26 20:39 +0000
categories: [Linux, Robotics, Sysadmin, Devops]
tags: [linux, robotics, ros2, devops]
---

When exploring robotics and automation, it's easy to find demonstration code that blends system-generated logic with user-defined logic. While these demos are great for learning, they often lack the structured approach needed for real-world applications. As someone with a background in coding, the concept of **Separation of Duty** has been ingrained in me. This principle ensures that different components of a system remain modular, making them easier to maintain, extend, and reuse.  

In this article, we’ll apply this principle by designing a **WiFi Scanner** that:  
- **Scans for available WiFi networks**  
- **Saves results to a database**  
- **Provides multiple ways to execute the scan** (direct execution, systemd automation, and ROS2 integration)  
## **Table of Contents**  
- [**Code Reusability: A Practical Approach with ROS2, Systemd, and Python**](#code-reusability-a-practical-approach-with-ros2-systemd-and-python)
  - [**Table of Contents**](#table-of-contents)
  - [**Understanding Code Reusability in ROS2**](#understanding-code-reusability-in-ros2)
  - [**Building a WiFi Scanner in Python**](#building-a-wifi-scanner-in-python)
  - [**Automating with Systemd Timers and Services**](#automating-with-systemd-timers-and-services)
    - [**Systemd Service**](#systemd-service)
    - [**Systemd Timer**](#systemd-timer)
  - [**Integrating with ROS2**](#integrating-with-ros2)
    - [**Why Use ROS2?**](#why-use-ros2)
    - [**Creating a ROS2 Topic**](#creating-a-ros2-topic)
  - [**Conclusion: The Power of Separation of Duty**](#conclusion-the-power-of-separation-of-duty)

---
By the end, we'll have a **single Python-based WiFi scanner** that can be accessed in multiple ways while keeping the core logic separate.  

---

## **Understanding Code Reusability in ROS2**  
Code reusability means writing code in a way that it can be used in different parts of a system without modification. In ROS2, this means keeping system-level and user-level logic separate, making the code easier to maintain and extend.  

Let’s focus on creating a reusable core and exposing it through multiple interfaces. This approach allows:  
- Direct execution for quick testing  
- Automation with **Systemd timers and services**  
- Integration with **ROS2 Topics** for robotic applications  

Let’s begin by developing our core functionality in Python.  

---

## **Building a WiFi Scanner in Python**  
To test our separation of duties, we first create a Python script that:  
1. Scans for available WiFi networks  
2. Saves the results to a database  
3. Provides a script to trigger the scan  

Here's how we can directly execute the scanner:  

```bash
python3 -m save_wifi_scan.py
```
[find code here](https://github.com/richard-sebos/Ethical-Hacking-Robot/tree/main/networking/wifi_scanner/scanner)

This allows system users  **ad hoc WiFi scans** as needed. With this foundation in place, let’s explore how to automate this process using systemd.  

---

## **Automating with Systemd Timers and Services**  
Instead of manually running the script, we can create a **systemd service** to execute it automatically at regular intervals.  

### **Systemd Service**  
The service acts as a wrapper around our Python script:  

```ini
# wifi_scan.service
[Unit]
Description=WiFi Scanner Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/robot/wifi_scanner
ExecStart=python3 /opt/robot/wifi_scanner/save_wifi_scan.py
Restart=always
RestartSec=10
```

### **Systemd Timer**  
To execute the service at fixed intervals, we configure a timer:  

```ini
# wifi_scan.timer
[Unit]
Description=Run WiFi Scanner every 30 seconds

[Timer]
OnBootSec=10
OnUnitActiveSec=30
Unit=wifi_scan.service

[Install]
WantedBy=timers.target
```

Now, enabling the timer ensures the scan runs automatically every **30 seconds**:  

```bash
systemctl enable wifi_scan.timer
systemctl start wifi_scan.timer
```

With this setup, **WiFi scanning is fully automated** without requiring manual execution. However, what if we want real-time access to this data in a robotic system?  

---

## **Integrating with ROS2**  
To extend our reusable WiFi scanner, we can publish scan results to a **ROS2 Topic**. This enables other components in a robotic system to access WiFi data dynamically.  

### **Why Use ROS2?**  
Publishing WiFi data in ROS2 allows:  
- **Checking if a target network is in range before connecting**  
- **Mapping WiFi signal strength to a robot's location**  
- **Building a WiFi coverage map of the environment**  

### **Creating a ROS2 Topic**  
To integrate our Python WiFi scanner with ROS2, we modify our code:  

```python
import sys
sys.path.append('/opt/robot/wifi_scanner/scanner')

from scanner import WiFiScanner  # Assuming your scanner script is saved as scanner.py

def scan_and_publish(self):
    networks = WiFiScanner.scan()
    # Code to publish networks to a ROS2 topic
```
[find code here](https://github.com/richard-sebos/Ethical-Hacking-Robot/tree/main/networking/ros2/wifi_scanner)

After rebuilding the ROS workspace, which publishes WiFi scan results to a ROS2 topic called `/wifi_scanner`, making them available for other robotic components.  

To test the topic:  

```bash
ros2 topic echo /wifi_scanner
```

Example output:  

```bash
data: '[{"bssid": "XX:XX:XX:XX:XX:XX", "ssid": "NetworkName", "channel": 1, "signal_strength": -60}]'
```
Learn to build ROS2 Topic [here](https://dev.to/sebos/building-an-ethical-hacking-robot-with-ros2-wifi-scanner-implementation-3ol5)
With this setup, our WiFi scanner is now accessible in three different ways:  
1. **Direct execution** for immediate results  
2. **Automated systemd timers** for scheduled scans  
3. **ROS2 Topic publishing** for real-time integration  

---

## **Conclusion: The Power of Separation of Duty**  
By structuring our WiFi scanner to separate core functionality from execution methods, we’ve created a **highly reusable** and **flexible** system. This approach:  
- Makes debugging and maintenance easier  
- Allows multiple ways to interact with the same core logic  
- Enables seamless integration into Linux and ROS2 environments  

Now, think about your own projects—what services could benefit from a **Separation of Duty** approach? Whether you're working with robotics, system administration, or automation, designing modular and reusable components will save time and effort in the long run.  

What other tasks in your system could be **reused** more effectively? 🚀
