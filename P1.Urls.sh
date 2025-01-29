#!/bin/bash

# 🎯 P1.Urls.sh - Aggressive URL Discovery & Vulnerability Scanning
# 🚀 Author: Vivek (realvivek)
# 🛡️ Version: 1.4.0

VERSION="1.4.0"

# ✅ Tool Verification
required_tools=("gau" "katana" "waymore" "gf" "httpx" "urldedupe" "nuclei" "parallel" "jq")
for tool in "${required_tools[@]}"; do
  command -v "$tool" &>/dev/null || { echo "❌ $tool not installed!"; exit 1; }
done

# ⚙️ Configuration
CONCURRENCY=50
RATE_LIMIT=100
DELAY=1
USER_AGENTS_FILE="user_agents.txt"
NUCLEI_TEMPLATES="$HOME/nuclei-templates"
INJECTION_TAGS="xss,sqli,lfi,ssrf,rce"

# 🔑 API Keys (REPLACE WITH YOUR OWN)
export URLSCAN_API_KEY="your_urlscan_api_key"
export VIRUSTOTAL_API_KEY="your_virustotal_api_key"

# 📂 Configure Input & Output
INPUT="$1"
TARGET_NAME=$(basename "$INPUT" .txt | awk -F'.' '{print $(NF-1)"."$NF}')
OUTPUT_DIR="${2:-results}/$TARGET_NAME"
mkdir -p "$OUTPUT_DIR"

# 📲 Telegram Notification Functions (Optional)
send_telegram_file() {
  [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ] && return
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_CHAT_ID}" -F document="@${1}" >/dev/null
}

# 🎭 Random User-Agent
random_ua() {
  [ -f "$USER_AGENTS_FILE" ] && shuf -n 1 "$USER_AGENTS_FILE" || echo "Mozilla/5.0 (Windows NT 10.0; rv:102.0)"
}

HTTPX_OPTIONS=(
  -status-code -content-length -title -tech-detect
  -rate-limit "$RATE_LIMIT" -threads "$CONCURRENCY" -timeout 5 -retries 2 -json -silent
)

process_target() {
  local DOMAIN="$1"
  echo "🔍 Scanning: $DOMAIN"

  # 🌐 URL Discovery
  echo "🚀 Running discovery tools..."
  gau --threads 20 --blacklist woff,css,png,svg,jpg,woff2,jpeg,gif,svg --providers wayback,otx,urlscan --subs --fc 404,403 "$DOMAIN" | anew "$OUTPUT_DIR/gau.txt" >/dev/null
  katana -u "https://$DOMAIN" -duc -silent -nc -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -d 3 -jc -kf -fx -xhr -c 15 -H "User-Agent: $(random_ua)" -o "$OUTPUT_DIR/katana.txt" >/dev/null
  waymore -i "$DOMAIN" -mode U -oU "$OUTPUT_DIR/waymore.txt" 2>/dev/null

  # 🔄 Advanced Deduplication
  echo "🔄 Processing URLs..."
  cat "$OUTPUT_DIR"/{gau,katana,waymore}.txt | \
    sed -E '
      s|#.*$||;           # Remove fragments
      s|/[^/]+$|/|;       # Normalize paths
      s|/:([0-9]+)/|:\1/|g;
      s|/?$||;
      s|:80/|/|g;
      s|:443/|/|g;
      s|www\.||gi;
    ' | \
    urldedupe -u -s | \
    httpx "${HTTPX_OPTIONS[@]}" -o "$OUTPUT_DIR/httpx.json"

  # 🎯 Extract Valid URLs
  jq -r '.url' "$OUTPUT_DIR/httpx.json" | anew "$OUTPUT_DIR/valid_urls.txt" >/dev/null

  # ⚠️ Vulnerability Classification
  echo "⚠️ Classifying vulnerabilities..."
  gf_patterns=("xss" "sqli" "lfi" "ssrf" "redirect" "rce" "ssti")
  for pattern in "${gf_patterns[@]}"; do
    gf "$pattern" < "$OUTPUT_DIR/valid_urls.txt" | anew "$OUTPUT_DIR/${pattern}.txt" >/dev/null
  done

  # 🛡️ Nuclei Scanning
  if [ -s "$OUTPUT_DIR/valid_urls.txt" ]; then
    echo "🛡️ Running Nuclei..."
    nuclei \
      -l "$OUTPUT_DIR/valid_urls.txt" \
      -tags "$INJECTION_TAGS" \
      -severity critical,high,medium \
      -rate-limit "$RATE_LIMIT" \
      -concurrency "$CONCURRENCY" \
      -retries 2 \
      -disable-update-check \
      -j -o "$OUTPUT_DIR/nuclei.json"
    
    # Format results
    jq < "$OUTPUT_DIR/nuclei.json" > "$OUTPUT_DIR/nuclei_results.txt"
    
    # Optional Telegram notification
    [ -s "$OUTPUT_DIR/nuclei_results.txt" ] && send_telegram_file "$OUTPUT_DIR/nuclei_results.txt"
  else
    echo "🔴 No valid URLs for Nuclei scanning"
  fi
}

# 🚀 Main Execution
if [ -f "$INPUT" ]; then
  while IFS= read -r target; do
    process_target "$(echo "$target" | sed -E 's#^https?://##; s|/$||')"
  done < "$INPUT"
else
  process_target "$(echo "$INPUT" | sed -E 's#^https?://##; s|/$||')"
fi

echo "✅ Scan completed! Results: $OUTPUT_DIR"
