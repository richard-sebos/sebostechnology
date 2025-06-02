# **Requirement Document: Agent Forwarding Project**

## **1. Overview**

The goal of the **Agent Forwarding Project** is to establish a secure and controlled SSH access environment leveraging SSH Agent Forwarding. The system will allow a local development machine (MacBookPro M4) to access multiple GCP-hosted VMs through a central **Jump VM**, while using SSH agent forwarding for authentication. This approach facilitates secure access without copying private keys to cloud servers.

---

## **2. Goals**

* Set up an SSH Agent on a local machine that can forward authentication to a Jump VM on GCP.
* Configure the Jump VM to route SSH connections securely to other Project VMs.
* Enforce least-privilege access through restricted user environments.
* Enable GitHub deployments from Project VMs using SSH agent forwarding from the local machine.

---

## **3. System Components**

### **3.1. Local Machine (MacBookPro M4)**

* Acts as the originating client with an active SSH Agent.
* Contains private GitHub SSH keys.
* Has a configured `~/.ssh/config` file to streamline access to the Jump VM and Project VMs.
* SSH agent forwarding must be enabled (`ForwardAgent yes`).
* Runs macOS and provides terminal access to initiate SSH sessions.

### **3.2. Jump VM (GCP)**

* **Purpose**: Serves as a secure intermediate SSH gateway.
* **OS**: Oracle Linux 9.
* **Location**: Hosted in GCP, accessible via external IP.

#### **Users:**

* `richard`

  * Restricted user account.
  * Default shell: `rbash` (restricted bash).
  * `$PATH`: Limited to `~/.bin`.
  * Allowed commands:

    * `su`
    * `ls`
    * `cd`
* `admin_richard`

  * Full sudo privileges.
  * No SSH login access.
  * Used for administrative tasks via privilege escalation (`su` from `richard`).

#### **Security Considerations:**

* SSH daemon configured to allow only the `richard` user.
* Agent forwarding allowed and logged.
* Use GCP firewall rules to limit access to trusted IPs only.

### **3.3. Project VMs (GCP)**

* One or more Oracle Linux 9-based servers.
* Accessible **only via the Jump VM** (no external IPs).
* Hosts target applications or services.

#### **Users:**

* `richard`

  * Restricted with `rbash`.
  * Same constraints as on the Jump VM.
* `admin_richard`

  * Full sudo access.
  * No SSH login access.

---

## **4. Functional Requirements**

| ID  | Requirement                   | Description                                                                               |
| --- | ----------------------------- | ----------------------------------------------------------------------------------------- |
| FR1 | SSH Agent Forwarding          | MacBookPro must forward the SSH agent to the Jump VM.                                     |
| FR2 | User Environment Restrictions | All cloud VMs must use `rbash` for the `richard` user with limited `$PATH`.               |
| FR3 | No Direct SSH for Admin       | `admin_richard` must not have direct SSH access; must be accessed via `su`.               |
| FR4 | Secure GitHub Access          | Project VMs must use the SSH agent forwarded from MacBookPro to authenticate with GitHub. |
| FR5 | Jump VM Access Control        | Only the `richard` user can SSH into the Jump VM; IPs are restricted via GCP firewall.    |

---

## **5. Non-Functional Requirements**

* **Security**: SSH key security, no private keys stored on cloud VMs.
* **Maintainability**: Users and permissions must be clearly documented and scripted.
* **Scalability**: Ability to add more Project VMs without architectural changes.
* **Compliance**: Enforce least-privilege and role-based access.

---

## **6. Actions Needed**

| Task                       | Description                                                                         |
| -------------------------- | ----------------------------------------------------------------------------------- |
| Create Jump VM             | Set up an Oracle Linux 9 VM on GCP with the user roles defined.                     |
| Configure Agent Forwarding | Ensure MacBookPro forwards its SSH agent to the Jump VM.                            |
| Lock Down SSH Access       | Configure sshd and firewalls to restrict access as defined.                         |
| Deploy and Test `rbash`    | Confirm `rbash` and `~/.bin` restrictions for `richard`.                            |
| Create Project VMs         | Spin up additional VMs with the same user access model.                             |
| GitHub Access              | Use SSH agent forwarding to deploy code to Project VMs using local GitHub SSH keys. |

---

## **7. Deliverables**

* Provisioned and configured Jump VM and at least one Project VM.
* SSH configuration scripts and setup instructions.
* Documentation for:

  * User role definitions and permissions.
  * GitHub deployment process using forwarded agent.
  * SSH usage examples from MacBookPro.

