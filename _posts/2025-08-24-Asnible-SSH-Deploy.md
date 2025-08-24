---
title: "Modular SSH Configuration with Ansible"
date: 2025-08-23 12:00:00 +0000
categories: [DevOps, Linux, Security]
tags: [Ansible, SSH, SSHD, Automation, Linux Hardening, SysAdmin, Infrastructure]
excerpt: "Learn how to secure and standardize your SSHD configuration using a modular approach and Ansible automation. Improve security posture, manage complexity, and scale your configurations with ease."
image: 
  path: /assets/img/ModularSSHAnsible.png
  alt: "Streamline deployment of SSH security policies"
---

## **Introduction**

With SSH being one of the primary attack vectors in modern infrastructure, hardening the SSH daemon (`sshd`) is a critical step in any system security strategy. Ideally, your organization maintains a standardized `sshd_config` file, reviewed periodically for compliance and security posture. However, reality often differs. In practice, environments typically fall into one of three categories: each server has its own SSH use case and configuration; many servers run with the default settings; or a new project begins with fresh infrastructure, providing an opportunity to set a standard from the start.

So, why is this the case? It's often a mix of legacy practices, diverse operational requirements, and the overwhelming nature of the default SSH configuration itself.

## **Table of Contents**

1. [Introduction](#introduction)
2. [The Default SSHD Configuration](#the-default-sshd-configuration)
3. [Modular SSH Configuration Design](#modular-ssh-configuration-design)
4. [Ansible Role Design and Layout](#ansible-role-design-and-layout)
5. [Conclusion](#conclusion)

---


## **The Default SSHD Configuration**

The default `sshd_config` file provided by OpenSSH is comprehensive and serves as both a configuration file and an inline manual. This duality is helpful, but it can also be overwhelming—especially for new users. For instance, on one system running a modern OpenSSH version, the default config contained 129 lines, with only three lines uncommented. The remaining lines served as documentation and disabled settings.

While these comments are valuable for understanding available options, they can obscure clarity and make it harder to manage or audit settings in production environments. The key challenge becomes: how do you maintain readability and flexibility without compromising security?

---

## **Modular SSH Configuration Design**

Coming from a programming background, I naturally tend to break down complex systems into modular components. Applying the same principle to SSH server configuration has resulted in a structure that supports consistent security policies, simplified updates, and environment-specific customizations.

By splitting the monolithic `/etc/ssh/sshd_config` file into logical modules using the `Include` directive, we can apply a role-based configuration structure that is easy to manage and reuse. The breakdown includes key configuration files such as:

* `04-logging.conf` – controls verbose logging and SyslogFacility.
* `05-banner.conf` – sets custom login banners and legal warnings.
* `06-session.conf` – defines session timeouts, keepalives, and connection throttling.
* `07-authentication.conf` – manages authentication methods, PAM integration, and user limits.
* `08-access-control.conf` – applies IP- and group-based access restrictions.
* `10-forwarding.conf` – disables agent, TCP, and X11 forwarding by default.
* `11-admin-exceptions.conf` – creates scoped exceptions for trusted admin access.
* `20-mfa.conf` – enforces multi-factor authentication using public key + PAM 2FA.
* `30-High-Vol.conf` – supports large-scale environments with high login frequency.
* `40-crypto.conf` – enforces modern cryptographic algorithms and key exchange methods.
* `99-hardening.conf` – applies miscellaneous hardening options.

Is this the best or only approach? Probably not. But it has worked reliably for me, delivering consistent, repeatable results across environments.

A common concern with modular design is deployment complexity—but with the help of configuration management tools like Ansible, this concern can be addressed effectively.

---

## **Ansible Role Design and Layout**

To streamline deployment, I developed an Ansible Role that encapsulates this modular SSH configuration structure. This role is organized into the following directory layout:

```
roles/build_ssh/
├── files/         → Base configuration (e.g., main sshd_config)
├── templates/     → Jinja2 templates for dynamic config generation
├── default/       → Centralized variable definitions
├── tasks/         → Main logic and sequencing
├── handlers/      → Restart logic for the SSH service
```

* The `files` directory contains static configuration files that rarely change.
* The `templates` and `defaults` directories are used to dynamically render `.conf` files that vary across environments—such as crypto policies, session rules, or access control.
* The `tasks` directory houses the core Ansible logic that ties everything together.
* The `handlers` directory includes restart handlers for applying SSH configuration changes.

This approach enables the creation of a standardized SSH server configuration while allowing for environment-specific customizations. It offers a balance between control and flexibility, letting you build consistent configurations and then adapt them for special requirements as needed.

---

## **Conclusion**

By combining modular configuration with Ansible automation, this approach provides a production-ready SSH hardening framework. It simplifies compliance, improves maintainability, and enforces centralized access control policies.

**Next steps for adoption might include:**
* Explore integrating this approach into your team's existing workflows, such as using version control (like Git) or simple automation tools. Over time, this can evolve into more advanced CI/CD or GitOps-style pipelines.

* Look into adding basic audit or monitoring features—such as logging access events or changes to SSH settings—to improve visibility and make troubleshooting easier.

Through modular design and automation, we can treat SSH not just as a secure access method—but as a well-engineered component of your infrastructure’s security baseline.




