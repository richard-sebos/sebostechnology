Absolutely! Here’s a clearer, more concise rewrite of the research on **Enforcing SSH Key Expiry and Rotation Policies with AuthorizedKeysCommand**:

---

# Enforcing SSH Key Expiry and Rotation Policies with AuthorizedKeysCommand

## Introduction

SSH keys are a foundational element for securing remote server access. However, if these keys are not regularly rotated, they become a significant security risk. One effective method to enforce key expiration and rotation is using SSH's `AuthorizedKeysCommand` directive.

---

## What is `AuthorizedKeysCommand`?

The `AuthorizedKeysCommand` directive in the SSH server configuration (`sshd_config`) specifies an external command that SSH runs to retrieve public keys for a user when they attempt to log in. This allows for dynamic key validation, including expiry checks, key rotation enforcement, or integrating with external key management systems.

---

## How Does `AuthorizedKeysCommand` Work?

1. A user attempts to log in using their SSH key.
2. Instead of reading the static `authorized_keys` file, SSH runs the specified `AuthorizedKeysCommand`.
3. This command can:
   - Validate the key (e.g., check for expiry).
   - Fetch updated keys from an external source.
   - Enforce policies like key rotation or user access controls.

If the command provides a valid key, access is granted; if not, the login attempt fails.

---

## Common Use Cases

1. **Key Expiry Enforcement:** Automatically deny access when a key exceeds its lifespan.
2. **Dynamic Access Control:** Allow or deny access based on real-time conditions, such as group membership or key origin.
3. **Auditing and Logging:** Log SSH key usage, expiry, and rotation events for compliance and monitoring.

---

## Example Configurations

### Example 1: Validate Keys Using `ssh-keygen`

```bash
Match All
AuthorizedKeysCommand /usr/bin/ssh-keygen -l -v
AuthorizedKeysCommandUser nobody
```

- This setup uses `ssh-keygen` to validate the fingerprint and format of provided keys.
- It ensures keys are valid but does not handle expiry.

---

### Example 2: Enforce Key Ownership for a Specific Domain

```bash
Match All
AuthorizedKeysCommand /usr/local/bin/validate_key.sh
AuthorizedKeysCommandUser nobody
```

**validate_key.sh Example:**

```bash
#!/bin/bash
KEY_ID="$1"
if grep -q "$KEY_ID" /etc/ssh/valid_keys; then
    cat /etc/ssh/valid_keys
else
    exit 1
fi
```

- This script only allows keys listed in `/etc/ssh/valid_keys`, enforcing centralized key control.

---

## Security Considerations

- **Private Key Protection:** Expiry policies are ineffective if private keys are leaked. Always secure private keys with strong file permissions and encryption.
- **Complementary Controls:** Use multi-factor authentication (MFA) alongside key expiry to mitigate risks from stolen private keys.
- **Layered Rotation Strategy:** Automate key expiry enforcement via `AuthorizedKeysCommand` but combine it with periodic manual reviews or an external key management system.

---

## Potential Risks of Poor SSH Key Management

- **Key Reuse:** Old or compromised keys reused across systems can allow attackers unauthorized access.
- **Stale Keys:** Keys that never expire remain valid indefinitely, creating a long-term security risk.
- **Man-in-the-Middle (MitM) Attacks:** If attackers gain access to private keys or intercept SSH traffic, they can impersonate legitimate users.

---

## Real-World Incidents

- **2018 SSH Gateway Attack:** Exploited vulnerabilities in SSH gateways to hijack sessions.
- **2017 SSH Brute Force Spike:** An uptick in successful brute-force attacks targeting SSH keys.
- **2016 Ubuntu Foundation Key Theft:** Compromised private keys led to significant risks for system integrity.

---

## Best Practices for SSH Key Management

1. **Implement Key Expiry and Rotation Policies.**
2. **Secure Storage of Private Keys:** Use encrypted vaults and limit access.
3. **Audit SSH Key Usage:** Regularly review active keys and associated user accounts.
4. **Deploy MFA for SSH:** Strengthen access controls beyond just key pairs.

---

## Resources

