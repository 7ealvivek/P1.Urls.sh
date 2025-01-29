

```markdown
# 🚀 P1.Urls.sh - Aggressive URL Discovery & Nuclei Tags Scanning

🔎 A fully automated, aggressive URL discovery & vulnerability scanning script for Bug Bounty & Penetration Testing.

## ✨ Features
- **✅ Multi-Source URL Discovery**: Uses `gau`, `katana`, and `waymore` for maximum URL enumeration.
- **✅ Smart URL Classification**: Automatically detects XSS, SQLi, LFI, SSRF, Open Redirects, RCE and stores URLs instead of deleting them.
- **✅ Optimized URL Deduplication**: Ensures you only scan unique URLs.
- **✅ Aggressive & Fast**: Supports high concurrency (100 threads) & rate-limiting (200 req/sec).
- **✅ High-Speed Nuclei Scanning**: Focuses on critical, high, and medium-severity vulnerabilities.
- **✅ 📲 Real-Time Telegram Alerts with Emojis** (🔥🔥🔥).
- **✅ ⚡ Auto-Update Feature**: Ensures you always have the latest version!

## 📌 Use Cases
- **🔹 Bug Bounty Hunting**: Quickly enumerate URLs & test for injection points.
- **🔹 Web Application Penetration Testing**: Automatically identify high-risk vulnerabilities.
- **🔹 Recon Automation**: Combine with other recon tools for maximum efficiency.
- **🔹 Red Teaming**: Identify and exploit vulnerable endpoints in real-time.

## 📥 Installation
Ensure the required tools are installed before running the script:

```bash
sudo apt install parallel jq -y

go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/xnl-h4ck3r/waymore/cmd/waymore@latest
go install github.com/tomnomnom/gf@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/urldedupe@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
```

## 🚀 Usage

### Single Domain Scan
```bash
./P1.Urls.sh example.com
```

### Multiple Domains Scan
```bash
./P1.Urls.sh domains.txt
```

### Custom Output Directory
```bash
./P1.Urls.sh example.com /custom/output/
```

## 📁 Output Structure
```
results/example.com/
├── urls.txt # Unique URLs after deduplication
├── classified_urls.txt # Stored URLs classified as vulnerabilities
├── nuclei_results.json # Nuclei scan results
├── xss.txt # Stored XSS URLs
├── sqli.txt # Stored SQLi URLs
├── lfi.txt # Stored LFI URLs
├── ssrf.txt # Stored SSRF URLs
├── redirect.txt # Stored Open Redirect URLs
```

## 📲 Telegram Notifications (🔥 Real-Time Alerts)
- **📌 Automatically sends alerts & results to Telegram!**
  - ✅ Real-time vulnerability notifications
  - ✅ Critical findings with emoji-based alerts
  - ✅ Sends results as JSON files for quick analysis
```
