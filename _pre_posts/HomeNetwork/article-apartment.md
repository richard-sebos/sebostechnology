- When living in an enviroment where you have neobourgh close to you or even in a apartment complex and make  securing a home/home lab network more important
- these concerns going beyond encryption traffic so you Internet Service Provided (ISP) monitoring your traffic. 
- Now adays, the home network as smartphone, tablet, tv as well as IOT device from light bulbs and friges to home smart controllers.

The modem/router combo provided by ISPs often comes with several security concerns that can compromise your home lab or network environment. These devices prioritize ease of use and cost-efficiency over security. Here are the primary concerns:

### 🔴 **1. Default Credentials and Backdoors**

* Many ISP routers ship with default admin credentials (e.g., `admin/admin`) that are rarely changed.
* Some have hidden backdoor accounts or undocumented access methods left by manufacturers or ISPs.

### 🟠 **2. Lack of Timely Firmware Updates**

* ISPs often delay firmware updates, leaving devices exposed to known vulnerabilities like:

  * **CVE-2019-18989** (Netgear routers)
  * **Mirai Botnet Exploits**
* Some devices never receive updates after a certain period.

### 🟡 **3. Remote Management (TR-069 Exploits)**

* ISPs use protocols like **TR-069 (CWMP)** for remote management.
* Poorly configured TR-069 can be exploited to gain remote control over the router.

### 🟢 **4. Weak or Outdated Encryption**

* Some ISP devices still support deprecated protocols like **WEP** or **TKIP** for Wi-Fi encryption.
* Weak VPN passthrough settings can also introduce vulnerabilities.

### 🔵 **5. Limited Security Controls**

* Lack of proper firewall features, no VLAN support, or advanced filtering options.
* Limited logging makes it difficult to detect anomalous behavior.

### 🟣 **6. Insecure UPnP and Port Forwarding**

* UPnP is often enabled by default, allowing devices and malware to open ports without user consent.
* Dynamic port forwarding can be abused for lateral movement within the network.

### 🟤 **7. DNS Hijacking and Ad Injection**

Even if they are up to date the them ISP device know how to protect the data from the growing number of devices homeowners have.  Don't get me started on the door cams

## What can a homeowner/homelaber do

- Secure when done well is done on layers.
- Each layer protects the layers behind it.
    - Adding a firewall between wired connections and ISP modem/router
        - If there are vulabilites on the ISP device, they can be filter out
        - An older computer or low end mini-PC will work for this
        - OpnSense or PFSense would work
        - How to setup OpnSense 
        - The firewall will setup up a WAN and a LAN
            - WAN is the network before the firewall
            - LAN is the network behind the firewall that the firewall is protected
    - A Intrustion Detections (ID) with Suricata or something similar
        - It can be setup to monitor the WAN network traffic
        - looking for attempts to break into the firewall
        - Suricata on OPNSense
        - Create rules  in Complain mode for short time and enforce once verify the results 
    - Add Access Point behind the firewall
        - A Access Point (AP) is a like a WiFi router just with out the router part.
        - It can be added to a network and allow wired devices to access the network
        - Setup device access by MAC
    Add  Intrustion Detections (ID) to the AP
        - Now that we added a whole to the firewall, lets block access
        - We need to create similar rules in Complain mode as before and enforce them once we verify they are doing what we want
        