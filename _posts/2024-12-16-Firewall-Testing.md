---
title: Firewall Testing 101 - How to Secure Your Network and Block Cyber Threats
date: 2024-12-16 16:21 +0000
categories: [Linux, DEVOPS]
tags: [LearnCyberSecurity, CyberSecurity, Firewall, CyberDefense]
---

A firewall is often the first line of defense for securing home or business networks. Whether you purchase a commercial solution or build your own, its purpose is to filter network traffic—allowing legitimate data to pass while blocking potentially harmful activity. In larger network environments, firewalls may also exist between internal network segments, adding layers of protection. 

## Table of Contents  

- [Firewall Testing: Ensuring Network Security](#firewall-testing-ensuring-network-security)
  - [Table of Contents](#table-of-contents)
  - [My Firewall Setup](#my-firewall-setup)
  - [Creating a Test Plan](#creating-a-test-plan)
  - [External Testing](#external-testing)
  - [Internal Testing](#internal-testing)
  - [Is My Firewall Secure?](#is-my-firewall-secure)
  - [Why Firewall Testing Matters](#why-firewall-testing-matters)
  - [What’s Next for You?](#whats-next-for-you)



The general rule for firewalls is to "deny everything in and allow anything out." While this approach provides a baseline for security, it can leave gaps that attackers may exploit, such as reverse SSH tunnels or other vulnerabilities. So, how can you ensure your firewall is as secure as it should be?  

---

## My Firewall Setup  

At the center of my homelab is an OPNsense firewall. It serves as both the central failure point and the primary attack target in my network. To make matters more challenging, I’m relatively new to configuring firewalls, and after five months of experimentation, my setup is in need of a serious cleanup. This raises the critical question: is my firewall still secure?  

---

## Creating a Test Plan  

Before diving into testing, I conducted research to create a structured plan for evaluating my firewall’s security. You can review the plan [here](https://github.com/richard-sebos/firewall_wifi_pentest/blob/main/Pentest_Plan.md).  

The next step was to install a tool for testing—in this case, **nmap**, a powerful network scanning utility. It became apparent during this process that without regular testing, a false sense of security can develop. Simply assuming a firewall is secure without verification is a risky approach. What isn’t tested isn’t secure.  

---

## External Testing  

For external testing, I ran an **nmap** scan on both TCP and UDP traffic. The results were encouraging, as no open ports were detected. I also ran vulnerability scans using nmap and identified an **Avahi service** utilizing the Multicast DNS (mDNS) protocol. However, this service was found to be non-vulnerable.  

On the surface, the external (WAN) side of the firewall seems secure, but what about the internal (LAN) side?  

---

## Internal Testing  

As expected, scanning from the LAN side revealed open ports for **SSH, DNS, HTTP, and HTTPS** during the TCP scan. The UDP scan identified a domain service related to DNS. While this is normal, a vulnerability scan flagged the potential for a **Slowloris DoS attack** on one of the ports. This will require further investigation.  

Despite this finding, the results so far are promising.  

---

## Is My Firewall Secure?  

The initial results suggest that my firewall is reasonably secure, but further testing is necessary to confirm. Each detected port must be individually tested to ensure no vulnerabilities exist. Additionally, the Slowloris DoS issue must be addressed.  

Future posts will document these tests in detail to avoid making this one overly lengthy.  

---

## Why Firewall Testing Matters  

It’s easy to install a firewall or router and assume your network is secure. Unfortunately, many people stop there, neglecting updates and routine security checks because they feel protected. This mindset can lead to untested vulnerabilities remaining unnoticed for years.  

To stay proactive, I’ve started developing a scanning app based on my testing plan. The app is still in its early stages, with limited functionality implemented so far, but you can explore it on [GitHub](https://github.com/richard-sebos/bear). My goal is to add more features as I continue refining my approach and documenting further tests.  

---

## What’s Next for You?  

After reading this, what steps will you take to ensure your firewall is secure? Regular testing and verification are key to maintaining a robust defense against threats. If you’ve never tested your setup, now is the time to start.  