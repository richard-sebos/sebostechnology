---
title: Grafana — The Single Pane of Glass
subtitle: Centralizing Security and Observability Data from Prometheus, Loki, and OpenSCAP into One Dashboard
date: 2026-03-22 10:00 +0000
categories: [Linux, Security]
tags: [Grafana, Prometheus, Loki, OpenSCAP, Observability, Security, Monitoring, EnterpriseLinux, Dashboard]
image:
  path: /assets/img/Grafana.png
  alt: Grafana dashboard centralizing security and observability data for enterprise Linux environments
---

> *"The ability to simplify means to eliminate the unnecessary so that the necessary may speak."* — Hans Hofmann

---

## 🧱 Building Without Seeing the Whole Picture

I don't remember playing with Lego as a kid, but I vividly remember watching my kids play with it. There's something genuinely satisfying about watching a child sort through a bin of bricks and start building something without a plan. It started small — a few simple kits, the kind with maybe 50 pieces and a picture on the box. Each kit built one thing. A car. A house. A spaceship. They were self-contained, and they were great.

Then my son inherited his uncle's Lego collection. Suddenly the bin tripled in size, and the possibilities shifted completely. It wasn't just about following the instructions for a specific kit anymore. He could take the wheels from one set, the cockpit from another, the landing struts from a third, and build something none of those kits were ever designed to make. As the number of pieces grew, so did what could be built — but only because those pieces were all designed to connect with each other.

That's the analogy I keep coming back to when I think about IT security tooling. The tools we've built across this series — Prometheus, Loki, OpenSCAP — are each excellent at what they do. But they were never meant to live in separate bins.

---

This article is part of an ongoing series documenting the build-out of a Linux-based corporate desktop and server environment. The previous article covered OpenSCAP — how compliance scanning was integrated across Rocky Linux, Ubuntu, and Fedora Kinoite desktops, and how scan results were fed into Prometheus via SCAPinoculars. If you haven't read [that article](https://richard-sebos.github.io/sebostechnology/posts/OpenSCAP/) yet, it provides important context for how the compliance data surfaces in Grafana.

This article is about Grafana: what it is, how it ties the rest of the stack together, and what becomes possible when all that data lives in one place.

---

## Table of Contents

