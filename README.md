
<p align="center">
<img src="https://github.com/kongali1720/KongWallet-Payment-Gateway-API/blob/main/kop_surat.jpg" width="100%">
</p>

<p align="center">


<div align="center">

<h3>
Cyber Defense Architect • Security Engineer • Web3 Builder
</h3>

---

# 🛡️ Security Automation Scripts

<p align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/kongali1720/Security-Automation-Scripts?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/kongali1720/Security-Automation-Scripts?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/kongali1720/Security-Automation-Scripts?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/kongali1720/Security-Automation-Scripts?style=for-the-badge)

![Python](https://img.shields.io/badge/Python-3.10+-blue?style=for-the-badge&logo=python)
![Bash](https://img.shields.io/badge/Bash-Supported-black?style=for-the-badge&logo=gnubash)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell)
![Linux](https://img.shields.io/badge/Linux-Supported-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-Supported-0078D6?style=for-the-badge&logo=windows)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

</p>

---

## 📖 Overview

**Security Automation Scripts** is an open-source collection of Python, Bash, and PowerShell scripts designed to automate common cybersecurity tasks for Blue Team operations, SOC analysts, system administrators, and security enthusiasts.

This repository focuses on defensive security, security monitoring, incident response, and system auditing.

---

## ✨ Features

```mermaid
mindmap
  root((🛡️ Security Automation))
    🔍 Log Analysis
      Parse Security Logs
      Detect Suspicious Events
      Generate Reports

    📁 File Integrity Monitoring
      File Change Detection
      Hash Comparison
      Integrity Verification

    🌐 DNS Lookup
      DNS Records
      Reverse DNS
      Name Resolution

    🌍 WHOIS Lookup
      Domain Information
      Registration Details
      Expiration Check

    🔐 Hash Verification
      MD5
      SHA1
      SHA256
      SHA512

    📄 IOC Extraction
      IP Addresses
      Domains
      URLs
      Email Addresses
      File Hashes

    🛡 Linux Security Audit
      User Audit
      SSH Configuration
      Firewall Status
      System Hardening

    🪟 Windows Security Audit
      Event Logs
      Defender Status
      Firewall Configuration
      Local Security Checks

    📊 Security Reporting
      HTML Reports
      JSON Output
      CSV Export

    ⚡ Automation
      Scheduled Tasks
      Batch Processing
      Script Chaining

    📈 Threat Hunting
      IOC Analysis
      Threat Indicators
      Log Correlation

    🔎 Network Utilities
      DNS Tools
      Port Analysis
      Connectivity Checks
```

## 📂 Repository Structure

```mermaid
flowchart TD

    A["🛡️ Security-Automation-Scripts"]

    A --> B["📄 README.md"]
    A --> C["📜 LICENSE"]
    A --> D["📦 requirements.txt"]

    A --> E["🐍 Python Scripts"]
    A --> F["🐧 Bash Scripts"]
    A --> G["🪟 PowerShell Scripts"]

    A --> H["📚 docs"]
    A --> I["🖼️ screenshots"]
    A --> J["🧪 samples"]
    A --> K["📊 reports"]

    E --> E1["log_analyzer.py"]
    E --> E2["hash_checker.py"]
    E --> E3["ioc_extractor.py"]
    E --> E4["dns_lookup.py"]
    E --> E5["whois_lookup.py"]
    E --> E6["url_checker.py"]
    E --> E7["file_integrity_monitor.py"]
    E --> E8["password_audit.py"]
    E --> E9["yara_scanner.py"]
    E --> E10["log_parser.py"]
    E --> E11["report_generator.py"]
    E --> E12["network_monitor.py"]

    F --> F1["system_audit.sh"]
    F --> F2["firewall_status.sh"]
    F --> F3["ssh_hardening.sh"]
    F --> F4["backup_logs.sh"]
    F --> F5["user_audit.sh"]

    G --> G1["windows_audit.ps1"]
    G --> G2["defender_status.ps1"]
    G --> G3["firewall_check.ps1"]
    G --> G4["eventlog_parser.ps1"]
```

---

# 🐍 Python Scripts

| Script | Description |
|---------|-------------|
| log_analyzer.py | Analyze security logs |
| hash_checker.py | Calculate and verify file hashes |
| ioc_extractor.py | Extract IPs, URLs, Domains and Hashes |
| dns_lookup.py | DNS Information Lookup |
| whois_lookup.py | WHOIS Lookup |
| url_checker.py | URL Validation |
| file_integrity_monitor.py | Detect file modifications |
| password_audit.py | Password Strength Checker |
| yara_scanner.py | Scan files using YARA rules |
| report_generator.py | Generate HTML Reports |
| network_monitor.py | Monitor Network Connections |

---

# 🐧 Bash Scripts

| Script | Description |
|---------|-------------|
| system_audit.sh | Linux Security Audit |
| ssh_hardening.sh | SSH Hardening |
| firewall_status.sh | Firewall Status |
| backup_logs.sh | Backup Security Logs |
| user_audit.sh | User Account Audit |

---

# 🪟 PowerShell Scripts

| Script | Description |
|---------|-------------|
| windows_audit.ps1 | Windows Security Audit |
| defender_status.ps1 | Microsoft Defender Status |
| firewall_check.ps1 | Windows Firewall Audit |
| eventlog_parser.ps1 | Windows Event Log Parser |

---
## 🚀 Quick Start

### 1️⃣ Clone Repository

```bash
git clone https://github.com/kongali1720/Security-Automation-Scripts.git
cd Security-Automation-Scripts
```

### 2️⃣ Install Dependencies

```bash
pip install -r requirements.txt
```

### 3️⃣ Run a Script

| Platform | Command |
|----------|---------|
| 🐍 Python | `python python/log_analyzer.py` |
| 🐧 Linux | `bash bash/system_audit.sh` |
| 🪟 Windows | `powershell .\powershell\windows_audit.ps1` |

---

## 📊 Project Workflow

```mermaid
flowchart LR

A[Collect Data]
-->B[Analyze]
-->C[Detect]
-->D[Generate Report]
-->E[Response]

B --> F[Logs]
B --> G[DNS]
B --> H[Hashes]
B --> I[Files]
```

## 🗺️ Roadmap

| Status | Feature |
|:------:|---------|
| ✅ | Log Analyzer |
| ✅ | Hash Checker |
| ✅ | IOC Extractor |
| ✅ | DNS Lookup |
| ✅ | WHOIS Lookup |
| ✅ | URL Validation |
| 🚧 | VirusTotal Integration |
| 🚧 | AbuseIPDB Integration |
| 🚧 | Shodan Integration |
| 🚧 | HTML Dashboard |
| 🚧 | PDF Report Generator |
| 🚧 | Email Notification |
| 🚧 | SIEM Integration |
| 🚧 | GitHub Actions CI/CD |

## 🏗 Architecture

```mermaid
flowchart TB

A[Security Scripts]

A --> B[Python]
A --> C[Bash]
A --> D[PowerShell]

B --> E[Log Analysis]
B --> F[IOC Extraction]
B --> G[Hash Verification]

C --> H[Linux Audit]
C --> I[SSH Hardening]

D --> J[Windows Audit]
D --> K[Defender Check]
```

## 🛠 Tech Stack

<p>

<img src="https://skillicons.dev/icons?i=python,bash,powershell,linux,windows,git,github,vscode" />

</p>

## 🤝 Contributing

Contributions are always welcome!

```mermaid
graph LR

Fork --> Code
Code --> Commit
Commit --> Push
Push --> PullRequest
PullRequest --> Review
Review --> Merge
```

## ⭐ Support

If this project helps you, consider supporting it by giving it a ⭐.

| ⭐ Star | 🍴 Fork | 🐛 Issue | 💡 Feature Request |
|:------:|:-------:|:-------:|:------------------:|
| Show support | Contribute | Report bugs | Suggest ideas |
# 📄 License

This project is licensed under the MIT License.

---

# 👨‍💻 Author

**Kong Ali**

Cybersecurity Enthusiast

Blue Team | Security Automation | Python | Linux | Windows | SOC

GitHub: https://github.com/kongali1720

---

<p align="center">

### 🛡️ Secure • Automate • Monitor • Defend 🛡️

Made with ❤️ for the Cybersecurity Community

</p>

<div align="center">


# ☕ Support Development


Jika project ini membantu kamu,
support kecil sangat berarti.


<a href="https://www.paypal.com/paypalme/bungtempong99/">

<img src="https://img.shields.io/badge/BUY_ME_A_COFFEE-support-yellow?style=for-the-badge&logo=buymeacoffee">

</a>


</div>
