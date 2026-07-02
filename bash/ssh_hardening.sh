#!/bin/bash
# SSH Hardening Script - Kunci konfigurasi SSH

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SSH_CONFIG="/etc/ssh/sshd_config"
BACKUP_DIR="/root/ssh_backup"
DATE=$(date +%Y%m%d_%H%M%S)

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

backup_config() {
    print_header "BACKUP CONFIGURATION"
    mkdir -p "$BACKUP_DIR"
    cp "$SSH_CONFIG" "$BACKUP_DIR/sshd_config_${DATE}.bak"
    cp "/etc/ssh/ssh_config" "$BACKUP_DIR/ssh_config_${DATE}.bak" 2>/dev/null || true
    cp "/etc/hosts.allow" "$BACKUP_DIR/hosts.allow_${DATE}.bak" 2>/dev/null || true
    cp "/etc/hosts.deny" "$BACKUP_DIR/hosts.deny_${DATE}.bak" 2>/dev/null || true
    print_success "Backup created in $BACKUP_DIR"
}

configure_ssh() {
    print_header "CONFIGURING SSH"
    backup_config
    if [[ ! -f "$SSH_CONFIG" ]]; then
        print_error "SSH config not found: $SSH_CONFIG"
        exit 1
    fi
    echo "Applying SSH hardening settings..."
    sed -i.bak 's/^#Port 22/Port 22/' "$SSH_CONFIG"
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' "$SSH_CONFIG"
    sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' "$SSH_CONFIG"
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"
    sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication no/' "$SSH_CONFIG"
    sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSH_CONFIG"
    sed -i 's/^#PermitEmptyPasswords no/PermitEmptyPasswords no/' "$SSH_CONFIG"
    sed -i 's/^#MaxAuthTries 6/MaxAuthTries 3/' "$SSH_CONFIG"
    sed -i 's/^#MaxSessions 10/MaxSessions 2/' "$SSH_CONFIG"
    sed -i 's/^#ClientAliveInterval 0/ClientAliveInterval 300/' "$SSH_CONFIG"
    sed -i 's/^#ClientAliveCountMax 3/ClientAliveCountMax 0/' "$SSH_CONFIG"
    sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 30/' "$SSH_CONFIG"
    sed -i 's/^#PermitUserEnvironment no/PermitUserEnvironment no/' "$SSH_CONFIG"
    echo "X11Forwarding no" >> "$SSH_CONFIG"
    echo "UseDNS no" >> "$SSH_CONFIG"
    echo "AllowAgentForwarding no" >> "$SSH_CONFIG"
    echo "AllowTcpForwarding no" >> "$SSH_CONFIG"
    echo "PermitTunnel no" >> "$SSH_CONFIG"
    print_success "SSH hardening applied"
}

setup_firewall() {
    print_header "FIREWALL SETUP"
    if command -v ufw &> /dev/null; then
        echo "Configuring UFW..."
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow 22/tcp
        ufw logging on
        echo "y" | ufw enable
        print_success "UFW configured"
    else
        echo "UFW not found, skipping..."
    fi
    echo "Configuring TCP wrappers..."
    echo "sshd: ALL" >> /etc/hosts.allow
    echo "ALL: ALL" >> /etc/hosts.deny
    print_success "TCP wrappers configured"
}

setup_fail2ban() {
    print_header "FAIL2BAN SETUP"
    if command -v fail2ban-client &> /dev/null; then
        if ! command -v fail2ban-client &> /dev/null; then
            if command -v apt &> /dev/null; then
                apt install -y fail2ban
            elif command -v yum &> /dev/null; then
                yum install -y fail2ban
            else
                print_error "Cannot install fail2ban"
                return
            fi
        fi
        cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
        systemctl restart fail2ban
        systemctl enable fail2ban
        print_success "Fail2ban configured"
    else
        echo "Fail2ban not installed, skipping..."
    fi
}

setup_ssh_keys() {
    print_header "SSH KEY SETUP"
    mkdir -p /root/.ssh
    if [[ ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
        echo "Generating ED25519 host key..."
        ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
    fi
    systemctl restart sshd
    print_success "SSH keys setup completed"
}

test_ssh() {
    print_header "TESTING CONFIGURATION"
    if sshd -t; then
        print_success "SSH configuration is valid"
    else
        print_error "SSH configuration error!"
        print_error "Restoring backup..."
        cp "$BACKUP_DIR/sshd_config_${DATE}.bak" "$SSH_CONFIG"
        systemctl restart sshd
        exit 1
    fi
}

show_summary() {
    print_header "HARDENING SUMMARY"
    echo "Hardening applied:"
    echo "  ✓ SSH root login disabled"
    echo "  ✓ Password authentication disabled"
    echo "  ✓ Public key authentication enabled"
    echo "  ✓ Login grace time reduced to 30 seconds"
    echo "  ✓ Max auth tries limited to 3"
    echo "  ✓ X11 forwarding disabled"
    echo "  ✓ TCP forwarding disabled"
    echo "  ✓ Firewall configured"
    echo "  ✓ Fail2ban installed (if available)"
    echo -e "\n${GREEN}SSH hardening complete!${NC}"
    echo "Please note:"
    echo "  - SSH port: 22 (default)"
    echo "  - Password auth: disabled"
    echo "  - Make sure you have your SSH key before disconnecting!"
}

main() {
    check_root
    echo -e "${GREEN}=== SSH HARDENING SCRIPT ===${NC}"
    echo "This script will apply SSH hardening settings"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    configure_ssh
    setup_firewall
    setup_fail2ban
    setup_ssh_keys
    test_ssh
    show_summary
}

main
