#!/bin/bash
# User Audit Script - Audit user dan group

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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Script ini harus dijalankan sebagai root"
        exit 1
    fi
}

check_user_inactive() {
    print_header "INACTIVE USERS"
    echo "Users inactive for > 90 days:"
    lastlog -b 90 | grep -v "Never" | tail -n +2
}

check_user_expiry() {
    print_header "USER EXPIRY"
    echo "Password expiry information:"
    chage -l root 2>/dev/null || echo "Cannot check root expiry"
}

check_sudoers() {
    print_header "SUDOERS FILE"
    echo "Checking sudoers file..."
    visudo -c
    echo -e "\nUsers with sudo access:"
    grep -v "^#" /etc/group | grep -E 'sudo|wheel' | cut -d: -f4 | tr ',' '\n'
}

check_duplicate_uids() {
    print_header "DUPLICATE UIDs"
    echo "Duplicate UIDs found:"
    awk -F: '{print $3}' /etc/passwd | sort | uniq -d
}

check_home_permissions() {
    print_header "HOME DIRECTORY PERMISSIONS"
    echo "Checking home directory permissions..."
    for user in $(getent passwd | cut -d: -f1); do
        home_dir=$(eval echo ~$user 2>/dev/null)
        if [[ -d "$home_dir" ]]; then
            perms=$(ls -ld "$home_dir" | awk '{print $1}')
            if [[ $perms == drwxrwxrwx* ]]; then
                print_error "World-writable home: $user ($home_dir)"
            elif [[ $perms == drwxr-xr-x* || $perms == drwx------* ]]; then
                print_success "Secure home: $user ($home_dir)"
            fi
        fi
    done
}

check_system_accounts() {
    print_header "SYSTEM ACCOUNTS"
    echo "System accounts with shells:"
    cat /etc/passwd | awk -F: '$3 < 1000 && $7 != "/sbin/nologin" && $7 != "/bin/false" {print $1}'
}

generate_report() {
    local report_file="user_audit_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "=== USER AUDIT REPORT ==="
        echo "Generated: $(date)"
        echo "========================="
        echo ""
        check_user_inactive
        echo ""
        check_user_expiry
        echo ""
        check_sudoers
        echo ""
        check_duplicate_uids
        echo ""
        check_home_permissions
        echo ""
        check_system_accounts
    } | tee "$report_file"
    print_success "Report saved to: $report_file"
}

main() {
    check_root
    echo -e "${GREEN}=== USER AUDIT SCRIPT ===${NC}"
    echo "Starting user security audit..."
    echo ""
    generate_report
    echo -e "\n${GREEN}Audit completed successfully!${NC}"
}

main
