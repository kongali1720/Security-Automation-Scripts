#!/usr/bin/env python3
"""
IOC Extractor - Ekstrak Indicator of Compromise dari log
"""

import re
import json
import hashlib
from typing import List, Dict, Set
from urllib.parse import urlparse
import socket

class IOCExtractor:
    def __init__(self):
        self.iocs = {
            'ip_addresses': set(),
            'domains': set(),
            'urls': set(),
            'email_addresses': set(),
            'file_hashes': set(),
            'file_paths': set(),
        }
        
    def extract_ip_addresses(self, text: str) -> Set[str]:
        """Ekstrak alamat IP"""
        ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
        ips = re.findall(ip_pattern, text)
        valid_ips = set()
        for ip in ips:
            parts = ip.split('.')
            if all(0 <= int(p) <= 255 for p in parts):
                valid_ips.add(ip)
        return valid_ips
    
    def extract_domains(self, text: str) -> Set[str]:
        """Ekstrak domain names"""
        domain_pattern = r'\b(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}\b'
        domains = re.findall(domain_pattern, text)
        return set(domains)
    
    def extract_urls(self, text: str) -> Set[str]:
        """Ekstrak URLs"""
        url_pattern = r'https?://[^\s\'"<>]+'
        urls = re.findall(url_pattern, text)
        return set(urls)
    
    def extract_emails(self, text: str) -> Set[str]:
        """Ekstrak email addresses"""
        email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
        emails = re.findall(email_pattern, text)
        return set(emails)
    
    def extract_file_hashes(self, text: str) -> Set[str]:
        """Ekstrak file hashes (MD5, SHA1, SHA256)"""
        md5_pattern = r'\b[0-9a-f]{32}\b'
        sha1_pattern = r'\b[0-9a-f]{40}\b'
        sha256_pattern = r'\b[0-9a-f]{64}\b'
        
        hashes = set()
        hashes.update(re.findall(md5_pattern, text, re.IGNORECASE))
        hashes.update(re.findall(sha1_pattern, text, re.IGNORECASE))
        hashes.update(re.findall(sha256_pattern, text, re.IGNORECASE))
        return hashes
    
    def extract_file_paths(self, text: str) -> Set[str]:
        """Ekstrak file paths"""
        path_pattern = r'(?:/[\w\.-]+)+'
        paths = re.findall(path_pattern, text)
        return set(paths)
    
    def extract_all(self, text: str) -> Dict[str, List[str]]:
        """Ekstrak semua IOC dari text"""
        self.iocs['ip_addresses'] = self.extract_ip_addresses(text)
        self.iocs['domains'] = self.extract_domains(text)
        self.iocs['urls'] = self.extract_urls(text)
        self.iocs['email_addresses'] = self.extract_emails(text)
        self.iocs['file_hashes'] = self.extract_file_hashes(text)
        self.iocs['file_paths'] = self.extract_file_paths(text)
        
        return {k: list(v) for k, v in self.iocs.items()}
    
    def extract_from_file(self, filename: str) -> Dict[str, List[str]]:
        """Ekstrak IOC dari file"""
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        return self.extract_all(content)
    
    def export_json(self, filename: str) -> None:
        """Export IOC ke JSON file"""
        data = {k: list(v) for k, v in self.iocs.items()}
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"[✓] IOC exported to {filename}")

if __name__ == "__main__":
    extractor = IOCExtractor()
    
    sample_text = """
    Suspicious activity detected from 192.168.1.100 and 10.0.0.50
    Domain: malware.example.com
    URL: http://evil.com/malware.exe
    Email: attacker@phishing.com
    File hash: 5d41402abc4b2a76b9719d911017c592
    """
    
    results = extractor.extract_all(sample_text)
    print(json.dumps(results, indent=2))
