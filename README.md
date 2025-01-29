# 🚀 P1.Urls.sh - Aggressive URL Discovery & Vulnerability Scanner

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Version](https://img.shields.io/badge/Version-1.3.0-blue)

🔍 Ultimate URL discovery machine with Nuclei-powered vulnerability scanning for Bug Bounty & Pentesting

## ✨ Features
- **🌐 Smart Input Handling**: Works with domains/subdomains (`example.com`), URLs (`https://sub.example.com`), and files
- **🔄 Protocol-Agnostic**: Automatically normalizes input (removes `http://`/`https://`)
- **💥 Multi-Source Enum**: Combines `gau` + `katana` + `waymore` for max coverage
- **🎯 Vulnerability Tagging**: Auto-classifies XSS/SQLi/LFI/SSRF/Redirect URLs
- **⚡ Blazing Fast**: 100 threads concurrency & 200 req/s rate limit
- **📊 Results Pipeline**: Deduplication → Classification → Nuclei Scanning
- **📡 Real-Time Telegram Alerts**: Get JSON reports directly in Telegram
- **🔁 Self-Updating**: Auto-updates to latest version on each run!

## 🛠️ Installation

# Core Dependencies
 `sudo apt install parallel jq -y`

# Golang Tools
`go install github.com/lc/gau/v2/cmd/gau@latest`

`go install github.com/projectdiscovery/katana/cmd/katana@latest`

`go install github.com/xnl-h4ck3r/waymore/cmd/waymore@latest`

`go install github.com/tomnomnom/gf@latest`

`go install github.com/projectdiscovery/httpx/cmd/httpx@latest`

`go install github.com/tomnomnom/anew@latest`

`go install github.com/tomnomnom/urldedupe@latest`

`go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest`

## Get P1.Urls.sh
`https://github.com/7ealvivek/P1.Urls.sh.git`
`cd P1.Urls.sh`
`chmod +x P1.Urls.sh`

## Usage

# Single domain/subdomain (with or without protocol)
`./P1.Urls.sh example.com`
`./P1.Urls.sh https://sub.example.com`

# File containing domains/URLs (one per line)
`./P1.Urls.sh targets.txt`

# Custom output directory
`./P1.Urls.sh example.com /path/to/custom_output/`

## 📂 Output Structure

results/example.com/

`├── urls.txt              # All unique URLs after deduplication`

`├── classified_urls.txt   # Potential vulnerable URLs`

`├── nuclei_results.json   # Full Nuclei findings (JSON)`

`├── xss.txt               # XSS-prone URLs`

`├── sqli.txt              # SQL injection points`

`├── lfi.txt               # Local File Inclusion candidates`

`├── ssrf.txt              # SSRF potential endpoints`

`└── redirect.txt          # Open redirect possibilities`


## Telegram Integration 

Edit script and set your credentials:

`TELEGRAM_TOKEN="YOUR_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"`

Receive real-time alerts:

🟢 Scan start notifications

🔵 New vulnerability alerts

📁 JSON report files on completion

🚨 Critical findings with emoji markers


## 🎯 Use Cases

# Quick subdomain test
`./P1.Urls.sh test.example.com`

# Bug Bounty pipeline integration
`cat scope.txt | ./P1.Urls.sh`

# Pentest engagement reporting
`./P1.Urls.sh client.com /engagements/client2023/`

# Continuous monitoring (cronjob)
`0 */6 * * * /path/to/P1.Urls.sh monitor_targets.txt`


## 📌 Pro Tips

Use -oA flag for nuclei findings in multiple formats

Combine with Airixss for XSS validation

Pipe results to Dalfox for parameter analysis