1. [The Problem: Too Many Tools, Too Little Time](#the-problem-too-many-tools-too-little-time)
2. [What Is Grafana?](#what-is-grafana)
3. [How Grafana Ties It Together](#how-grafana-ties-it-together)
4. [The Benefits of a Single Pane of Glass](#the-benefits-of-a-single-pane-of-glass)
5. [Why Do This?](#why-do-this)
6. [Part of a Larger Journey](#part-of-a-larger-journey)

---

## 🔍 The Problem: Too Many Tools, Too Little Time

In corporate security, the different tools in your stack are a lot like those individual Lego kits. Each one is designed to do a specific job, and each one does it reasonably well. Prometheus monitors system metrics. Loki collects and indexes logs. OpenSCAP scans for compliance drift. On their own, all three are useful.

The problem is that organizations — and the IT teams inside them — tend to be siloed. The operations team watches Prometheus. The security team checks the compliance reports. The sysadmin scrolling through logs in Loki is a different person from the one who gets paged when a metric crosses a threshold. Each team has their own tool, their own dashboard, their own definition of "something's wrong."

What gets lost in that fragmentation is correlation. A spike in failed SSH login attempts, a compliance rule that just failed on the same host, and a memory anomaly happening at the same moment — those three data points together tell a very different story than each one does alone. But if the people watching those three tools aren't talking to each other in real time, or if they're not even looking at the same screen, that story never gets told until after the damage is done.

This is the gap that Grafana is designed to close.

---

## ⚙️ What Is Grafana?

Grafana is fundamentally a visualization, observability, and reporting platform — not a security tool. That distinction matters. Grafana does not collect data. It does not store logs, scrape metrics, or run compliance scans. What it does is connect to the systems that do all of those things, and give you a single, coherent window into all of them at once.

It started life as a dashboard tool for Graphite and InfluxDB time-series databases — a better way to look at graphs than whatever those tools shipped with natively. Over the years it grew into a full observability platform, adding support for dozens of data source plugins, a sophisticated alerting engine, and a rich panel library for visualizing almost any kind of data.

The core concepts are worth understanding before connecting anything:

* **Dashboards** are the visual layer. A dashboard is a collection of panels arranged on a page. You can have one dashboard per team, per service, or one that shows everything — it is up to you.
* **Panels** are the individual visualizations that make up a dashboard. A panel can be a time-series graph, a table, a stat block showing a single value, a heatmap, an alert list, or a log stream viewer. Each panel runs one or more queries against a data source.
* **Data Sources** are the plugins that connect Grafana to external systems. Prometheus, Loki, and many others are supported natively. Connecting a data source tells Grafana where to send queries — it does not move or copy any data.
* **Alerts** are rules that run queries on a schedule and fire notifications when results cross a defined threshold. Grafana can send those notifications to email, Slack, PagerDuty, or any number of other destinations.

What Grafana is not: it is not a database, not a log collector, and not a compliance scanner. It is the window into all of those things. That is both its strength and its design philosophy — stay out of the data pipeline and focus entirely on making the data useful.

For this series, that design is exactly what the stack needs. Everything built so far — Prometheus for metrics, Loki for logs, OpenSCAP for compliance results via SCAPinoculars — already speaks a language Grafana understands. The pieces are already in the bin. Grafana is what lets you build something with all of them at once.

---

## 🔧 How Grafana Ties It Together

The real power of Grafana in this environment is not any single feature — it is the connective layer it provides across the tools built throughout this series.

**Prometheus** connects as a native data source. Once connected, every metric that Prometheus has been scraping — CPU load, memory usage, disk I/O, network throughput, custom exporter data from all the servers and Kinoite desktops — becomes available for visualization without opening a terminal or writing raw PromQL at the command line. The metrics that have been collecting since article six are ready to become panels.

**Loki** connects the same way. Once added as a data source, log streams from every host running Promtail become queryable inside Grafana. More importantly, log panels and metric panels can be placed on the same dashboard, sharing the same time axis. When a CPU spike appears in a graph, you can look immediately at the log stream from the same host at the same moment and see what was happening. That correlation — metric and log, side by side, in real time — is not something you can easily replicate by switching between tabs.

**OpenSCAP** feeds into Grafana through Prometheus. The SCAPinoculars exporter, configured in article eight, translates compliance pass/fail counts into Prometheus metrics. That means compliance state is just another data source in Grafana — another panel on the same dashboard, with the same time controls and the same alert capability as everything else. A compliance failure is no longer something discovered in a quarterly report review. It shows up on the screen next to the metrics and logs, at the time it happened.

The specific configuration steps for each data source connection — adding Prometheus and Loki to Grafana, building the initial dashboards, writing the alert rules — will be covered in follow-up articles in this series. This article is about understanding what becomes possible before diving into the mechanics. The architecture is the point here, not the click sequence.

What that architecture enables is a single timeline where a compliance failure, a spike in failed logins, and a memory anomaly can all appear simultaneously, attributed to the same host, queryable from the same screen. That is a fundamentally different way of looking at infrastructure health than three separate tools in three separate browser tabs.

---

## 📊 The Benefits of a Single Pane of Glass

The phrase "single pane of glass" gets used a lot in the monitoring world, often as marketing language for products that claim to unify everything but deliver a mediocre experience with all of it. Grafana earns the description differently — not by replacing the underlying tools, but by leaving them intact and providing a genuinely useful visualization layer on top.

**Time to insight** is the most immediate benefit. Jumping between the Prometheus web interface, a Loki query session, and a folder of OpenSCAP HTML reports is slow. It requires context switching, and it requires whoever is investigating to mentally correlate information that was never presented together. One dashboard collapses that. Answers that used to take twenty minutes of tab-hopping take seconds when the relevant panels are already in front of you.

**Correlation** is where the real operational value shows up. Events that look insignificant in isolation often look significant in context. A compliance rule failing on one host is a note to follow up on. That same compliance failure appearing on the same dashboard as an authentication anomaly and a memory spike — all within the same fifteen-minute window — is an incident. The tools were always capable of surfacing those data points. Grafana makes the connection visible.

**Consistency** matters more than it sounds, especially in environments where multiple people are responsible for different parts of the stack. When one person's first instinct is to check Prometheus and another's is to check Loki, there will be gaps. One place for the team to look removes the "I saw it in Prometheus but forgot to check the logs" failure mode.

**Alerting in one place** removes the overhead of maintaining separate notification rules in separate systems. Grafana can fire alerts based on queries against any connected data source — which means one alerting configuration covers metrics, logs, and compliance state, with one set of notification destinations and one set of escalation rules.

**Historical context** is something that gets underappreciated until you need it. Grafana's time-range controls apply simultaneously across all panels on a dashboard. If you want to look at what was happening across the entire stack at 2:00 AM last Thursday, you adjust one control and every panel shifts to that window. Doing that across separate tools requires either discipline or luck.

**Visibility without expertise** is important for teams where not everyone is comfortable with PromQL or LogQL. A dashboard built by someone who knows the query languages is accessible to anyone who knows how to read a graph. That lowers the barrier for other team members to be part of monitoring — and in a small IT team, that breadth of awareness matters.

**Audit-readiness** is the compliance benefit that replaces the static HTML report workflow. Instead of generating reports that sit in a directory until someone remembers to look at them, compliance state becomes a live panel. Pass rates, failure counts, and trend lines are always current, always visible, and always correlated with the rest of the operational data.

One dashboard to look at instead of three. That is not a small thing.

---

## 🎯 Why Do This?

Looking back at the Lego analogy: the pieces were always there. Prometheus has been collecting metrics since article six. Loki has been aggregating logs since article seven. OpenSCAP has been running compliance scans and feeding results to Prometheus since article eight. Those tools were doing their jobs the whole time.

Grafana does not add complexity to this stack — it removes it. It is the step that takes three separate workflows and turns them into one coherent operational picture. The data that was already being collected becomes genuinely useful for a broader audience: the security team, the operations team, and the business owner who needs to demonstrate compliance without generating a manual report.

The follow-up articles in this series will walk through the actual configuration: connecting Prometheus and Loki as data sources, building dashboards that answer real security and operational questions, and setting up alert rules that surface problems before someone notices them the hard way.

But the premise is worth stating plainly before getting into the mechanics. The best security posture is not the one with the most tools — it is the one where you can see everything clearly enough to act on it.

---

## Part of a Larger Journey

Over the next 3-6 months, I plan to build out this environment and document the process through a series of articles covering:

* Article 1: [Introduction - Why this project matters and what Linux can offer businesses](https://richard-sebos.github.io/sebostechnology/posts/Exploring-Enterprise-Security/)
* Article 2: [Proxmox Virtualization Best Practices - Setting up a robust virtualization foundation](https://richard-sebos.github.io/sebostechnology/posts/Proxmox-Prototype/)
* Article 3: [Making Linux Work as a Corporate Desktop](https://richard-sebos.github.io/sebostechnology/posts/Linux-Corporate-Desktop-Usability-Security/)
* Article 4: [OS Updates on the Corporate Linux Desktop](https://richard-sebos.github.io/sebostechnology/posts/OSTree/)
* Article 5: [Enterprise Desktop Update Lifecycle with Kinoite](https://richard-sebos.github.io/sebostechnology/posts/Lifecycle-with-Kinoite/)
* Article 6: [Bringing Prometheus Monitoring to the Linux Corporate Desktop](https://richard-sebos.github.io/sebostechnology/posts/Prometheus-Desktop/)
* Article 7: [Loki: From Naming Servers After Gods to Monitoring Them](https://richard-sebos.github.io/sebostechnology/posts/Loki/)
* Article 8: [OpenSCAP: Compliance Scanning for the Linux Corporate Desktop](https://richard-sebos.github.io/sebostechnology/posts/OpenSCAP/)
* Article 9: **Grafana: The Single Pane of Glass** *(this article)*
* Articles 10-12: SMB Infrastructure Planning, Ansible Automation, Core Services (AD/File/Print)

### My goals are to:

* Help business owners understand that there are viable alternatives for securing their systems
* Highlight what Linux-based systems are capable of in real-world business environments
* Provide practical tools, configurations, and guidance for users who are new to Linux as well as experienced IT professionals
* Continue developing my own skills in Linux-based security and infrastructure design

### Call to Action

Whether you're evaluating alternatives to expensive licensing, building your first Linux infrastructure, or simply curious about enterprise security on open-source platforms — I'd love to hear from you.

If you are a business owner, system administrator, or IT professional interested in improving security without relying solely on expensive licensing and third-party tools, I invite you to follow along. Experiment with these ideas, ask questions, challenge assumptions, and share your experiences. Together, we can explore what a secure, Linux-based business environment can look like in practice.

---

**Need Linux expertise?** I help businesses streamline servers, secure infrastructure, and automate workflows. Whether you're troubleshooting, optimizing, or building from scratch — I've got you covered.
📬 Drop a comment or [email me](mailto:info@sebostechnology.com) to collaborate. For more tutorials, tools, and insights, visit [sebostechnology.com](https://sebostechnology.com).

---

☕ **Did you find this article helpful?**
Consider supporting more content like this by buying me a coffee:
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow)](https://www.buymeacoffee.com/sebostechnology)
Your support helps me write more Linux tips, tutorials, and deep dives.

[https://www.buymeacoffee.com/sebostechnology](https://www.buymeacoffee.com/sebostechnology)
