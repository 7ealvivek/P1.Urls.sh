#!/bin/bash
# 🎯 P1.Urls.sh - Ultimate URL Discovery & Vulnerability Scanner
# 🚀 Version: 3.3 | Author: Vivek (realvivek)
# ✅ Mandatory Requirements
required_tools=("gau" "katana" "waymore" "gf" "httpx" "nuclei")
for tool in "${required_tools[@]}"; do
  command -v "$tool" || { echo "❌ $tool missing!"; exit 1; }
done

# Input Validation
TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "❌ Error: No target provided!"
  echo "Usage: $0 <target-domain>"
  exit 1
fi

# ⚙️ Configuration
OUTPUT_DIR="results/$(date +%s)"
mkdir -p "$OUTPUT_DIR"

# 🚀 Optimized Discovery
run_discovery() {
  echo "🔍 Phase 1: URL Discovery"
  
  # 1. GAU
  echo "🚀 Running GAU..."
  gau --threads 20 --blacklist woff,css,png,svg,jpg,woff2,jpeg,gif,svg --subs --providers wayback,urlscan,otx "$TARGET" 2>/dev/null | anew "$OUTPUT_DIR/gau.txt"
  
  # 2. Katana
  echo "🚀 Running Katana..."
  timeout 900 katana -u "https://$TARGET" -d 3 -kf all -c 15 -silent -duc -nc -jc -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg 2>/dev/null | anew "$OUTPUT_DIR/katana.txt"
  
  # 3. Waymore
  echo "🚀 Running Waymore..."
  waymore -i "$TARGET" -mode U -ft "font/woff,font/woff2,text/css,image/png,image/svg+xml,image/jpeg,image/gif" -oU "$OUTPUT_DIR/waymore.txt" 2>/dev/null
}

# 🛠️ URL Processing
process_urls() {
  echo "🔄 Phase 2: URL Processing"
  
  # Step 1: Merge and deduplicate
  echo "🔗 Merging URLs..."
  cat "$OUTPUT_DIR"/{gau,katana,waymore}.txt | sort | uniq | tee "$OUTPUT_DIR/all_unique_urls.txt" | wc -l | awk '{print "📊 Total unique URLs:", $1}'
  
  # Step 2: Filter valid URLs
  echo "🔍 Validating URLs..."
  cat "$OUTPUT_DIR/all_unique_urls.txt" | grep -E '^https?://' | perl -MURI::Escape -ne 'chomp; print uri_unescape($_), "\n"' | httpx -silent -timeout 30 > "$OUTPUT_DIR/valid_urls.txt"
  
  # Report valid URLs
  wc -l "$OUTPUT_DIR/valid_urls.txt" | awk '{print "📊 Valid URLs:", $1}'
}

# 🔥 Vulnerability Detection
detect_vulns() {
  echo "⚠️ Phase 3: Vulnerability Analysis"
  
  # GF Pattern Classification
  echo "🕵️ Running GF patterns..."
  gf_patterns=("xss" "sqli" "lfi" "ssrf" "redirect")
  for pattern in "${gf_patterns[@]}"; do
    echo "🔎 Checking $pattern..."
    gf "$pattern" "$OUTPUT_DIR/valid_urls.txt" | tee "$OUTPUT_DIR/${pattern}_urls.txt" | wc -l | awk -v pat="$pattern" '{print "📊 " pat " URLs:", $1}'
  done
  
  # Nuclei Scanning
  echo "🛡️ Running Nuclei..."
  nuclei -update-templates
  nuclei -l "$OUTPUT_DIR/valid_urls.txt" \
    -tags "sqli,xss,lfi,ssrf" \
    -severity critical,high,medium \
    -rate-limit 100 \
    -concurrency 50 \
    -silent \
    -o "$OUTPUT_DIR/nuclei_results.txt"
  
  # Immediate Reporting
  if [ -s "$OUTPUT_DIR/nuclei_results.txt" ]; then
    echo "🚨 Vulnerabilities Found! Check '$OUTPUT_DIR/nuclei_results.txt' for details."
    head -n 10 "$OUTPUT_DIR/nuclei_results.txt"
  else
    echo "✅ No vulnerabilities found."
  fi
}

# 🚦 Main Execution
{
  run_discovery
  process_urls
  detect_vulns
} 2>&1 | tee "$OUTPUT_DIR/scan.log"
echo "✅ Final Output: $OUTPUT_DIR"
