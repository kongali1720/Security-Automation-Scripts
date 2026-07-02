#!/usr/bin/env python3
"""
Log Analyzer - Menganalisis file log untuk pola keamanan
"""

import re
import json
import argparse
from datetime import datetime
from collections import Counter
from typing import Dict, List, Tuple

class LogAnalyzer:
    def __init__(self, log_file: str):
        self.log_file = log_file
        self.logs = []
        self.suspicious_patterns = {
            'failed_login': r'(?i)(failed|invalid).*?(login|password|user)',
            'sudo_access': r'(?i)sudo.*?(command|exec)',
            'root_access': r'(?i)root.*?(login|access)',
            'ssh_connection': r'(?i)sshd.*?(accepted|connection)',
            'malicious_ip': r'(?i)from\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})',
            'error_critical': r'(?i)(error|critical|fatal|panic)',
        }
        
    def load_logs(self) -> None:
        """Membaca file log"""
        try:
            with open(self.log_file, 'r', encoding='utf-8', errors='ignore') as f:
                self.logs = f.readlines()
            print(f"[✓] Berhasil membaca {len(self.logs)} baris log")
        except FileNotFoundError:
            print(f"[✗] File log '{self.log_file}' tidak ditemukan")
            exit(1)
            
    def analyze_patterns(self) -> Dict[str, List[str]]:
        """Menganalisis pattern keamanan"""
        results = {key: [] for key in self.suspicious_patterns.keys()}
        
        for line_num, line in enumerate(self.logs, 1):
            for pattern_name, pattern_regex in self.suspicious_patterns.items():
                if re.search(pattern_regex, line):
                    results[pattern_name].append({
                        'line': line_num,
                        'content': line.strip()
                    })
                    
        return results
    
    def extract_ips(self) -> List[str]:
        """Ekstrak alamat IP dari log"""
        ip_pattern = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
        ips = re.findall(ip_pattern, ' '.join(self.logs))
        return list(set(ips))
    
    def generate_report(self) -> str:
        """Generate report dalam format JSON"""
        pattern_results = self.analyze_patterns()
        ips = self.extract_ips()
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'log_file': self.log_file,
            'statistics': {
                'total_entries': len(self.logs),
                'suspicious_entries': sum(len(v) for v in pattern_results.values()),
                'unique_ips': len(ips)
            },
            'suspicious_patterns': {
                k: len(v) for k, v in pattern_results.items()
            },
            'ips_found': ips[:10],
            'details': pattern_results
        }
        
        return json.dumps(report, indent=2)

def main():
    parser = argparse.ArgumentParser(description='Log Analyzer untuk keamanan')
    parser.add_argument('-f', '--file', required=True, help='Path ke file log')
    parser.add_argument('-o', '--output', help='Output file (opsional)')
    parser.add_argument('--json', action='store_true', help='Output dalam format JSON')
    
    args = parser.parse_args()
    
    analyzer = LogAnalyzer(args.file)
    analyzer.load_logs()
    
    if args.json:
        report = analyzer.generate_report()
        if args.output:
            with open(args.output, 'w') as f:
                f.write(report)
            print(f"[✓] Report disimpan ke {args.output}")
        else:
            print(report)
    else:
        results = analyzer.analyze_patterns()
        print("\n=== LOG ANALYSIS SUMMARY ===")
        for pattern, matches in results.items():
            print(f"{pattern}: {len(matches)} ditemukan")
        
        ips = analyzer.extract_ips()
        print(f"\nIP Address ditemukan: {len(ips)}")
        if ips:
            print("Top 5 IPs:")
            for ip in ips[:5]:
                print(f"  - {ip}")

if __name__ == "__main__":
    main()
