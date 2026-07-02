#!/usr/bin/env python3
"""
File Integrity Monitor - Monitor perubahan file
"""

import os
import json
import hashlib
import time
import argparse
from datetime import datetime
from typing import Dict, List, Tuple
import pickle

class FileIntegrityMonitor:
    def __init__(self, base_dir: str):
        self.base_dir = base_dir
        self.file_hashes = {}
        self.db_file = 'file_integrity.db'
        
    def calculate_hash(self, filepath: str, algorithm: str = 'sha256') -> str:
        """Hitung hash file"""
        hasher = hashlib.new(algorithm)
        try:
            with open(filepath, 'rb') as f:
                for chunk in iter(lambda: f.read(4096), b''):
                    hasher.update(chunk)
            return hasher.hexdigest()
        except Exception as e:
            print(f"[!] Error hashing {filepath}: {e}")
            return None
    
    def scan_directory(self, extensions: List[str] = None) -> Dict[str, str]:
        """Scan directory dan simpan hash"""
        files_hashed = {}
        
        for root, _, files in os.walk(self.base_dir):
            for file in files:
                filepath = os.path.join(root, file)
                
                if extensions:
                    if not any(filepath.endswith(ext) for ext in extensions):
                        continue
                
                if os.path.getsize(filepath) > 50 * 1024 * 1024:
                    continue
                    
                file_hash = self.calculate_hash(filepath)
                if file_hash:
                    files_hashed[filepath] = file_hash
                    
        return files_hashed
    
    def save_state(self) -> None:
        """Simpan state ke database"""
        state = {
            'timestamp': datetime.now().isoformat(),
            'base_dir': self.base_dir,
            'files': self.file_hashes
        }
        
        with open(self.db_file, 'wb') as f:
            pickle.dump(state, f)
        print(f"[✓] State saved to {self.db_file}")
    
    def load_state(self) -> bool:
        """Load state dari database"""
        if not os.path.exists(self.db_file):
            print("[!] Database tidak ditemukan. Membuat baru...")
            return False
            
        try:
            with open(self.db_file, 'rb') as f:
                state = pickle.load(f)
            self.file_hashes = state['files']
            print(f"[✓] State loaded from {self.db_file}")
            return True
        except Exception as e:
            print(f"[!] Error loading state: {e}")
            return False
    
    def check_integrity(self) -> Dict[str, List[str]]:
        """Check integritas file"""
        changes = {
            'added': [],
            'modified': [],
            'deleted': []
        }
        
        current_files = self.scan_directory()
        
        for filepath, old_hash in self.file_hashes.items():
            if filepath not in current_files:
                changes['deleted'].append(filepath)
            else:
                if current_files[filepath] != old_hash:
                    changes['modified'].append(filepath)
                    
        for filepath in current_files:
            if filepath not in self.file_hashes:
                changes['added'].append(filepath)
                
        return changes
    
    def monitor(self, interval: int = 60, extensions: List[str] = None):
        """Monitor file integrity secara kontinyu"""
        print(f"[*] Monitoring {self.base_dir} setiap {interval} detik...")
        print("Press Ctrl+C to stop")
        
        try:
            while True:
                if not self.file_hashes:
                    self.file_hashes = self.scan_directory(extensions)
                    self.save_state()
                
                changes = self.check_integrity()
                
                if any(changes.values()):
                    print(f"\n[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Changes detected:")
                    if changes['added']:
                        print(f"  Added: {len(changes['added'])} files")
                    if changes['modified']:
                        print(f"  Modified: {len(changes['modified'])} files")
                    if changes['deleted']:
                        print(f"  Deleted: {len(changes['deleted'])} files")
                    
                    self.file_hashes = self.scan_directory(extensions)
                    self.save_state()
                else:
                    print(".", end="", flush=True)
                    
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print("\n[*] Monitoring stopped")

def main():
    parser = argparse.ArgumentParser(description='File Integrity Monitor')
    parser.add_argument('-d', '--directory', required=True, help='Directory yang dimonitor')
    parser.add_argument('-e', '--extensions', nargs='+', help='Ekstensi file yang dimonitor')
    parser.add_argument('--check', action='store_true', help='Check sekali saja')
    parser.add_argument('--monitor', action='store_true', help='Monitor kontinyu')
    parser.add_argument('-i', '--interval', type=int, default=60, help='Interval dalam detik')
    
    args = parser.parse_args()
    
    monitor = FileIntegrityMonitor(args.directory)
    
    if args.monitor:
        monitor.monitor(args.interval, args.extensions)
    else:
        monitor.file_hashes = monitor.scan_directory(args.extensions)
        if args.check:
            changes = monitor.check_integrity()
            print(json.dumps(changes, indent=2))
        else:
            monitor.save_state()
            print(f"[✓] Initial scan completed. {len(monitor.file_hashes)} files hashed.")

if __name__ == "__main__":
    main()