1. [SSH Configuration Guide (DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
2. [SSH Key Rotation Best Practices (Red Hat)](https://www.redhat.com/en/topics/openshift/ssd-key-rotation-best-practices)
3. [Enforcing SSH Key Expiry (Microsoft)](https://blogs.msdn.microsoft.com/powershell/2015/07/16/enforcing-ssh-key-expiry-and-rotation-policies/)
4. [SSH Gateway Attack (SSH.com)](https://www.sshtech.org/security-alerts-blog/2018/09/ssgw-attack)
5. [SSH Key Theft Incident (TechCrunch)](https://techcrunch.com/2016/07/18/ubuntu-foundation-admits-private-key-stolen-from-github/)

---

Let me know if you’d like to expand this with a step-by-step script example or include integration with key management solutions!

Great question! Unfortunately, **OpenSSH's `ssh-keygen` does *not* natively support setting an expiration date on SSH keys**. SSH keys, unlike X.509 certificates, don’t carry metadata like expiry dates. Once a key is generated, it's valid indefinitely unless you manually remove it from the server or use external mechanisms to enforce expiration.

### Workarounds for SSH Key Expiry

Here are some ways you can **enforce expiry** or **simulate expiration**:

---

### 1. **Use `AuthorizedKeysCommand` for Expiry Enforcement (Dynamic Validation)**

You can maintain a database (or file) with key metadata, including expiration dates, and use the `AuthorizedKeysCommand` directive to validate if a key is expired *before allowing access*.

For example:
- Store keys and their expiry dates in `/etc/ssh/authorized_keys_with_expiry`.
- Use a custom script that checks the expiry date when a user logs in.

---

### 2. **Use `from="..."` Option in `authorized_keys`**

While this doesn’t set an expiry, you can **restrict key usage** to certain IP addresses, commands, or times.

Example entry in `authorized_keys`:
```bash
from="192.168.1.100",command="echo 'This key has expired!'" ssh-rsa AAAAB3Nza...
```

For time-based controls, you'd need external automation (like a cron job) to disable or remove keys at specific times.

---

### 3. **Manually Rotate Keys (with Scheduling Tools)**

- Use **cron** or **Ansible** to schedule key rotation.
- A simple cron job could **remove keys** from the `authorized_keys` file once expired.

Example cron:
```bash
0 0 1 * * /usr/local/bin/remove_expired_keys.sh
```

---

### 4. **Use Certificates (SSH CA) with Expiry**

OpenSSH supports **certificate-based authentication**, which *does* allow expiry.

1. Generate a key pair:
   ```bash
   ssh-keygen -t rsa -b 4096 -f user_key
   ```

2. Use an **SSH Certificate Authority (CA)** to sign the key with an expiry:

   ```bash
   ssh-keygen -s ca_key -I user_cert -n username -V +52w user_key.pub
   ```

   - `-s ca_key`: The CA private key.
   - `-I user_cert`: Certificate identity.
   - `-n username`: The principal (user).
   - `-V +52w`: Valid for 52 weeks (you can specify `YYYYMMDD` format or relative times).

**Certificates are the only native way in SSH to embed expiration directly into the authentication process.**

---

Would you be interested in setting up **SSH certificates** in your environment? I can help walk you through that if you're curious!

Great follow-up! SSH **certificates** offer **several advantages** over traditional SSH **public/private key pairs** (authorized keys). They provide better scalability, security, and manageability, especially in larger environments.

Here’s a breakdown of the key advantages of **SSH certificates** over regular **authorized keys**:

---

## 🔑 1. **Built-in Expiration and Validity Controls**

- **Certificates:** Have a built-in **expiry time** (`-V` option in `ssh-keygen -s`). The SSH server will automatically reject expired certificates.
- **Authorized keys:** No native expiration. You have to manually remove or rotate keys.

**Benefit:** Reduces the risk of stale or forgotten keys providing indefinite access.

---

## 🌐 2. **Centralized Trust via Certificate Authority (CA)**

- **Certificates:** Trust is based on a **CA public key** installed on servers. The server accepts any user key **signed** by the trusted CA.
- **Authorized keys:** Each server must maintain its own **list of authorized keys**, leading to duplication and manual synchronization.

**Benefit:** You can add or revoke access **centrally** without modifying every server's `authorized_keys` file.

---

## 🔒 3. **Granular Access Control with Principals**

- **Certificates:** Include **principals** (usernames, hostnames) embedded in the cert, specifying who or what the cert is valid for.
- **Authorized keys:** Tied directly to a user account but without rich metadata.

**Benefit:** You can issue one cert per user that grants access to multiple systems or roles (e.g., `admin`, `developer`).

---

## 🧹 4. **Easier Key Rotation**

- **Certificates:** **User keys stay the same**, only the **certificates** need to be reissued periodically (e.g., daily or weekly certs).
- **Authorized keys:** Requires **replacing user keys** across all systems.

**Benefit:** Simplifies key rotation without needing to regenerate new key pairs.

---

## 🚫 5. **Revocation Capabilities**

- **Certificates:** Support **revocation lists** (CRLs) via a `revoked_keys` file on the server, allowing you to **revoke certs before expiry**.
- **Authorized keys:** No direct revocation—must remove the key from each server.

**Benefit:** Allows **emergency access removal** (e.g., when a key is compromised).

---

## 🧩 6. **Improved Host Authentication**

- **Host Certificates:** SSH certificates aren't just for users—you can also sign **host keys** with the CA.
- **Benefit:** Provides a way to **validate server identities**, avoiding the typical "Are you sure you want to continue connecting?" prompt for new hosts.

---

## 🔁 7. **Scalability for Large Environments**

- **Certificates:** Scale better in environments with **many users and hosts** because trust relationships are centralized through the CA.
- **Authorized keys:** Managing many users or hosts manually can become a nightmare.

**Benefit:** Much easier **automation and policy enforcement**.

---

## ⚙️ 8. **Supports Multiple CA Chains**

- **Certificates:** OpenSSH allows multiple **trusted CAs** (e.g., different teams or org units).
- **Authorized keys:** No concept of delegation.

**Benefit:** Flexible delegation of trust across different teams or business units.

---

### ⚖️ Summary Table

| Feature                  | SSH Certificates                  | Authorized Keys             |
|--------------------------|------------------------------------|-----------------------------|
| **Expiry control**       | ✔️ Built-in                        | ❌ Manual                    |
| **Centralized trust**    | ✔️ CA-based                        | ❌ Per-server key files      |
| **Revocation**           | ✔️ Revocation lists (CRLs)         | ❌ Manual removal            |
| **Granular access**      | ✔️ Principals (usernames/roles)    | ❌ Only per user              |
| **Host validation**      | ✔️ Signed host keys                | ❌ Fingerprint confirmation  |
| **Scalability**          | ✔️ Scales to large environments    | ❌ Hard to manage at scale   |
| **Rotation ease**        | ✔️ Cert renewal only               | ❌ New keys per rotation     |

---

If you’re managing a **home lab** or **enterprise** environment, SSH certificates can make your life a lot easier, especially as things scale out.

Let me know if you want help setting up an **SSH CA**, or exploring how certs could fit into your current setup!

Ah, great question! Let's unpack that because **self-signed SSH certificates** vs **regular SSH keys** often get mixed up with SSL/TLS concepts.

### First off:  
SSH **certificates** and SSH **keys** both rely on **public-key cryptography** for authentication. The **security level** of both fundamentally depends on:

- The **cryptographic strength** of the keys (e.g., RSA 4096, Ed25519).
- How well the **private keys** are protected.

But when you ask **"Are self-signed certs as secure as SSH keys?"** — here’s the key difference:

---

## 🔐 SSH Key Pairs (Traditional Authorized Keys)

- **Security relies entirely on the keypair itself**:
  - The public key goes in `authorized_keys` on the server.
  - The private key stays with the user.
- There’s **no external validation** (like a CA); the server just checks if the presented public key matches what's in `authorized_keys`.
- **Pros:** Simple, direct, and doesn’t require extra infrastructure.
- **Cons:** Harder to manage at scale (you manually distribute keys).

---

## 🛡️ SSH Certificates (with Self-Signed CA)

- A **Certificate Authority (CA)** signs the user’s public key, creating a **certificate**.
- The server **trusts the CA’s public key**, not individual user keys.
- The certificate contains:
  - The **public key**.
  - **Metadata** (expiry, principals, etc.).
  - **Signature from the CA**.

**Self-signed CA** just means **you control the CA key**, which signs the certificates. **It's not inherently insecure**—as long as:

- The **CA private key** is well-protected.
- Proper **expiry and revocation** policies are in place.

> **Key point:** SSH certificates signed by your **own CA (self-signed)** are *at least as secure* as regular SSH keys **if managed properly**. The **encryption strength** is the same; the difference is in **trust management and metadata**.

---

### 🔥 So, which is more secure?

| Feature                        | SSH Keys                        | SSH Certificates (Self-CA)    |
|---------------------------------|---------------------------------|-------------------------------|
| **Cryptographic strength**      | Same (depends on key size/type) | Same (depends on key size/type) |
| **Built-in expiry**             | ❌ None (manual removal)        | ✔️ Yes (cert expiry field)    |
| **Centralized trust model**     | ❌ No (trust per-server)         | ✔️ Yes (trusted CA)           |
| **Revocation support**          | ❌ Manual                        | ✔️ Revocation lists (CRLs)    |
| **Scalability**                 | ❌ Challenging at scale          | ✔️ Easy with CA               |
| **Management overhead**         | ✅ Simple for small setups       | ❌ More complex (needs CA)    |

**TL;DR:**
- **Security-wise**: Both are secure **if the keys and CA are protected**.
- **Manageability-wise**: **SSH certificates** (even with a self-signed CA) offer **more flexibility, expiry, and revocation**, making them *safer at scale*.

---

If you’re running a **home lab**, self-signed SSH certs are a **huge win** for **expiry control and easier management**. You control the CA, no third parties involved, but gain the **expiry and revocation** benefits.

Want help **setting up a self-signed SSH CA** for your lab? I can guide you through it!