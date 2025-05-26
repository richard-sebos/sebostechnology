import subprocess
from .base import SecurityReport

class AppArmorReport(SecurityReport):
    def parse_logs(self):
        self.denials = []
        self.complain_events = []
        self.enforced_profiles = []
        self.complain_profiles = []

        self._parse_profiles()
        self._parse_events()

    def _parse_profiles(self):
        try:
            result = subprocess.run(["aa-status"], capture_output=True, text=True, check=True)
            output = result.stdout
            current_section = None

            for line in output.splitlines():
                if "profiles are in enforce mode" in line:
                    current_section = "enforce"
                    continue
                if "profiles are in complain mode" in line:
                    current_section = "complain"
                    continue
                if line.startswith((" ", "\t")):
                    profile = line.strip()
                    if current_section == "enforce":
                        self.enforced_profiles.append(profile)
                    elif current_section == "complain":
                        self.complain_profiles.append(profile)
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] aa-status failed: {e}")
        except Exception as e:
            print(f"[ERROR] Failed to parse aa-status output: {e}")

    def _parse_events(self):
        try:
            result = subprocess.run(
                ["journalctl", "-k", "-o", "short"], capture_output=True, text=True, check=True
            )
            for line in result.stdout.splitlines():
                if "apparmor=" in line:
                    if "DENIED" in line:
                        self.denials.append(line.strip())
                    elif 'apparmor="ALLOWED"' in line:
                        self.complain_events.append(line.strip())
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] journalctl failed: {e}")
        except Exception as e:
            print(f"[ERROR] Failed to parse AppArmor events: {e}")

    def summarize(self):
        return {
            "enforced_profiles": len(self.enforced_profiles),
            "complain_profiles": len(self.complain_profiles),
            "denials": len(self.denials),
            "complain_events": len(self.complain_events),
        }

    def generate_output(self):
        summary = self.summarize()
        return {
            "module": "AppArmor",
            "summary": (
                f"{summary['enforced_profiles']} enforced, "
                f"{summary['complain_profiles']} complain mode, "
                f"{summary['denials']} denials, "
                f"{summary['complain_events']} complain events."
            ),
            "details": {
                "Enforced Profiles": self.enforced_profiles or ["No enforced profiles found."],
                "Complain Mode Profiles": self.complain_profiles or ["No complain mode profiles found."],
                "Denied Events": self.denials[:10] or ["No denial events found."],
                "Complain Events": self.complain_events[:10] or ["No complain events found."],
            }
        }
