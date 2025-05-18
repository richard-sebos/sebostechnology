---
title: Building an Ethical Hacking Robot with ROS2 - WiFi Scanner Implementation
date: 2025-02-23 22:05 +0000
categories: [Linux, Robotics, Sysadmin, Hack]
tags: [linux, robotics, ros2, hacking]
---

One of the key software technologies needed for my [Ethical Hacking Robot](https://dev.to/sebos/hacking-robot-needed-raspberry-pi-need-not-apply-49l6) is **ROS2 (Robot Operating System 2)**. ROS2 is a powerful middleware framework that allows developers to create modular software components that integrate with hardware. It has been widely adopted by **hobbyists, enterprises, and government agencies** for robotics development.  

# **Table of Contents**  

1. [Introduction](#introduction)  
2. [How Does ROS2 Work?](#how-does-ros2-work)  
3. [WiFi Scanner: The First Step](#wifi-scanner-the-first-step)  
4. [Publishing WiFi Networks as a ROS2 Topic](#publishing-wifi-networks-as-a-ros2-topic)  
   - [Setting Up the ROS2 Workspace](#setting-up-the-ros2-workspace)  
   - [Creating the WiFi Scanner Node](#creating-the-wifi-scanner-node)  
   - [Defining the Entry Point in setup.py](#defining-the-entry-point-in-setuppy)  
5. [Building and Running the ROS2 WiFi Scanner](#building-and-running-the-ros2-wifi-scanner)  
6. [Practical Use Cases: Why a WiFi Scanning Robot?](#practical-use-cases-why-a-wifi-scanning-robot)  
7. [What Would You Use a WiFi-Scanning Robot For?](#what-would-you-use-a-wifi-scanning-robot-for)  
8. [Next Steps](#next-steps)  

---

You can include this at the beginning of your article to give readers an easy way to navigate through the sections. If you plan to publish it online with Markdown support, the clickable links will work automatically. 😊
## **How Does ROS2 Work?**  

ROS2 is installed as an application on an existing operating system, such as **Ubuntu**. It provides a structured environment to build robotic applications using:  

- **Topics** – Real-time data streaming using a **publish-subscribe** model.  
- **Services** – One-time request-response calls.  
- **Actions** – Long-running tasks with feedback.  
- **Parameters** – Configuration values that can be modified at runtime.  
- **Lifecycle Nodes** – Ensuring a safe startup and shutdown of components.  
- **TF (Transforms)** – Managing robot coordinate frames.  
- **Logging** – Debugging and monitoring system performance.  

These components work together to perform robotic actions. For example, a **navigation action** might use a **topic** to provide location data while interacting with a **wheel control service** to move the robot.  

So, where do we start after installing ROS2? Let’s begin by developing a **WiFi Scanner**—a crucial feature for an ethical hacking robot.  

---

## **WiFi Scanner: The First Step**  

Since my larger project involves creating a hacking robot, the first step was developing a **WiFi scanning tool**. I wrote a Python script that:  

- Scans for available WiFi **SSIDs (network names)**.  
- Stores them in a database for future analysis.  
- Can be triggered manually, through a **systemd timer**, or as a **ROS2 Topic**.  

In the future, I envision the robot combining **GPS and WiFi scanning** to map out WiFi networks along with their signal strength.  

---

## **Publishing WiFi Networks as a ROS2 Topic**  

For the robot to be aware of **active WiFi networks**, I created a **ROS2 Topic** to publish available networks in real-time.  

### **Setting Up the ROS2 Workspace**  

First, create a ROS2 workspace and package for the WiFi scanner:  

```bash
# Create the workspace
mkdir -p /opt/robot_ros/wifi/src
cd /opt/robot_ros/wifi/src

# Create a ROS2 package
ros2 pkg create --build-type ament_python wifi_scanner
```

This will generate the following directory structure:  

```
src
└── wifi_scanner
    ├── resource
    ├── test
    └── wifi_scanner
```

### **Creating the WiFi Scanner Node**  

Inside `src/wifi_scanner/wifi_scanner/`, I implemented a **ROS2 node** that scans and publishes WiFi networks every 5 seconds.  

```python
import sys
import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import json

# Import the scanning code
sys.path.append('/opt/robot/wifi_scanner/scanner')
from scanner import WiFiScanner  # Assuming your scanner script is named wifi_scanner.py

class WiFiScannerNode(Node):
    def __init__(self):
        super().__init__('wifi_scanner_node')
        self.publisher_ = self.create_publisher(String, 'wifi_scanner', 5)
        self.timer = self.create_timer(5.0, self.scan_and_publish)  # Scan every 5 seconds
        self.get_logger().info("WiFi Scanner Node has been started.")

    def scan_and_publish(self):
        networks = WiFiScanner.scan()
        networks_data = [network.__dict__ for network in networks]
        msg = String()
        msg.data = json.dumps(networks_data)
        self.publisher_.publish(msg)
        self.get_logger().info(f"Published {len(networks)} WiFi networks.")

def main(args=None):
    rclpy.init(args=args)
    node = WiFiScannerNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
```
**Find out more about WiFiScanner code[here](https://dev.to/sebos/enhancing-code-reusability-in-robotics-a-modular-wifi-scanner-with-ros2-systemd-35ck)**
### **Defining the Entry Point in setup.py**  

To let ROS2 know which script to execute, update the `setup.py` file inside `src/wifi_scanner/`:  

**Before:**  
```python
entry_points={
    'console_scripts': [
    ],
},
```

**After:**  
```python
entry_points={
    'console_scripts': [
        'wifi_node = wifi_scanner.wifi_node:main',
    ],
},
```

---

## **Building and Running the ROS2 WiFi Scanner**  

Now that the code is in place, let's build the package:  

```bash
# Navigate back to the ROS workspace
cd /opt/robot_ros/wifi

# Build the package
colcon build --packages-select wifi_scanner
source install/setup.bash
```

To start the WiFi scanner node:  

```bash
ros2 run wifi_scanner wifi_node
```

To verify that the topic is being published, list all available ROS2 topics:  

```bash
ros2 topic list
```

You should see:  
```
/wifi_scanner
```

The topic name **`/wifi_scanner`** is defined in the Python script:  

```python
self.publisher_ = self.create_publisher(String, 'wifi_scanner', 10)
```

To test the topic, use:  

```bash
ros2 topic echo /wifi_scanner
```

Example output:  

```
data: '[{"bssid": "XX:XX:XX:XX:XX:XX", "ssid": "Network1", "channel": 1, "rate": "54 Mb/s", "bars": 5, "secure": "WPA2"}]'
```

---

## **Practical Use Cases: Why a WiFi Scanning Robot?**  

From my experience working with **warehouse environments**, one major issue is **WiFi dead zones**—areas where connectivity drops. A robot with a WiFi scanner could:  

- Traverse a warehouse and **map WiFi coverage** at different bin locations.  
- Identify weak signal areas and **optimize access point placement**.  
- Assist IT teams in troubleshooting **connectivity issues**.  

Beyond warehouses, other potential applications include:  

- **Security Audits** – Identifying rogue access points in an office environment.  
- **Smart Cities** – Mapping **public WiFi** coverage areas.  
- **Disaster Recovery** – Deploying a robot to find working networks in disaster-stricken areas.  

## **Next Steps**  

Now that we have a working WiFi scanner, the next steps include:  

- Integrating **GPS data** to map WiFi networks geographically.  
- Enhancing security analysis to detect **open vs. secured networks**.  
- Automating **WiFi signal strength monitoring** for network optimization. 
### **What Would You Use a WiFi-Scanning Robot For?**  


This is just the beginning of building a **fully autonomous hacking robot**. Stay tuned for more updates! 🚀  

I’d love to hear your thoughts! How would you use a robot that can scan for WiFi networks?  


 