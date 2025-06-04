
In the last post we when over 
- Updating the server post Ubuntu install
- Setup a ROS2 users
- It setup the system to have ROS2 installed on it
- This post, the ROS2   

### ✅ Summary

This script:
1. Installs necessary dependencies.
2. Adds the official ROS 2 repository and GPG key.
3. Installs ROS 2 base packages and supporting tools.
4. Initializes and updates `rosdep` for dependency resolution.



### 🧩 Step-by-step Explanation

```bash
apt install -y curl gnupg2 lsb-release software-properties-common
```
- **Purpose**: Install required tools for setting up ROS repositories and handling packages.
- **Tools installed**:
  - `curl`: For downloading files from URLs.
  - `gnupg2`: To manage GPG keys for verifying repository authenticity.
  - `lsb-release`: Provides the distribution codename (e.g., `focal`, `jammy`).
  - `software-properties-common`: Adds support for managing additional APT repositories.

---

```bash
curl -sSL "$ROS_KEY_URL" -o /etc/apt/trusted.gpg.d/ros.asc
```
- **Purpose**: Download the ROS repository GPG key.
- **Details**:
  - `"$ROS_KEY_URL"` is a variable containing the URL to the ROS GPG key.
  - The key is saved in the trusted keyring at `/etc/apt/trusted.gpg.d/ros.asc`.

---

```bash
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/ros.asc] $ROS_REPO_URL $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list
```
- **Purpose**: Adds the ROS 2 repository to APT sources.
- **Details**:
  - `$ROS_REPO_URL`: Base URL of the ROS 2 APT repository.
  - `$(lsb_release -cs)`: Dynamically gets the codename of the distro (e.g., `jammy`).
  - Output is written to `/etc/apt/sources.list.d/ros2.list` for APT to recognize.

---

```bash
apt update
```
- **Purpose**: Updates the package list to include the newly added ROS 2 repository.

---

```bash
apt install -y ros-$ROS_DISTRO-ros-base python3-rosdep python3-colcon-common-extensions python3-argcomplete colcon
```
- **Purpose**: Installs core ROS 2 components and supporting tools.
- **Packages installed**:
  - `ros-$ROS_DISTRO-ros-base`: Base installation of ROS 2 (e.g., middleware, CLI, no GUIs).
  - `python3-rosdep`: Tool for installing system dependencies of ROS packages.
  - `python3-colcon-common-extensions`, `colcon`: Build system for ROS 2.
  - `python3-argcomplete`: Enables shell autocompletion for ROS CLI tools.

---

```bash
[ -f /etc/ros/rosdep/sources.list.d/20-default.list ] || rosdep init
```
- **Purpose**: Initializes `rosdep` if it hasn’t been initialized yet.
- **How**: Checks if the config file exists; if not, it runs `rosdep init`.

---

```bash
rosdep update
```
- **Purpose**: Downloads the latest dependency definitions so `rosdep` can resolve and install system dependencies for ROS packages.

---

### ✅ Summary

This script:
1. Installs necessary dependencies.
2. Adds the official ROS 2 repository and GPG key.
3. Installs ROS 2 base packages and supporting tools.
4. Initializes and updates `rosdep` for dependency resolution.

