#!/usr/bin/env python3
"""
Log Parser - Mem-parsing berbagai format log
"""

import re
import csv
import json
from typing import Dict, List, Optional
from datetime import datetime

class LogParser:
    def __init__(self, log_content: str):
        self.content = log_content
        self.parsed_entries = []
        
    def parse_apache_log(self) -> List[Dict]:
        """Parse Apache access log"""
        pattern = r'(?P<ip>\S+) \S+ \S+ \[(?P<time>.*?)\] "(?P<method>\S+) (?P<path>\S+) \S+" (?P<status>\d+) (?P<size>\S+)'
        matches = re.finditer(pattern, self.content)
        
        for match in matches:
            self.parsed_entries.append({
                'type': 'apache',
                'ip': match.group('ip'),
                'timestamp': match.group('time'),
                'method': match.group('method'),
                'path': match.group('path'),
                'status': int(match.group('status')),
                'size': match.group('size')
            })
        return self.parsed_entries
    
    def parse_syslog(self) -> List[Dict]:
        """Parse syslog format"""
        pattern = r'(?P<timestamp>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2}) (?P<host>\S+) (?P<service>\S+?)(?:\[(?P<pid>\d+)\])?: (?P<message>.*)'
        matches = re.finditer(pattern, self.content)
        
        for match in matches:
            self.parsed_entries.append({
                'type': 'syslog',
                'timestamp': match.group('timestamp'),
                'host': match.group('host'),
                'service': match.group('service'),
                'pid': match.group('pid'),
                'message': match.group('message')
            })
        return self.parsed_entries
    
    def parse_json_log(self) -> List[Dict]:
        """Parse JSON log format"""
        try:
            if self.content.strip().startswith('['):
                data = json.loads(self.content)
                if isinstance(data, list):
                    for entry in data:
                        entry['type'] = 'json'
                        self.parsed_entries.append(entry)
            else:
                data = json.loads(self.content)
                data['type'] = 'json'
                self.parsed_entries.append(data)
        except json.JSONDecodeError:
            print("[!] Invalid JSON format")
        return self.parsed_entries
    
    def filter_by_time(self, start_time: str, end_time: str) -> List[Dict]:
        """Filter entries by time range"""
        filtered = []
        for entry in self.parsed_entries:
            if 'timestamp' in entry:
                filtered.append(entry)
        return filtered
    
    def export_csv(self, filename: str) -> None:
        """Export parsed entries to CSV"""
        if not self.parsed_entries:
            print("[!] No data to export")
            return
            
        keys = self.parsed_entries[0].keys()
        with open(filename, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            writer.writerows(self.parsed_entries)
        print(f"[✓] Exported to {filename}")

if __name__ == "__main__":
    sample_log = '192.168.1.1 - - [10/Oct/2023:13:55:36] "GET /index.html HTTP/1.1" 200 2326'
    parser = LogParser(sample_log)
    parser.parse_apache_log()
    print(json.dumps(parser.parsed_entries, indent=2))
