# 🎯 P1.Urls.sh - The Ultimate URL Discovery & Vulnerability Scanner  

🚀 **Version:** 3.9 | 👨‍💻 **Author:** [Vivek (realvivek)](https://github.com/realvivek)  

P1.Urls.sh is a **high-performance, automated URL discovery and vulnerability scanning tool** designed for penetration testers, bug bounty hunters, and security researchers. It intelligently extracts **hidden and exposed URLs** using multiple sources like `gau`, `katana`, and `waymore`, ensuring **comprehensive coverage** of the target’s attack surface. The script filters, normalizes, and validates URLs using `httpx`, removing unnecessary assets like images and stylesheets while focusing on potentially vulnerable endpoints. It then performs **deep vulnerability analysis** using `gf` to classify URLs into high-risk categories (`XSS`, `SQLi`, `LFI`, `SSRF`, `Open Redirect`) and `nuclei` to scan for **critical security vulnerabilities**, ensuring aggressive and accurate detection. Designed for speed and efficiency, P1.Urls.sh employs **multi-threading, intelligent deduplication, and rapid URL processing**, making it one of the most powerful automated reconnaissance scripts available. Unlike conventional scanners, this tool also includes a **real-time Telegram notification system**, instantly alerting users when a new vulnerability is found. It supports **single-domain scanning**, **batch processing of multiple domains**, and **subdomain enumeration**, making it a **versatile asset** for both offensive security professionals and ethical hackers.  

```bash
# 🚀 Installation & Usage  
# Ensure dependencies are installed and clone the repository:  
sudo apt update && sudo apt install -y curl jq && go install github.com/lc/gau/v2/cmd/gau@latest && go install github.com/projectdiscovery/katana/cmd/katana@latest && pip install waymore && go install github.com/tomnomnom/gf@latest && go install github.com/projectdiscovery/httpx/cmd/httpx@latest && go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest  
git clone https://github.com/realvivek/P1.Urls.sh.git && cd P1.Urls.sh && chmod +x P1.Urls.sh  
./P1.Urls.sh example.com  # Scan a single domain  
./P1.Urls.sh domains.txt  # Scan multiple domains  
./P1.Urls.sh subdomains.txt  # Scan a subdomain list  

# ⚙️ How It Works  
# P1.Urls.sh automates the tedious process of URL enumeration, validation, and vulnerability scanning in four streamlined phases:  
# 1️⃣ Advanced URL Discovery → Extracts URLs from diverse sources (gau, katana, waymore), leveraging Wayback Machine, URLScan, Open Threat Exchange (OTX), and more to uncover the deepest attack surface.  
# 2️⃣ Smart URL Filtering & Validation → Merges and deduplicates URLs, removes unnecessary files (e.g., images, fonts, stylesheets), and verifies live endpoints using httpx.  
# 3️⃣ Aggressive Vulnerability Detection → Uses gf to classify URLs by vulnerability type (XSS, SQLi, LFI, SSRF, Open Redirect) and nuclei to scan for high-severity exploits, ensuring precise and fast security assessments.  
# 4️⃣ Instant Real-Time Alerts → Sends detailed Telegram notifications when a vulnerability is found, providing affected URLs, severity levels, and issue descriptions for immediate action. Update TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID in the script for personalized alerts.  

# 📌 Example Output  
🔍 Starting URL Discovery... ✅ URL Discovery Complete.  
⚠️ Starting Vulnerability Analysis... 🚨 New Vulnerabilities Found!  
Target: example.com | Total Vulnerabilities: 5  
- URL: https://example.com/index.php?id=1 | Template: SQL Injection  
- URL: https://example.com/profile?user=<script>alert(1)</script> | Template: XSS  

# 🚀 Why Choose P1.Urls.sh?  
# ✅ Fast & Automated – Leverages multi-threading, rapid processing, and smart deduplication for high-speed scanning.  
# ✅ Deep URL Discovery – Extracts URLs from multiple data sources, revealing hidden and forgotten endpoints.  
# ✅ Advanced Vulnerability Detection – Uses gf and nuclei for comprehensive scanning of high-impact vulnerabilities.  
# ✅ Real-Time Telegram Alerts – Get instant notifications of critical security issues.  
# ✅ Scalable & Versatile – Works with single domains, bulk lists, and subdomains for maximum flexibility.  
# ✅ Open-Source & Customizable – Modify and enhance the script to fit your security research needs.  