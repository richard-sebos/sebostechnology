---
title: Securing a Prankster Robot - Linux Security Strategies to Prevent Rogue AI
date: 2025-03-01 20:39 +0000
categories: [Linux, Robotics, Sysadmin, Devops]
tags: [linux, robotics, ros2, devops]
---

## **Introduction**  

Imagine a world where robots entertain us at theme parks, birthday parties, or public events. Now, imagine one of these robots is **a mischievous clown robot** designed to perform pranks—like **blowing bubbles at unsuspecting guests**.  

While it sounds fun, **what happens if the clown robot goes rogue and starts pranking everyone uncontrollably?** What if its **bubble gun** malfunctions and **sprays foam at VIP guests or clogs an important event stage?**  

This article outlines a **security architecture** leveraging **Linux security policies, encryption, and strict access controls** to prevent unintended behavior while ensuring the system operates as expected.  

---
## **Table of Contents**  

2. [The Clown Robot Setup](#the-clown-robot-setup)  
3. [Securing the Important Modules](#securing-the-important-modules)  
4. [Securing the Code](#securing-the-code)  
   - [Protecting the Prank Safety Protocol](#protecting-the-prank-safety-protocol)  
   - [Restricting Execution with systemd and sudoers](#restricting-execution-with-systemd-and-sudoers)  
5. [Friend and Foe Logic Security](#friend-and-foe-logic-security)  
6. [The Camera Logic: Isolation & Security](#the-camera-logic-isolation--security)  
7. [Bubble Gun Security: Validating Prank Requests](#bubble-gun-security-validating-prank-requests)  
8. [Overall Security Strategy](#overall-security-strategy)  
9. [Final Thoughts: Preventing an AI Takeover](#final-thoughts-preventing-an-ai-takeover)  

---
## **The Clown Robot Setup**  

Our **clown robot** has the following capabilities:  

- **Facial Recognition** – Scans faces to identify people.  
- **Friend/Foe Database** – Determines if a person is a "prank-friendly" guest or someone who should not be pranked.  
- **Prank Safety Protocol** – Governs whether the bubble gun can activate.  
- **Bubble Gun Module** – Fires bubbles when permitted.  

### **Operational Flow**  

1. The robot **searches its environment** and scans faces.  
2. The **Friend/Foe logic** determines if a person is a prank-friendly guest or someone who should not be pranked.  
3. If prank permission is granted, the **Prank Safety Protocol generates a prank token** and **wraps it in an encrypted authorization token** before sending it to the Bubble Gun.  
4. If prank permission is denied, the robot moves on to the next guest.  

Now, let's explore how to **prevent unauthorized control** and ensure that the clown robot does not start spraying bubbles at everyone uncontrollably.  

---

## **Securing the Important Modules**  

Each module must be isolated and protected with strict security measures:  

1. **The Bubble Gun** – Can only fire when properly authorized.  
2. **The Prank Safety Protocol** – Controls when the gun can fire and ensures safety.  
3. **Friend and Foe Logic** – Determines valid prank targets but cannot directly fire the gun.  
4. **Camera System** – Captures images but has no control over firing.  

---

## **Securing the Code**  

### **Protecting the Prank Safety Protocol**  

- The **prank safety protocol code** is stored in a **secure, read-only directory**.  
- The protocol **only allows one bubble blast at a time** before automatically engaging the safety again.  
- **Only the root user** can modify the prank safety protocol.  

### **Restricting Execution with systemd and sudoers**  

To ensure that only authorized components can interact with the prank safety protocol:  

- A **dedicated systemd service** manages the prank safety protocol.  
- A **new user `bubble_safety`** is created with restricted permissions.  
- A **sudoers rule** allows `bubble_safety` to run the service—but nothing else.  
- The `bubble_safety` user **cannot modify code**, ensuring that even if compromised, it cannot alter the prank logic.  

---

## **Friend and Foe Logic Security**  

- Runs as a separate **service** that listens for image processing requests.  
- It **does not have access to the camera system**, preventing manipulation of images.  
- If a **guest is prank-friendly**, it sends an **encrypted request** to the prank safety protocol.  
- The prank safety protocol **returns an encrypted prank token**.  
- The **Friend/Foe system never sees the actual prank token**, preventing it from spoofing commands.  

### **Extra Security Layer: Wrapping the Prank Token**  

To prevent interception or misuse of the prank token:  

1. The **Prank Safety Protocol generates a prank token**.  
2. It **encrypts the token** and then **wraps it in a separate encrypted authorization token**.  
3. The Bubble Gun **must decrypt the authorization token first** to extract the prank token.  

Since **only the Bubble Gun can decrypt the authorization token**, this prevents other components from manipulating the token.  

---

## **The Camera Logic: Isolation & Security**  

- A **separate service** tracks movement and captures images.  
- **No access to the prank safety protocol or gun**—it simply forwards images.  
- **Does not process Friend/Foe logic**, ensuring it cannot manipulate decisions.  

---

## **Bubble Gun Security: Validating Prank Requests**  

- The bubble gun **listens for prank tokens** from both the **prank safety protocol** and **Friend/Foe logic**.  
- To fire, the gun must verify:  
  - **Sender Identity** – Encrypted sender ID validation.  
  - **Token Expiry** – Tokens expire after a short time.  
  - **Token Matching** – The Friend/Foe token must match the Prank Safety Protocol token.  
  - **Authorization Token Validation** – The prank safety protocol’s encrypted token must be decrypted before extracting the prank token.  

This multi-step validation ensures that **no single system can authorize a prank on its own**.  

---

## **Overall Security Strategy**  

### **1. Camera System**  
✅ Captures images but **cannot access** the gun or prank safety protocol.  
✅ **Does not process Friend/Foe logic**, preventing manipulation.  

### **2. Friend and Foe Logic**  
✅ **Cannot access the camera**, ensuring image integrity.  
✅ **Can communicate with the gun but lacks the full prank key.**  
✅ **Cannot modify the prank safety protocol** or reuse expired tokens.  

### **3. Prank Safety Protocol**  
✅ **Has access to the gun but only generates a wrapped authorization token.**  
✅ **Cannot forge Friend/Foe verification tokens.**  
✅ **Runs as a protected systemd service** with restricted execution.  

### **4. Bubble Gun**  
✅ **Only fires when it receives a valid decrypted prank token.**  
✅ **Validates both the prank token and the authorization token.**  
✅ **Cannot be activated without explicit authorization.**  

---

## **Final Thoughts: Preventing an AI Takeover**  

To further harden security, **implementing SELinux or AppArmor** can restrict processes to their intended permissions.  

- **SELinux (Security-Enhanced Linux)** can define mandatory access control (MAC) policies to prevent unauthorized access to critical files and services.  
- **AppArmor** can restrict each service to a predefined set of operations, ensuring that even if compromised, they cannot execute arbitrary commands.  

By combining **system isolation, encryption, token-based authentication, and kernel-level security policies**, we ensure that the clown robot remains under strict control—**a fun entertainer, not a rogue prankster**.  

🔐 **Security in robotics isn’t just about preventing rogue AI—it’s about ensuring systems operate as designed, without unintended consequences.**  
