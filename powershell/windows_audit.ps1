#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Windows Audit - Comprehensive Windows Security Audit
.DESCRIPTION
    Script untuk audit keamanan Windows
#>

$ErrorActionPreference = "Stop"

function Write-Info { Write-Host "ℹ $($args[0])" -ForegroundColor Yellow }
function Write-Success { Write-Host "✓ $($args[0])" -ForegroundColor Green }
function Write-Error { Write-Host "✗ $($args[0])" -ForegroundColor Red }
function Write-Section { Write-Host "`n=== $($args[0]) ===" -ForegroundColor Cyan }

function Test-AdminRights {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Audit users
function Audit-Users {
    Write-Section "USER AUDIT"
    
    # Local users
    $users = Get-LocalUser
    Write-Info "Local users: $($users.Count)"
    
    # Enabled users
    $enabledUsers = $users | Where-Object {$_.Enabled -eq $true}
    Write-Info "Enabled users: $($enabledUsers.Count)"
    
    # Users with empty password
    $emptyPassword = $users | Where-Object {$_.Password -eq $null}
    if ($emptyPassword) {
        Write-Error "Users with empty password: $($emptyPassword.Name -join ', ')"
    } else {
        Write-Success "No users with empty passwords"
    }
    
    # Last login times
    Write-Info "Last user logins:"
    Get-LocalUser | ForEach-Object {
        $lastLogon = Get-LocalUser -Name $_.Name | Select-Object * 
        # Note: LastLogon property might not be available in all systems
    }
}

# Audit groups
function Audit-Groups {
    Write-Section "GROUP AUDIT"
    
    # Administrator groups
    $adminGroups = Get-LocalGroup | Where-Object {$_.Name -match "Administrators|Domain Admins"}
    Write-Info "Administrative groups found: $($adminGroups.Count)"
    
    # Members of Administrators
    Write-Info "Members of Administrators group:"
    Get-LocalGroupMember -Group "Administrators" | Format-Table Name, ObjectClass, PrincipalSource
}

# Audit services
function Audit-Services {
    Write-Section "SERVICE AUDIT"
    
    # Running services
    $services = Get-Service | Where-Object {$_.Status -eq 'Running'}
    Write-Info "Running services: $($services.Count)"
    
    # Services that can be stopped/started by non-admin
    Write-Info "Checking service permissions..."
    
    # Unusual services (simple check)
    $suspiciousServices = $services | Where-Object {
        $_.DisplayName -match "hack|malware|exploit" -or 
        $_.ServiceName -match "hack|malware|exploit"
    }
    
    if ($suspiciousServices) {
        Write-Error "Suspicious services found:"
        $suspiciousServices | Format-Table Name, DisplayName, Status
    }
}

# Audit processes
function Audit-Processes {
    Write-Section "PROCESS AUDIT"
    
    # Running processes
    $processes = Get-Process
    Write-Info "Running processes: $($processes.Count)"
    
    # Processes running as SYSTEM
    $systemProcesses = $processes | Where-Object {$_.SessionId -eq 0}
    Write-Info "System processes: $($systemProcesses.Count)"
    
    # High CPU/Memory processes
    $highCPU = $processes | Sort-Object CPU -Descending | Select-Object -First 5
    Write-Info "Top 5 CPU processes:"
    $highCPU | Format-Table Name, CPU, WorkingSet
    
    # Suspicious processes (simple check)
    $suspiciousNames = @("mimikatz", "hashcat", "nc.exe", "plink.exe")
    $suspiciousProcesses = $processes | Where-Object {
        $suspiciousNames -contains $_.Name.ToLower()
    }
    
    if ($suspiciousProcesses) {
        Write-Error "Suspicious processes found:"
        $suspiciousProcesses | Format-Table Name, CPU, Path
    }
}

# Audit network
function Audit-Network {
    Write-Section "NETWORK AUDIT"
    
    # Network interfaces
    $interfaces = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
    Write-Info "Active network interfaces: $($interfaces.Count)"
    
    # Open ports
    $connections = Get-NetTCPConnection
    $listening = $connections | Where-Object {$_.State -eq 'Listen'}
    Write-Info "Listening ports: $($listening.Count)"
    $listening | Format-Table LocalPort, LocalAddress, OwningProcess
    
    # Established connections
    $established = $connections | Where-Object {$_.State -eq 'Established'}
    Write-Info "Established connections: $($established.Count)"
    $established | Select-Object -First 10 | Format-Table LocalAddress, LocalPort, RemoteAddress, RemotePort
}

# Audit Windows settings
function Audit-Settings {
    Write-Section "WINDOWS SETTINGS"
    
    # Firewall
    $firewall = Get-NetFirewallProfile
    Write-Info "Firewall status:"
    $firewall | Format-Table Name, Enabled, InboundDefaultAction, OutboundDefaultAction
    
    # Windows Defender
    $defender = Get-MpComputerStatus
    if ($defender) {
        Write-Info "Windows Defender status:"
        Write-Host "  Antivirus: $($defender.AntivirusEnabled)"
        Write-Host "  Signatures: $($defender.AntivirusSignatureVersion)"
    }
    
    # Windows Update
    $update = Get-WUApiVersion -ErrorAction SilentlyContinue
    if ($update) {
        Write-Info "Windows Update: $($update)"
    }
    
    # UAC
    $uac = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -ErrorAction SilentlyContinue
    if ($uac) {
        Write-Info "UAC Enabled: $($uac.EnableLUA -eq 1)"
    }
}

# Audit file system
function Audit-FileSystem {
    Write-Section "FILE SYSTEM AUDIT"
    
    # Check for common malware locations
    $locations = @(
        "$env:TEMP",
        "$env:APPDATA",
        "$env:PROGRAMDATA",
        "C:\Windows\Temp",
        "C:\PerfLogs"
    )
    
    foreach ($location in $locations) {
        if (Test-Path $location) {
            $files = Get-ChildItem $location -File -Recurse -ErrorAction SilentlyContinue | 
                     Where-Object {$_.Extension -match "\.exe$|\.dll$|\.vbs$|\.ps1$"}
            if ($files) {
                Write-Info "Found executable files in $location: $($files.Count)"
            }
        }
    }
}

# Generate report
function Export-AuditReport {
    param([string]$OutputPath = "windows_audit_$(Get-Date -Format 'yyyyMMdd_HHmmss').html")
    
    Write-Info "Generating HTML report..."
    
    $html = @"
<!DOCTYPE html>
<html>
<head><title>Windows Security Audit</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
.container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
.header { background: #2c3e50; color: white; padding: 20px; border-radius: 10px; }
.section { background: #ecf0f1; margin: 10px 0; padding: 15px; border-radius: 5px; }
.success { color: #27ae60; }
.error { color: #e74c3c; }
</style>
</head>
<body>
<div class="container">
<div class="header">
    <h1>Windows Security Audit Report</h1>
    <p>Generated: $(Get-Date)</p>
</div>
"@
    
    # Add sections
    $html += "<div class='section'><h2>System Information</h2>"
    $html += "<p>Hostname: $env:COMPUTERNAME</p>"
    $html += "<p>OS: $((Get-CimInstance Win32_OperatingSystem).Caption)</p>"
    $html += "<p>Version: $((Get-CimInstance Win32_OperatingSystem).Version)</p>"
    $html += "</div>"
    
    $html += "</div></body></html>"
    
    $html | Out-File -FilePath $OutputPath
    Write-Success "Report exported to $OutputPath"
}

# Main execution
function Main {
    Write-Host "=== WINDOWS SECURITY AUDIT ===" -ForegroundColor Green
    Write-Host "Running comprehensive security audit..." -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-AdminRights)) {
        Write-Error "This script requires administrator privileges"
        exit 1
    }
    
    Audit-Users
    Audit-Groups
    Audit-Services
    Audit-Processes
    Audit-Network
    Audit-Settings
    Audit-FileSystem
    
    Write-Host ""
    Export-AuditReport
    
    Write-Host ""
    Write-Success "Windows audit completed"
}

# Run
Main
