---
title: 🛡️
date:  2025-04-09 13:06 +0000
categories: [Robotics, ROS2 Install Series, Security]
tags: [ros2, robotics, cybersecurity, linux]
---

- Up until this point, we have work to secure the ROS2.
- We have
    - Started with a fresh install
    - Setup SROS2
    - Configured AppAmor and Auditd do
    - Setup a firewall
    - And added Suricata

- Auditd, AppAmor and Suricata allow user to define rules or profiles to define how the system monitors or protects the system
- In this post, we will look deeper into what `auditd` does and how it works with AppArmor and Auditd


## What is Auditd
- `auditd` is a **security auditing tool** that monitors and records **user activities, process actions, file system accesses, and certain network-related events**. 
- a key thing to note, it doesn't stop the events it monitors and records the actions
- as the robot is really a commuitity of electric devices 
- from camera and senses to motor controller, there could be multiple device interacting with the robot's main controller
- With specialized software to control eact of the device, it maybe hard to define what should be allowed or blocked
- `auditd` can help with this by created rules between device boundtries and report on what is going through  
---

### 📚 **Key Capabilities:**

* Monitors **file system actions** (read, write, execute, attribute changes).
* Tracks **user activity** (logins, privilege escalations, command executions).
* Captures **process actions** (process creation, exec calls).
* Monitors certain **network-related system calls** (e.g., `connect()`, `bind()`) but it is **not a network traffic analysis tool** like Suricata.
* Provides detailed **audit logs** in `/var/log/audit/audit.log`.
* Integrates with tools like `ausearch`, `aureport`, and `auditctl` for analysis and rule management.

## Why Use Auditd
- The debate of deny acces vs monitor will always happen.
- Deny for an security point of veiw sounds saver them monitoring could malious traffic/process
- Monitor from a business point a view means users are allow to do what they need and we and audit what went wrong
- This is where `auditd` comes in; when added to the development of process or applications
    - rules can be setup and monitor for who and what needs access durning development
    - Applications like Suricata, AppArmor and SELinux can be deployed in passive mode (allowing but logging) in dev and stage to find exceptions
    - In production, passive rules become enforced, which deny access
- The passive mode logs can be used to show then business denies can be added without affecting the business
- But how would a robot system use `auditd`?

## Auditd and Robots
- So why use `auditd` and robots.
- With robots being a collection of device, how do you ensure the security between devices.
- Did the call to the wheel come from the main controller to a melious code in a device driver or miss configures application calls
- `auditd` durning the build process allows you to collect process events running on the robots `Linux` systems.
- These logs give you the base line data to define what would be allow, which can be used to devy everything else.

## How does it work

- Let create an `auditd` rule to watch for when `colcon` is run. `colcon` is use to build the ROS2 packages for a robot.
- We will create a rule that will log when it is executed.
- the entry will have a `auditd` key of `colcon_exec`

```
-w /usr/bin/colcon -p x -k colcon_exec
```

### Breakdown:

| Parameter         | Meaning                                                                                                                                        |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `-w`              | Watch a file or directory. In this case, `/usr/bin/colcon`.                                                                                    |
| `/usr/bin/colcon` | The target file being watched (likely the `colcon` command-line tool used in ROS 2 development).                                               |
| `-p x`            | Specifies the permission filter: `x` means **execute**. This will generate audit events **when the file is executed**.                         |
| `-k colcon_exec`  | Adds a custom **key** (`colcon_exec`) to the audit log entries, making it easier to search for related events using `ausearch -k colcon_exec`. |


### Monitoring the ROS2 Code
- Another use of `auditd` would be to monitor the robot's code base
- below are the `auditd` rules to monitor the code.
- it will create logs when users outside the dev_team group tries to access the files.
- this would include just trying to read the files
> Remember, it doesn't stop them from access it.  It just reports the action taken.

```
# Monitor read, write, and execute attempts outside of dev_team
-a always,exit -F dir=/home/rosbot/ros_wd/ -F perm=rwx -F key=ros_code_access -F auid!=unset -F gid!=<dev_team_gid>

# Monitor file attribute changes (chmod, chown, etc.) outside of dev_team
-a always,exit -F dir=/home/rosbot/ros_wd/ -F perm=a -F key=ros_code_attr_change -F auid!=unset -F gid!=<dev_team_gid>

# Monitor file creations or deletions outside of dev_team
-w /home/rosbot/ros_wd/ -p wa -k ros_code_mod -F gid!=<dev_team_gid>
```

