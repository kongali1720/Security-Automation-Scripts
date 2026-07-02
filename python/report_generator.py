#!/usr/bin/env python3
"""
Report Generator - Generate laporan keamanan
"""

import json
import csv
import os
from datetime import datetime
from typing import Dict, List, Any
import pdfkit
import matplotlib.pyplot as plt
import seaborn as sns

class SecurityReportGenerator:
    def __init__(self, title: str = "Security Report"):
        self.title = title
        self.data = {}
        self.timestamp = datetime.now()
        
    def add_section(self, section_name: str, data: Dict) -> None:
        """Tambah section ke report"""
        self.data[section_name] = data
        
    def generate_summary(self) -> Dict:
        """Generate summary dari data"""
        summary = {
            'report_title': self.title,
            'generated_at': self.timestamp.isoformat(),
            'sections': len(self.data),
            'total_entries': 0,
            'critical_issues': 0,
            'high_issues': 0,
            'medium_issues': 0,
            'low_issues': 0
        }
        
        for section, data in self.data.items():
            if isinstance(data, dict):
                summary['total_entries'] += len(data)
                if 'severity' in data:
                    if data['severity'] == 'critical':
                        summary['critical_issues'] += 1
                    elif data['severity'] == 'high':
                        summary['high_issues'] += 1
                    elif data['severity'] == 'medium':
                        summary['medium_issues'] += 1
                    elif data['severity'] == 'low':
                        summary['low_issues'] += 1
                        
        return summary
    
    def export_json(self, filename: str = None) -> None:
        """Export ke JSON"""
        if not filename:
            filename = f"report_{self.timestamp.strftime('%Y%m%d_%H%M%S')}.json"
            
        report = {
            'title': self.title,
            'timestamp': self.timestamp.isoformat(),
            'summary': self.generate_summary(),
            'data': self.data
        }
        
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        print(f"[✓] JSON report saved to {filename}")
        
    def export_csv(self, filename: str = None) -> None:
        """Export ke CSV"""
        if not filename:
            filename = f"report_{self.timestamp.strftime('%Y%m%d_%H%M%S')}.csv"
            
        with open(filename, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['Section', 'Key', 'Value'])
            
            for section, data in self.data.items():
                if isinstance(data, dict):
                    for key, value in data.items():
                        writer.writerow([section, key, str(value)])
                elif isinstance(data, list):
                    for item in data:
                        writer.writerow([section, '', str(item)])
                        
        print(f"[✓] CSV report saved to {filename}")
        
    def generate_html(self, filename: str = None) -> str:
        """Generate HTML report"""
        if not filename
