#!/bin/bash
# System Audit Script - Audit keamanan sistem Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Script ini harus dijalankan sebagai root"
        exit 1
    fi
}

check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "OS: $NAME $VERSION"
    else
        echo "OS: Unknown"
    fi
}

audit_users() {
    print_header "USER AUDIT"
    
    # Check root users
    echo "Root users:"
    grep -E 'root|x:0:' /etc/passwd
    
    # Check users with empty password
    echo -e "\nUsers with empty password:"
    awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null || echo "None"
    
    # Check sudo users
    echo -e "\nUsers with sudo privileges:"
    grep -E '^sudo|^wheel' /etc/group | cut -d: -f4
    
    # Check last logins
    echo -e "\nLast 10 logins:"
    last -10
}

audit_services() {
    print_header "SERVICES AUDIT"
    
    # Check running services
    echo "Running services:"
    systemctl list-units --type=service --state=running | head -10
    echo "... (showing first 10)"
    
    # Check listening ports
    echo -e "\nListening ports:"
    ss -tuln | grep LISTEN
    
    # Check startup services
    echo -e "\nEnabled services:"
    systemctl list-unit-files --type=service --state=enabled | head -10
}

audit_filesystem() {
    print_header "FILESYSTEM AUDIT"
    
