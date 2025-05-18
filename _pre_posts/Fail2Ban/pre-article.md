# fail2ban

- so far we have limited what users can log into our `ssh` and added from what IP address
- secured the log in with Auth keys and  Two-Factor Authentication (2FA) 
- so we are secure right and we can log in anytime we want right?
- well no, what about a brute force access.
- ssh auth and 2FA will help keep melisous users out, it does stop brute force attacks that can cause
    - 🛡️ **1. Security Risks**
    - 📈 **2. Performance and Resource Impacts**
    - 📡 **3. Network Impacts**
    - 📚 **4. Compliance and Audit Issues**
- even with SSH servers behind a firewall,  other compernmized servers on the same network can be used in a brute force attach
- How to protect agaisnst a brute force attach?

## What is Fail2ban
- `fail2ban` is a intrusion prevention service that monitors logs
- In this article we are talk about `ssh` and `fail2ban` but it can be uses with other services like Apache, Nginx, Sendmail just to list a few
- when suspicious activity, such as failed authentication attempts or brute force attacks it applies actions to mitigaste the attack
- the actions it can take are 

Fail2Ban can take a wide variety of **automated actions** when it detects suspicious activity. These actions are highly customizable and can be simple or complex depending on your needs.

-  🛡️ **Common Fail2Ban Actions**
    * ✅ **1. Block IP Addresses Using Firewall Rules**
    * ✅ **2. Modify IP Sets (Advanced Firewall Management)**
    *  ✅ **3. Add Routes to Blackhole Of
    *  ✅ **4. Send Email Notifications**
    *  ✅ **5. Run Custom Scripts**
    *  ✅ **6. Execute Permanent or Temporary Bans**
    * ✅ **7. Logging and Alerting Only (Without Banning)**

## How to setup for `ssh`
- `fail2ban` does have a `fail2ban.conf` to define service options but it is the `jail` files that are used to configure what service `fail2ban` are protecting and the options for them.
- the `jail.conf` is the default files that comes with `fail2ban` and you override it with `jail.local`
- I'm goint to break my `ssh` setup into two files
    - jail.local (Global Defaults)
    - sshd.local (SSH-Specific Settings)
---

## 📦 **File 1: `/etc/fail2ban/jail.local` 

```ini
[DEFAULT]
# General Settings
ignoreip = 127.0.0.1/8 ::1 192.168.178.0/24
bantime = 1h
findtime = 10m
maxretry = 3

backend = systemd
usedns = warn

# Default Ban Action
action = %(action_mwl)s
```

---

## 📦 **File 2: `/etc/fail2ban/jail.d/sshd.local` 

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = %(sshd_log)s
backend = systemd

# SSH-Specific Overrides
findtime = 5m
maxretry = 4
```

---

💡 **Tip:** You can similarly create `nginx.local`, `apache.local`, etc., under `/etc/fail2ban/jail.d/` to keep things clean and modular.
--
You **do not need an `include` statement** in `jail.local`.

Fail2Ban automatically processes:

1. `/etc/fail2ban/jail.conf` (defaults, do not modify)
2. `/etc/fail2ban/jail.local` (your global overrides)
3. **All `.local` files in `/etc/fail2ban/jail.d/` (like the `sshd.local`)**

## Fail2ban in Action
- now that fail2ban is setup, lets test it out
- from another server, i ran `fail2ban_trigger.sh`
```bash
#!/bin/bash

TARGET_HOST="192.168.178.13"
FAKE_USER="invaliduser"
ATTEMPTS=5  # Number of failed attempts (adjust based on Fail2Ban maxretry)

echo "Triggering Fail2Ban by attempting to SSH as user '$FAKE_USER' to $TARGET_HOST"

for i in $(seq 1 $ATTEMPTS); do
    echo "Attempt $i..."
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$FAKE_USER@$TARGET_HOST" exit
done

echo "Done. Check Fail2Ban status on the target server."

```
- this blocked the calling server

```bash
sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed:	1
|  |- Total failed:	5
|  `- Journal matches:	_SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned:	1
   |- Total banned:	1
   `- Banned IP list:	192.168.178.11

```

- if needed to clear a block before the time limit
```bash
sudo fail2ban-client set sshd unbanip 192.168.178.11

```

- ssh is an import protocol used to access remote Linux server. 
- It is also a attach point on those servers
- Fail2ban now stops brute force attaches, which is part of a critical trio with 2FA and SSH Auth keys to protect servers.
