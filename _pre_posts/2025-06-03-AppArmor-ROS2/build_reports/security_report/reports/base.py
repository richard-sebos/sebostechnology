# reports/base.py

from abc import ABC, abstractmethod

class SecurityReport(ABC):
    def __init__(self, log_source):
        self.log_source = log_source
        self.events = []

    @abstractmethod
    def parse_logs(self):
        pass

    @abstractmethod
    def summarize(self):
        pass

    @abstractmethod
    def generate_output(self):
        pass
