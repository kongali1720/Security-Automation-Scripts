#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Event Log Parser - Parse Windows Event Logs
.DESCRIPTION
    Script untuk menganalisis event log Windows
#>

# Configuration
$ErrorActionPreference = "Stop"

# Colors
function Write-Info { Write-Host "ℹ $($args[0])" -ForegroundColor Yellow }
function Write-Success { Write-Host "✓ $($args[0])" -ForegroundColor Green }
function Write-Error { Write-Host "✗ $($args[0])" -ForegroundColor Red }

# Check admin rights
function Test-AdminRights {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Parse event logs
function Get-SecurityEvents {
    param(
        [int]$MaxEvents = 100,
        [DateTime]$StartDate = (Get-Date).AddDays(-7),
        [int]$EventID = 4624 # Login events
    )
    
    Write-Info "Parsing security events from $StartDate..."
    
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = $EventID
        StartTime = $StartDate
    } -MaxEvents $MaxEvents | ForEach-Object {
        $xml = [xml]$_.ToXml()
        $eventData = $xml.Event.EventData.Data
        
        [PSCustomObject]@{
            TimeCreated = $_.TimeCreated
            User = ($eventData | Where-Object {$_.Name -eq 'TargetUserName'}).'#text'
            Domain = ($eventData | Where-Object {$_.Name -eq 'TargetDomainName'}).'#text'
            LogonType = ($eventData | Where-Object {$_.Name -eq 'LogonType'}).'#text'
            SourceIP = ($eventData | Where-Object {$_.Name -eq 'IpAddress'}).'#text'
            Process = ($eventData | Where-Object {$_.Name -eq 'ProcessName'}).'#text'
            EventID = $_.Id
            Message = $_.Message
        }
    }
    
    return $events
}

# Analyze failed logins
function Get-FailedLogins {
    param([int]$MaxEvents = 50)
    
    Write-Info "Checking failed login attempts..."
    
    $failedEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4625
        StartTime = (Get-Date).AddDays(-1)
    } -MaxEvents $MaxEvents
    
    $failedCount = $failedEvents.Count
    
    if ($failedCount -gt 0) {
        Write-Error "Found $failedCount failed login attempts"
        $failedEvents | Format-Table TimeCreated, User, SourceIP -AutoSize
    } else {
        Write-Success "No failed login attempts found"
    }
}

# Check for admin activity
function Get-AdminActivity {
    param([int]$MaxEvents = 50)
    
    Write-Info "Checking administrative activity..."
    
    $adminEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4672, 4768, 4769, 4770, 4771, 4772
        StartTime = (Get-Date).AddDays(-1)
    } -MaxEvents $MaxEvents
    
    $adminCount = $adminEvents.Count
    
    if ($adminCount -gt 0) {
        Write-Info "Found $adminCount administrative events"
        $adminEvents | Format-Table TimeCreated, Id, Message -AutoSize
    } else {
        Write-Success "No administrative activity found"
    }
}

# Analyze system events
function Get-SystemEvents {
    param([int]$MaxEvents = 50)
    
    Write-Info "Checking system events..."
    
    $systemEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        Level = 1, 2, 3  # Critical, Error, Warning
        StartTime = (Get-Date).AddHours(-24)
    } -MaxEvents $MaxEvents
    
    $errorCount = $systemEvents.Count
    
    if ($errorCount -gt 0) {
        Write-Error "Found $errorCount system errors/warnings"
        $systemEvents | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize
    } else {
        Write-Success "No system errors found"
    }
}

# Generate report
function Export-EventReport {
    param(
        [string]$OutputPath = "event_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    )
    
    Write-Info "Generating event report..."
    
    $events = Get-SecurityEvents -MaxEvents 1000
    $failed = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4625
        StartTime = (Get-Date).AddDays(-7)
    } -MaxEvents 100
    
    $report = @()
    
    # Security events
    foreach ($event in $events) {
        $report += [PSCustomObject]@{
            Type = 'Security'
            Time = $event.TimeCreated
            EventID = $event.EventID
            User = $event.User
            SourceIP = $event.SourceIP
            LogonType = $event.LogonType
        }
    }
    
    # Failed logins
    foreach ($event in $failed) {
        $xml = [xml]$event.ToXml()
        $eventData = $xml.Event.EventData.Data
        $user = ($eventData | Where-Object {$_.Name -eq 'TargetUserName'}).'#text'
        $sourceIP = ($eventData | Where-Object {$_.Name -eq 'IpAddress'}).'#text'
        
        $report += [PSCustomObject]@{
            Type = 'FailedLogin'
            Time = $event.TimeCreated
            EventID = $event.Id
            User = $user
            SourceIP = $sourceIP
            LogonType = 'Failed'
        }
    }
    
    $report | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Success "Report exported to $OutputPath"
}

# Main execution
function Main {
    Write-Host "=== WINDOWS EVENT LOG PARSER ===" -ForegroundColor Green
    Write-Host "Running event log analysis..." -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-AdminRights)) {
        Write-Error "This script requires administrator privileges"
        exit 1
    }
    
    # Get recent events
    Write-Info "Last 10 login events:"
    Get-SecurityEvents -MaxEvents 10 | Format-Table -AutoSize
    
    Write-Host ""
    Get-FailedLogins -MaxEvents 20
    
    Write-Host ""
    Get-AdminActivity -MaxEvents 20
    
    Write-Host ""
    Get-SystemEvents -MaxEvents 30
    
    Write-Host ""
    Export-EventReport
    
    Write-Host ""
    Write-Success "Event log analysis completed"
}

# Run
Main
