# Limiting SSH Access with TCP Wrappers, AllowUsers, and IP Restrictions
- In the last article, the importance of SSH was talked about.
- The sshd_config was interduce as the way to configure the SSH daemon (service) running on the server
- In this article we will look at restricting users from access the server through SSH
The restricting will be done by TCP Wrappers, AllowUsers, and IP Restrictions

## What are TCP Wrappers?
- TCP Wrappers s considered **legacy** but it still maybe around.
- TCP Wrappers is a host-based access control system for network services. 
- It uses two configuration files:
    - /etc/hosts.allow – explicitly allows access
    - /etc/hosts.deny – explicitly denies access

### Example of Deny all but 192.168.1.100
**`/etc/hosts.allow`**:
```bash
sshd: 192.168.1.100
```
- this allows `ssh` connections form `192.168.1.100`

**`/etc/hosts.deny`**:
```bash
sshd: ALL
```
- this deny all other `ssh` connections
- If this is stil needed, it can be done with firewall rules
- Example filewalld:
```bash 
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100" service name="ssh" accept'
firewall-cmd --reload

```
## AllowUsers and AllowGroups
- The sshd_config file is based on ssh directive and `AllowUsers` and `AllowGroups` are ones of them
- `AllowUsers` directive restricts which server users can access ssh whereas `AllowGroups`
- if both are used, a user must be listed in `AllowUsers` AND be a member of a group in `AllowGroups` to be allowed SSH access.

- From a enterprise level view, I normally create a ssh_users group and use `AllowGroups` to enforce it
- If you have your Linux server  connected to `Active Directory` this group can now all SSH access from `Active Directory` 

## IP Restrictions

- One advantage of `AllowUsers` is it can be used with `Match Address` to restrict what IP address a user can connect from.
- Match Address is a condictional used to assign one or more directives in a block to the address that matches it

```bash
## The only user from 192.168.1.100 that can log in is richard
Match Address 192.168.1.100 
    AllowUsers richard
```
- SSH also allows both to be on the same line:
```bash
AllowUsers richard@192.168.1.100  ## the match address is more reliable
```
- be carefull when using sshd_config condictional
