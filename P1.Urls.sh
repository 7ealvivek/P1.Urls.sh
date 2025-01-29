#!/bin/bash

# 🎯 P1.Urls.sh - Ultimate URL Discovery & Vulnerability Scanner
# 🚀 Version: 2.0 | Author: Vivek (realvivek)

# ✅ Mandatory Requirements
required_tools=("gau" "katana" "waymore" "gf" "httpx" "urldedupe" "nuclei" "jq")
for tool in "${required_tools[@]}"; do
  command -v "$tool" || { echo "❌ $tool missing!"; exit 1; }
done

# 🔑 REQUIRED: Add your API keys here!
export URLSCAN_API_KEY="02899922-32c3-4d1c-91b0-04aa1bc95cef"
export VIRUSTOTAL_API_KEY="639632231b5a98a6389fbc7f5d8e6c399684363dea67d6431198f9a733ed9031"

# ⚙️ Configuration
CONCURRENCY=50
RATE_LIMIT=100
OUTPUT_DIR="$(pwd)/results/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# 🎯 Main Function
scan_target() {
  target="$1"
  echo "🔍 Starting scan: $target"
  
  # 1️⃣ URL Discovery
  echo "🚀 Gathering URLs..."
  
  # GAU (Wayback/URLScan/OTX)
  gau --threads 20 --blacklist woff,css,png,svg,jpg,woff2,jpeg,gif,svg --subs --providers wayback,urlscan,otx "$target" 2>/dev/null | anew "$OUTPUT_DIR/gau.txt"
  
  # Katana (Crawling)
  katana -u "https://$target" -d 3 -kf all -c 15 -silent -duc -silent -nc -jc -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg 2>/dev/null | anew "$OUTPUT_DIR/katana.txt"
  
  # Waymore (Comprehensive)
  waymore -i "$target" -mode U -ft "font/woff,font/woff2,text/css,image/png,image/svg+xml,image/jpeg,image/gif" -oU "$OUTPUT_DIR/waymore.txt" 2>/dev/null

  # 2️⃣ Process URLs
  echo "🔄 Processing URLs ($(wc -l $OUTPUT_DIR/*.txt | tail -1 | awk '{print $1}') raw)..."
  cat "$OUTPUT_DIR"/{gau,katana,waymore}.txt | \
    urldedupe -u -s | \
    httpx -silent -status-code -title -tech-detect -fr -timeout 10 -retries 2 -o "$OUTPUT_DIR/valid_urls.txt"

  # 3️⃣ Vulnerability Classification
  echo "⚠️ Analyzing vulnerabilities..."
  [ -s "$OUTPUT_DIR/valid_urls.txt" ] && {
    gf xss "$OUTPUT_DIR/valid_urls.txt" | anew "$OUTPUT_DIR/xss.txt"
    gf sqli "$OUTPUT_DIR/valid_urls.txt" | anew "$OUTPUT_DIR/sqli.txt"
    gf lfi "$OUTPUT_DIR/valid_urls.txt" | anew "$OUTPUT_DIR/lfi.txt"
    gf ssrf "$OUTPUT_DIR/valid_urls.txt" | anew "$OUTPUT_DIR/ssrf.txt"
  }

  # 4️⃣ Nuclei Scanning
  echo "🛡️ Running Nuclei..."
  [ -s "$OUTPUT_DIR/valid_urls.txt" ] && \
    nuclei -l "$OUTPUT_DIR/valid_urls.txt" \
    -tags "xss,sqli,lfi,ssrf,rce" \
    -severity critical,high,medium \
    -rate-limit $RATE_LIMIT \
    -concurrency $CONCURRENCY \
    -silent \
    -o "$OUTPUT_DIR/nuclei_results.txt"

  echo "✅ Scan completed! Results: $OUTPUT_DIR"
}

# 🚀 Execution
[ -z "$1" ] && { echo "Usage: $0 <target/domain>"; exit 1; }
scan_target "$(echo "$1" | sed 's|https\?://||;s|/$||')"
