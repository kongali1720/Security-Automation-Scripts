#!/bin/bash
# System Audit Script - Audit keamanan sistem Linux

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
    echo "Root users:"
    grep -E 'root|x:0:' /etc/passwd
    echo -e "\nUsers with empty password:"
    awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null || echo "None"
    echo -e "\nUsers with sudo privileges:"
    grep -E '^sudo|^wheel' /etc/group | cut -d: -f4
    echo -e "\nLast 10 logins:"
    last -10
}

audit_services() {
    print_header "SERVICES AUDIT"
    echo "Running services:"
    systemctl list-units --type=service --state=running | head -10
    echo "... (showing first 10)"
    echo -e "\nListening ports:"
    ss -tuln | grep LISTEN
    echo -e "\nEnabled services:"
    systemctl list-unit-files --type=service --state=enabled | head -10
}

audit_filesystem() {
    print_header "FILESYSTEM AUDIT"
    echo "SUID/SGID binaries:"
    find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -la {} \; 2>/dev/null | head -10
    echo -e "\nWorld-writable files:"
    find / -type f -perm -002 -exec ls -la {} \; 2>/dev/null | head -10
    echo -e "\nUnowned files:"
    find / -type f -nouser -o -nogroup 2>/dev/null | head -10
}

audit_network() {
    print_header "NETWORK AUDIT"
    echo "Network interfaces:"
    ip addr show
    echo -e "\nFirewall status:"
    if command -v ufw &> /dev/null; then
        ufw status
    elif command -v iptables &> /dev/null; then
        iptables -L -n | head -10
    else
        echo "No firewall found"
    fi
    echo -e "\nDNS settings:"
    cat /etc/resolv.conf
}

audit_packages() {
    print_header "PACKAGE AUDIT"
    echo "Available updates:"
    if command -v apt &> /dev/null; then
        apt list --upgradable 2>/dev/null | head -5
    elif command -v yum &> /dev/null; then
        yum check-update 2>/dev/null | head -5
    elif command -v dnf &> /dev/null; then
        dnf check-update 2>/dev/null | head -5
    else
        echo "Package manager not recognized"
    fi
}

audit_security() {
    print_header "SECURITY SETTINGS"
    echo "Password policy:"
    cat /etc/login.defs | grep -E 'PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE'
    echo -e "\nSSH configuration (key settings):"
    if [[ -f /etc/ssh/sshd_config ]]; then
        grep -E 'PermitRootLogin|PasswordAuthentication|PubkeyAuthentication' /etc/ssh/sshd_config
    else
        echo "SSH config not found"
    fi
    echo -e "\nKernel security parameters:"
    sysctl net.ipv4.tcp_syncookies
    sysctl net.ipv4.ip_forward
    sysctl kernel.randomize_va_space
}

audit_logs() {
    print_header "LOG AUDIT"
    echo "Recent authentication failures:"
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "No auth log found"
    echo -e "\nRecent sudo commands:"
    grep "sudo" /var/log/auth.log 2>/dev/null | tail -5 || echo "No sudo log found"
}

generate_report() {
    local report_file="system_audit_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "=== SYSTEM AUDIT REPORT ==="
        echo "Generated: $(date)"
        echo "============================"
        echo ""
        check_os
        echo ""
        audit_users
        echo ""
        audit_services
        echo ""
        audit_filesystem
        echo ""
        audit_network
        echo ""
        audit_packages
        echo ""
        audit_security
        echo ""
        audit_logs
    } | tee "$report_file"
    print_success "Report saved to: $report_file"
}

main() {
    check_root
    echo -e "${GREEN}=== SYSTEM AUDIT SCRIPT ===${NC}"
    echo "Starting security audit..."
    echo ""
    generate_report
    echo -e "\n${GREEN}Audit completed successfully!${NC}"
}

main
