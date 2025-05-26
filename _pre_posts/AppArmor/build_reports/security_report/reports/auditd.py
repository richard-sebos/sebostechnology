# reports/auditd.py

import re
import yaml
from .base import SecurityReport

class AuditdReport(SecurityReport):
    def __init__(self, log_source, key_file):
        super().__init__(log_source)
        self.key_file = key_file
        self.keys = []
        self.matched = {}

    def load_keys(self):
        print(f"[DEBUG] Loading keys from YAML file: {self.key_file}")
        try:
            with open(self.key_file, 'r') as f:
                data = yaml.safe_load(f)
                self.keys = data.get("audit_keys", [])
                print(f"[DEBUG] Loaded keys: {self.keys}")
                # Initialize match dictionary
                for k in self.keys:
                    self.matched[k] = []
        except FileNotFoundError:
            print(f"[ERROR] Key file {self.key_file} not found.")
        except yaml.YAMLError as e:
            print(f"[ERROR] Failed to parse YAML file: {e}")

    def parse_logs(self):
        self.load_keys()
        print(f"[DEBUG] Parsing audit log: {self.log_source}")
        try:
            with open(self.log_source, 'r') as f:
                for line_number, line in enumerate(f, 1):
                    line = line.strip()
                    print(f"[DEBUG] [Line {line_number}] {line}")
                    key_match = re.search(r'key="?([\w\-]+)"?', line)
                    if key_match:
                        key = key_match.group(1)
                        print(f"[DEBUG] Found key in log: {key}")
                        if key in self.keys:
                            print(f"[DEBUG] Matched key: {key} — Adding to results.")
                            self.matched[key].append(line)
                        else:
                            print(f"[DEBUG] Key '{key}' found but not in configured keys.")
                    else:
                        print("[DEBUG] No 'key=' found in this line.")
        except FileNotFoundError:
            print(f"[ERROR] Audit log file {self.log_source} not found.")
        except Exception as e:
            print(f"[ERROR] Failed to parse audit log: {e}")

    def summarize(self):
        summary = {k: len(v) for k, v in self.matched.items()}
        print(f"[DEBUG] Summary of matched events: {summary}")
        return summary

    def generate_output(self):
        summary = self.summarize()
        print(f"[DEBUG] Final matched event counts per key: {summary}")
        for key, events in self.matched.items():
            print(f"[DEBUG] Events for key '{key}':")
            for event in events:
                print(f"    {event}")
        return {
            "module": "Auditd",
            "summary": f"Matched keys: {', '.join(self.keys)}",
            "details": {
                k: self.matched[k][:5] for k in self.keys if self.matched.get(k)
            }
        }