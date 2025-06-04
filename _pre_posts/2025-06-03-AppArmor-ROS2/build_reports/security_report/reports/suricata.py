# reports/suricata.py

import json
from .base import SecurityReport

class SuricataReport(SecurityReport):
    def parse_logs(self):
        print(f"[DEBUG] Parsing Suricata logs from {self.log_source}")
        try:
            with open(self.log_source, 'r') as f:
                for line_number, line in enumerate(f, 1):
                    line = line.strip()
                    try:
                        event = json.loads(line)
                        if event.get("event_type") == "alert":
                            print(f"[DEBUG] [Line {line_number}] Alert Found: {event}")
                            self.events.append(event)
                    except json.JSONDecodeError:
                        print(f"[DEBUG] [Line {line_number}] JSON decode error.")
        except FileNotFoundError:
            print(f"[ERROR] Suricata log file {self.log_source} not found.")

    def summarize(self):
        total_alerts = len(self.events)
        high_severity = sum(1 for e in self.events if e.get("alert", {}).get("severity", 5) <= 2)
        return {
            "total_alerts": total_alerts,
            "high_severity": high_severity
        }

    def generate_output(self):
        summary = self.summarize()
        return {
            "module": "Suricata",
            "summary": f"{summary['total_alerts']} alerts, {summary['high_severity']} high-severity",
            "details": {
                "High Severity Alerts": [
                    f"{e['alert']['signature']} (Severity: {e['alert']['severity']})"
                    for e in self.events if e.get('alert', {}).get('severity', 5) <= 2
                ],
                "Other Alerts": [
                    f"{e['alert']['signature']} (Severity: {e['alert']['severity']})"
                    for e in self.events if e.get('alert', {}).get('severity', 5) > 2
                ]
            }
        }
