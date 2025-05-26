# After the Ubuntu Install

- In this first part of the series, I am going to look at the updating the system and setup up the users.
- I will be using a Bash script to do these task and throughout the series I will be developing the script so you can start with a fresh install and get the syetem setup.
- Lets get started building the script.

## Common  module
- I broke the install script into parts based on logical breaking up of the work.
- There is a common module with the varaible at the top

```bash
#!/bin/bash

# Shared configuration and utility functions


TIMEZONE="UTC".                     # System time zone to set

ROS_DISTRO="jazzy"                  # What version of ROS2
ROS_USER="rosbot"                   # Local user to create
ROS_WS="/home/$ROS_USER/ros2_ws".   # Developement directory

### ROS Reps Info
ROS_KEY_URL="https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc"
ROS_REPO_URL="http://packages.ros.org/ros2/ubuntu"

## Other nodes part of the project
ROS_NODE_IPS=("192.168.1.10" "192.168.1.11")

```

## Re-running if need
- The script is setup to be able to re-run if errors have.
- This is useful for developement or trying different Linux version
- This is setup for Debain/Ubuntu system since it use `apt`
- Each module of the script is run through run_step and wrtie to a log file when completes without errors
- on re-run the script a function call has_run(), checks to see if modules has completed,  if it has not, it run/re-runs that module
- Any errors are spooled to the commandline
```bash
## 
STATE_FILE="/var/log/ros2_setup_state" 

log_step() { echo "$1" >> "$STATE_FILE"; }

has_run() { grep -q "$1" "$STATE_FILE" 2>/dev/null; }

abort_on_failure() { echo "[-] ERROR: $1"; exit 1; }

run_step() {
    local STEP_NAME="$1"
    shift
    if ! has_run "$STEP_NAME"; then
        echo "[*] Running: $STEP_NAME..."
        "$@" || abort_on_failure "$STEP_NAME failed"
        log_step "$STEP_NAME"
    else
        echo "[✓] Skipping: $STEP_NAME (already completed)"
    fi
}

```

## Time Zones, Updates and ROS2 Users

- the first module to be call is system_setup.sh
- It assumes there is a fresh install of the OS and will:
    - Set timezone
    - do system updates
    - install some commonly needed software


```bash 
#!/bin/bash

source ./common.sh

timezone_and_update() {
    timedatectl set-timezone "$TIMEZONE"
    apt update
    apt full-upgrade -y
    apt install -y curl gnupg2 lsb-release software-properties-common ufw apparmor apparmor-utils auditd vim nano
}
```

- After that, it creates a new ROS2 users and 
```bash
create_ros_user() {
    id -u "$ROS_USER" &>/dev/null || (
        adduser --disabled-password --gecos '' "$ROS_USER"
        usermod -aG sudo "$ROS_USER"
    )
}
```

- SO a script has been started that can be re-run if there are errors.
- The script sets the timezone, does update, install base software and setups a new user.
- Boring so far but it securing a system needs steps like this. 
- Cybersecurity is setup in layers of process and barrier to stop intruders.
- This sets up the foundation for install ROS2 and securing it.

## Next Steps
In the next step, the ROS2 application will be installed and future post will get into firewall and intrusion detection. 