- in the future, as we build ROS2 Topics, Services and Actions we will look at using `auditd` to monitor events on them.

## Reviewing the Logs

- to review the `auditd` logs all you need to do is:

```bash
ausearch --start now-24h -k ros_code_access -k colcon_exec
```

is can be hard to read so here is a batch script that makes it easier

Here’s a complete, reusable Bash script that does exactly that.

* If you provide a **key**, it groups by **User**, sorts by **Action** and **Time**.
* If you provide a **username**, it filters by that user and sorts by **Action** and **Time**.

---

### 📄 **Script: `audit_report.sh`**

```bash
#!/bin/bash

# Usage: ./audit_report.sh --key <audit_key> 
#        ./audit_report.sh --user <username> 

# Input validation
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 --key <audit_key> OR --user <username>"
    exit 1
fi

FILTER_TYPE=$1
FILTER_VALUE=$2

# Determine ausearch parameters based on input
if [[ "$FILTER_TYPE" == "--key" ]]; then
    SEARCH_CMD="ausearch --start now-24h -k $FILTER_VALUE --interpret"
elif [[ "$FILTER_TYPE" == "--user" ]]; then
    USER_UID=$(id -u "$FILTER_VALUE" 2>/dev/null)
    if [[ -z "$USER_UID" ]]; then
        echo "Error: User '$FILTER_VALUE' does not exist."
        exit 1
    fi
    SEARCH_CMD="ausearch --start now-24h -ua $USER_UID --interpret"
else
    echo "Invalid option: $FILTER_TYPE"
    echo "Usage: $0 --key <audit_key> OR --user <username>"
    exit 1
fi

# Process audit logs and produce report
$SEARCH_CMD | \
grep -E 'type=EXECVE|type=SYSCALL|type=CWD|type=PATH|type=USER_CMD' | \
awk -F' ' '
    /type=SYSCALL/ { 
        time=gensub(/.*msg=audit\(([^)]+)\).*/, "\\1", "g"); 
        split(time, t, ":"); 
        cmd_epoch=t[1]; 
        cmd_time=strftime("%Y-%m-%d %H:%M:%S", cmd_epoch); 
    } 
    /auid=/ { 
        for(i=1;i<=NF;i++) { 
            if($i ~ /auid=/) { 
                split($i, a, "="); 
                cmd_uid=a[2]; 
                cmd_user=""; 
                cmd_user_cmd=""; 
            } 
        } 
    } 
    /type=EXECVE/ { 
        for(i=1;i<=NF;i++) { 
            if($i ~ /^a[0-9]+=.+$/) { 
                split($i, b, "="); 
                cmd_user_cmd=cmd_user_cmd b[2]" "; 
            } 
        } 
    } 
    /acct=/ { 
        for(i=1;i<=NF;i++) { 
            if($i ~ /acct=/) { 
                split($i, a, "="); 
                gsub("\"", "", a[2]); 
                cmd_user=a[2]; 
            } 
        } 
    } 
    /type=PATH/ && cmd_user!="" { 
        print cmd_user "|" cmd_epoch "|" cmd_time "|" cmd_user_cmd; 
        cmd_user=""; 
    }' | \
{
    if [[ "$FILTER_TYPE" == "--key" ]]; then
        # Sort by User, Action, Time
        sort -t '|' -k1,1 -k4,4 -k2,2n | \
        awk -F'|' '
        BEGIN { current_user="" } 
        {
            if ($1 != current_user) { 
                current_user = $1; 
                print "\nUser: " current_user; 
                print "----------------------------"; 
            } 
            print "Time: " $3 " | Action: " $4; 
        }'
    else
        # Only show Action and Time for a specific user
        sort -t '|' -k4,4 -k2,2n | \
        awk -F'|' '
        {
            print "Time: " $3 " | Action: " $4; 
        }'
    fi
}
```

---

### 📌 **Usage Examples:**

* **By Auditd Key (Grouped by User, Action, Time):**

  ```bash
  ./audit_report.sh --key ros_code_access
  ```

* **By User (Action and Time Only):**

  ```bash
  ./audit_report.sh --user alice
  ```
- the script can either be run ad hoc or added to a systemd or crontab to do schedule monitoring of the system
- even though this was write for a robot project, the same scripts can be used for general Linux servers and applications.


