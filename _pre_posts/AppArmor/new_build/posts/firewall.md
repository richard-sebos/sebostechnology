# ROS2 Firewall

- For me, robots are an extention of man humanity
- They are born out of you creative and extend what we can do
- they can be made for have fun, to explore, help make life easier, or to help reduce suffering
- But to these thing, they need access to the real world and an internet connection
- In a world where hacker, computer virus, and other melisious threats exists we are getting ready to all more robots then there are humans?

## Firewalls and Robots
- Can a robot exist without a coonection?
- Whether it is a WIFI connection, wired network connection,  a console port, or a USB port, a robot needs a way to get new command instruction or ways to update
- Firewall are there to protect the device connection with wire and wireless networks.
- Sorry USB.
- Firewall are used to either allow or reject network traffice
- traditional firewall best practices are to allow all outgoing but stop any unintialed incoming but does that still
- But does this still work for device like robot?

## Why Robots are not like Servers
- While the quick answser is robots a cool and server are boring is a true answer, for the purpose of this blog servers life in a controlled enviroment.
- Server are protected with tempature controll rooms, security devices like multiple layered firewall, and have montoring application watching them
- All of these are external to the server
- A robot needs to carry its security with it and some robots built with low end hardware, security concerns are an issue.

# UFW and Firewalld
- The two primary firewall software on Linux is Firewalld for Red Hat base distros and for other Uncomplicated Firewall (UFW)
- You can use Firewalld on non Red Hat based distros and UFW on  Red Hat based distros but in our case we will use UFW
```bash
#!/bin/bash

source ./common.sh

ufw_setup() {
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow OpenSSH

    for ip in "${ROS_NODE_IPS[@]}"; do
        for port in {7400..7600}; do
            ufw allow from "$ip" to any port "$port" proto udp
        done
    done

    echo 'y' | ufw enable
}
```