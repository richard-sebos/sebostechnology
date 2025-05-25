## SSH Restict access 

- SSH is a daily tools for Linux Admins
- If you are using it, you will be using sudo with it
- this means, admin accounts that can be logged in from remote devices
- Add ssh auth logins from laptop and you have a security issue
- If the laptop or auth key are take them your remotes servers become open doors
- what if you could create a restricted users you can ssh in as and then switch to you admin account?

# Why use Two ID
- I recently started to setup up two accounts on my Linux system
- a restricted account richard and an admin account rchamberlain
- richard is locked down to its home drive and has access to very few commands
- rchamberlain is an admin with sudo access
- richard can ssh in and rchamberlain can't
- This allows me to protect my admin account from external attacked
- here is how I did it

## Restricted User
- Most Linux distro's have an rbash command
- it is used to launch a restrict version of bash
```bash
## Is rbash there
which rbash
/usr/bin/rbash

## If it is not
which bash    ## to find bash
/usr/bin/bash

## link to were bash is
sudo ln -s /usr/bin/bash /usr/bin/rbash
```
- Linux knows the difference between bash and rbash even though it is the same file
- from there I set the default shell to rbash
```bash
sudo usermod -s /usr/bin/rbash richard
```
- now when the users tries to login next, there are contained to their home directory
- but what about running commands that are on their path like bash to open a unresticted session.

## Restricting commands
- now that users can not leave their home drive, lets make sure it says this way
- I create a /home/richard/bin directory and link any commands I want the users to be able to do
```bash
sudo mkdir /home/richard/.bin

## it should be owned by root but lets make sure
sudo chown root:root /home/richard/.bin  ## this restricts richard from adding commands
sudo ln -s /bin/ls /home/richard/.bin/ls   ## List files and directories
sudo ln -s /bin/su /home/richard/.bin/su  ## Allows richard to change users
sudo ln -s /bin/clear /home/richard/.bin/clear ## clear the screen
```
- next the path in .bashrc is lock down to /home/richard/bin and ensure any files scp to the home drive is not executable
 ```bash
## open /home/richard/.bashrc
sudo nano  /home/richard/.bashrc

## add and save
export PATH=$HOME/.bin
umask 077

## /home/richard/.bashrc should be -rw-r--r--
## lock down the .bashrc
sudo chown root:richard /home/richard/.bashrc
```
- now the richard account can on run the commands that are /home/richard/bin
- So why do this

## So is this over kill
- Alot of time, secure lays like is seems as over kill or will take too much time when it is critical to log into a server
- that is, until an attack happens and tighter security becomes important agian.
- Cybersecurity is about creating layers to try to stop an attacker
- with the other recent article of auth key, Fail2ban and 2FA, retricted access builts up a layer security to if not stop, then delay or make the attacker look for easier targets.

