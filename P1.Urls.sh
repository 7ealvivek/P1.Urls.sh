#!/bin/bash
# 🎯 P1.Urls.sh - Ultimate URL Discovery & Vulnerability Scanner
# 🚀 Version: 3.1 | Author: Vivek (realvivek)
# ✅ Mandatory Requirements
required_tools=("gau" "katana" "waymore" "gf" "httpx" "urldedupe" "nuclei" "parallel")
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
  if ! gau --threads 20 --blacklist woff,css,png,svg,jpg,woff2,jpeg,gif,svg --subs --providers wayback,urlscan,otx "$TARGET" 2>/dev/null | anew "$OUTPUT_DIR/gau.txt"; then
    echo "❌ GAU failed!"
    exit 1
  fi
  
  # 2. Katana
  echo "🚀 Running Katana..."
  if ! timeout 900 katana -u "https://$TARGET" -d 3 -kf all -c 15 -silent -duc -nc -jc -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg 2>/dev/null | anew "$OUTPUT_DIR/katana.txt"; then
    echo "❌ Katana failed!"
    exit 1
  fi
  
  # 3. Waymore
  echo "🚀 Running Waymore..."
  if ! waymore -i "$TARGET" -mode U -ft "font/woff,font/woff2,text/css,image/png,image/svg+xml,image/jpeg,image/gif" -oU "$OUTPUT_DIR/waymore.txt" 2>/dev/null; then
    echo "❌ Waymore failed!"
    exit 1
  fi
}

# 🛠️ URL Processing
process_urls() {
  echo "🔄 Phase 2: URL Processing"
  
  # Step 1: Merge and deduplicate
  echo "🔗 Merging URLs..."
  if [ ! -s "$OUTPUT_DIR/gau.txt" ] || [ ! -s "$OUTPUT_DIR/katana.txt" ] || [ ! -s "$OUTPUT_DIR/waymore.txt" ]; then
    echo "❌ Error: One or more discovery tools failed to generate output."
    exit 1
  fi
  
  cat "$OUTPUT_DIR"/{gau,katana,waymore}.txt | urldedupe -u -s | tee "$OUTPUT_DIR/all_unique_urls.txt" | wc -l | awk '{print "📊 Total unique URLs:", $1}'
  
  # Step 2: Validate with httpx
  echo "🔍 Validating URLs..."
  cat "$OUTPUT_DIR/all_unique_urls.txt" | httpx -silent -fr -timeout 15 -o "$OUTPUT_DIR/valid_urls.txt"
  
  # Step 3: Extract parameterized URLs
  echo "🎯 Extracting parameterized URLs..."
  grep '?' "$OUTPUT_DIR/valid_urls.txt" > "$OUTPUT_DIR/params_urls.txt"
  wc -l "$OUTPUT_DIR/params_urls.txt" | awk '{print "📊 Parameterized URLs:", $1}'
  
  # Fallback if no parameterized URLs
  if [ ! -s "$OUTPUT_DIR/params_urls.txt" ]; then
    echo "⚠️ No parameterized URLs found. Falling back to scanning all valid URLs..."
    cp "$OUTPUT_DIR/valid_urls.txt" "$OUTPUT_DIR/params_urls.txt"
  fi
}

# 🔥 Vulnerability Detection
detect_vulns() {
  echo "⚠️ Phase 3: Vulnerability Analysis"
  
  # GF Pattern Detection
  echo "🕵️ Running GF patterns..."
  gf_patterns=("xss" "sqli" "lfi" "ssrf" "redirect")
  for pattern in "${gf_patterns[@]}"; do
    echo "🔎 Checking $pattern..."
    gf "$pattern" "$OUTPUT_DIR/params_urls.txt" | tee "$OUTPUT_DIR/${pattern}_urls.txt" | wc -l | awk -v pat="$pattern" '{print "📊 " pat " URLs:", $1}'
  done
  
  # Nuclei Scanning
  echo "🛡️ Running Nuclei..."
  nuclei -update-templates
  nuclei -l "$OUTPUT_DIR/params_urls.txt" \
    -tags "xss,sqli,lfi,ssrf" \
    -severity critical,high,medium \
    -rate-limit 100 \
    -concurrency 50 \
    -silent \
    -o "$OUTPUT_DIR/nuclei_results.txt"
  
  # Show quick stats
  echo "📊 Nuclei Findings:"
  grep -c "\[.*\]" "$OUTPUT_DIR/nuclei_results.txt" | awk '{print "  Total findings:", $1}'
}

# 🚦 Main Execution
{
  run_discovery
  process_urls
  detect_vulns
} 2>&1 | tee "$OUTPUT_DIR/scan.log"
echo "✅ Final Output: $OUTPUT_DIR"
