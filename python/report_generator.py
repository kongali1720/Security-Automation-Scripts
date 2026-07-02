#!/usr/bin/env python3
"""
Report Generator - Generate laporan keamanan
"""

import json
import csv
import os
from datetime import datetime
from typing import Dict, List, Any
import pdfkit  # Opsional, butuh wkhtmltopdf
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
                # Cek untuk severity
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
        if not filename:
            filename = f"report_{self.timestamp.strftime('%Y%m%d_%H%M%S')}.html"
            
        summary = self.generate_summary()
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>{self.title}</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    margin: 20px;
                    background-color: #f5f5f5;
                }}
                .container {{
                    max-width: 1200px;
                    margin: 0 auto;
                    background-color: white;
                    padding: 20px;
                    border-radius: 10px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }}
                .header {{
                    background-color: #2c3e50;
                    color: white;
                    padding: 20px;
                    border-radius: 10px 10px 0 0;
                    margin: -20px -20px 20px -20px;
                }}
                .summary {{
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 20px;
                    margin-bottom: 30px;
                }}
                .summary-card {{
                    background-color: #ecf0f1;
                    padding: 15px;
                    border-radius: 5px;
                    text-align: center;
                }}
                .summary-card .number {{
                    font-size: 24px;
                    font-weight: bold;
                    color: #2c3e50;
                }}
                .summary-card .label {{
                    color: #7f8c8d;
                    margin-top: 5px;
                }}
                .section {{
                    margin-bottom: 30px;
                    padding: 15px;
                    background-color: #f8f9fa;
                    border-radius: 5px;
                }}
                .section-title {{
                    font-size: 18px;
                    font-weight: bold;
                    color: #2c3e50;
                    margin-bottom: 10px;
                }}
                .data-table {{
                    width: 100%;
                    border-collapse: collapse;
                }}
                .data-table th, .data-table td {{
                    border: 1px solid #ddd;
                    padding: 8px;
                    text-align: left;
                }}
                .data-table th {{
                    background-color: #34495e;
                    color: white;
                }}
                .severity-critical {{ color: #e74c3c; }}
                .severity-high {{ color: #e67e22; }}
                .severity-medium {{ color: #f1c40f; }}
                .severity-low {{ color: #2ecc71; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>{self.title}</h1>
                    <p>Generated: {self.timestamp.strftime('%Y-%m-%d %H:%M:%S')}</p>
                </div>
                
                <div class="summary">
                    <div class="summary-card">
                        <div class="number">{summary['total_entries']}</div>
                        <div class="label">Total Entries</div>
                    </div>
                    <div class="summary-card">
                        <div class="number">{summary['critical_issues']}</div>
                        <div class="label">Critical Issues</div>
                    </div>
                    <div class="summary-card">
                        <div class="number">{summary['high_issues']}</div>
                        <div class="label">High Issues</div>
                    </div>
                    <div class="summary-card">
                        <div class="number">{summary['medium_issues']}</div>
                        <div class="label">Medium Issues</div>
                    </div>
                </div>
                
                <h2>Detailed Data</h2>
        """
        
        for section_name, data in self.data.items():
            html += f'<div class="section"><div class="section-title">{section_name}</div>'
            
            if isinstance(data, dict):
                html += '<table class="data-table"><tr><th>Key</th><th>Value</th></tr>'
                for key, value in data.items():
                    html += f'<tr><td>{key}</td><td>{value}</td></tr>'
                html += '</table>'
            elif isinstance(data, list):
                html += '<ul>'
                for item in data:
                    html += f'<li>{item}</li>'
                html += '</ul>'
                
            html += '</div>'
            
        html += """
            </div>
        </body>
        </html>
        """
        
        with open(filename, 'w') as f:
            f.write(html)
        print(f"[✓] HTML report saved to {filename}")
        
        return html
    
    def generate_pdf(self, filename: str = None) -> None:
        """Generate PDF report (membutuhkan pdfkit)"""
        try:
            html = self.generate_html('temp.html')
            if not filename:
                filename = f"report_{self.timestamp.strftime('%Y%m%d_%H%M%S')}.pdf"
            pdfkit.from_file('temp.html', filename)
            os.remove('temp.html')
            print(f"[✓] PDF report saved to {filename}")
        except ImportError:
            print("[!] pdfkit not installed. Install with: pip install pdfkit")
        except Exception as e:
            print(f"[!] Error generating PDF: {e}")

# Contoh penggunaan
if __name__ == "__main__":
    generator = SecurityReportGenerator("Security Audit Report")
    
    # Tambah data
    generator.add_section("Vulnerabilities", {
        'SQL Injection': '3 found',
        'XSS': '2 found',
        'CSRF': '1 found'
    })
    
    generator.add_section("Scan Results", [
        '192.168.1.1 - Open Ports: 22, 80, 443',
        '192.168.1.2 - Open Ports: 22, 3306'
    ])
    
    generator.add_section("Recommendations", {
        'severity': 'high',
        'actions': [
            'Patch vulnerable services',
            'Update firewall rules',
            'Enable 2FA'
        ]
    })
    
    # Export dalam berbagai format
    generator.export_json()
    generator.export_csv()
    generator.generate_html()
