# run_reports.py

import os
from jinja2 import Environment, FileSystemLoader
from reports.apparmor import AppArmorReport
from reports.suricata import SuricataReport
from reports.auditd import AuditdReport

def main():
    modules = [
        #AppArmorReport("/var/log/syslog"),
        SuricataReport("/var/log/suricata/eve.json"),
        #AuditdReport("/var/log/audit/audit.log", "audit_keys.yaml")
     ]

    for m in modules:
        m.parse_logs()

    rendered = render_html([m.generate_output() for m in modules])
    with open("security_report.html", "w") as f:
        f.write(rendered)
    print("Report written to security_report.html")

def render_html(report_data):
    env = Environment(loader=FileSystemLoader("templates"))
    env.filters['pprint'] = lambda x: '\n'.join([str(i) for i in x])
    template = env.get_template("reports.html.j2")
    return template.render(reports=report_data)

if __name__ == "__main__":
    main()
