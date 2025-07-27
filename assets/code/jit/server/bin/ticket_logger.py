"""
ticket_logger.py

This module defines a class `TicketLogger` that logs user access tickets
to an SQLite database for auditing or JIT access tracking.

Each ticket contains:
- a unique ID
- the username
- the reason for access
- a UTC timestamp

Author: Richard Chamberlain
"""
# ticket_logger.py

"""
Handles logging and auditing of JIT SSH access tickets.
Supports both flat file and SQLite-based storage for flexibility.
"""

import sqlite3
import os
from datetime import datetime

class TicketLogger:
    def __init__(self, db_path="./db/tickets.sqlite", log_path="./db/access.log"):
        """
        Args:
            db_path (str): Path to the SQLite database file.
            log_path (str): Path to a text file for flat log format (optional).
        """
        self.db_path = db_path
        self.log_path = log_path
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        self._initialize_db()

    def _initialize_db(self):
        """
        Initialize the SQLite database and create table if it doesn't exist.
        """
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS tickets (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user TEXT NOT NULL,
                    reason TEXT NOT NULL,
                    timestamp TEXT NOT NULL
                )
            ''')
            conn.commit()

    def log_ticket(self, username, reason):
        """
        Log an entry to SQLite with timestamp.

        Args:
            username (str): Username requesting access.
            reason (str): Reason provided for the JIT request.
        """
        timestamp = datetime.utcnow().isoformat() + "Z"
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                'INSERT INTO tickets (user, reason, timestamp) VALUES (?, ?, ?)',
                (username, reason, timestamp)
            )
            conn.commit()

    def log(self, username, reason):
        """
        Log an entry to both SQLite and flat file.

        Args:
            username (str): Username requesting access.
            reason (str): Reason for access.
        """
        self.log_ticket(username, reason)

        timestamp = datetime.utcnow().isoformat()
        log_entry = f"{timestamp} - {username} - {reason}\n"
        with open(self.log_path, "a") as f:
            f.write(log_entry)

    def list_tickets(self):
        """
        Return all stored tickets from the database.

        Returns:
            List[Tuple]: (id, user, reason, timestamp)
        """
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                'SELECT id, user, reason, timestamp FROM tickets ORDER BY id DESC'
            )
            return cursor.fetchall()

