#!/bin/bash 

# 🎯 P1.Urls.sh - Aggressive URL Discovery & Vulnerability Scanning (Now with Waymore!)
# 🚀 Author: Vivek (realvivek)
# 🛡️ Description: Discovers URLs using gau, katana, waymore & scans them with Nuclei.

VERSION="1.3.0"

# ✅ One-Line Tool Verification
for tool in gau katana waymore gf httpx urldedupe nuclei parallel jq; do
  command -v "$tool" &>/dev/null || { echo "❌ $tool not installed! Install it first."; exit 1; }
done

# ⚙️ Configuration
CONCURRENCY=100
RATE_LIMIT=200
DELAY=1
USER_AGENTS_FILE="user_agents.txt"
NUCLEI_TEMPLATES="~/nuclei-templates"
INJECTION_TAGS="xss,sqli,lfi,ssrf,rce"
TELEGRAM_TOKEN="7474418301:AAEQwa4SDAg3oZipZW8dD_d-Z19J_lvuuuE"
TELEGRAM_CHAT_ID="994467652"

# 📂 Configure Input & Output
INPUT="$1"
TARGET_NAME=$(basename "$INPUT" .txt | awk -F'.' '{print $(NF-1)"."$NF}')
OUTPUT_DIR="${2:-results}/$TARGET_NAME"
mkdir -p "$OUTPUT_DIR"

# 📲 Telegram Notification Functions
send_telegram_message() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" -d text="$message" -d parse_mode="Markdown" >/dev/null
}

send_telegram_file() {
  local file_path="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_CHAT_ID}" -F document="@${file_path}" >/dev/null
}

# 🎭 Generate Random User-Agent
random_ua() {
  [ -f "$USER_AGENTS_FILE" ] && shuf -n 1 "$USER_AGENTS_FILE" || echo "Mozilla/5.0 (Windows NT 10.0; rv:102.0)"
}

HTTPX_OPTIONS=(
  -random-agent -status-code -content-length -title -tech-detect
  -rate-limit "$RATE_LIMIT" -threads "$CONCURRENCY" -timeout 5 -retries 2 -json
)

process_target() {
  DOMAIN="$1"
  echo "🔍 Scanning: $DOMAIN"

  # 🌐 Fetch URLs
  gau --threads 20 --blacklist png,jpg,gif,svg,css,woff2,woff,ttf --fc 404,403 "$DOMAIN" | anew "$OUTPUT_DIR/gau.txt" >/dev/null
  katana -u "https://$DOMAIN" -d 3 -jc -kf all -c 15 -H "User-Agent: $(random_ua)" -o "$OUTPUT_DIR/katana.txt"
  waymore -i "$DOMAIN" -mode U --retries 3 --timeout 10 --memory-threshold 95 --processes 5 --config ~/.config/waymore/config.yml -o "$OUTPUT_DIR/waymore.txt"

  # 🔄 Deduplicate URLs
  cat "$OUTPUT_DIR"/{gau,katana,waymore}.txt | urldedupe -u -s | httpx -silent "${HTTPX_OPTIONS[@]}" | jq -r .url | anew "$OUTPUT_DIR/urls.txt" >/dev/null

  # ⚠️ Classify Vulnerabilities
  gf xss < "$OUTPUT_DIR/urls.txt" | anew "$OUTPUT_DIR/xss.txt" >/dev/null
  gf sqli < "$OUTPUT_DIR/urls.txt" | anew "$OUTPUT_DIR/sqli.txt" >/dev/null
  gf lfi < "$OUTPUT_DIR/urls.txt" | anew "$OUTPUT_DIR/lfi.txt" >/dev/null
  gf ssrf < "$OUTPUT_DIR/urls.txt" | anew "$OUTPUT_DIR/ssrf.txt" >/dev/null
  gf redirect < "$OUTPUT_DIR/urls.txt" | anew "$OUTPUT_DIR/redirect.txt" >/dev/null

  # 🛑 Save All Classified URLs
  cat "$OUTPUT_DIR"/{xss,sqli,lfi,ssrf,redirect}.txt | urldedupe -u -s | anew "$OUTPUT_DIR/classified_urls.txt" >/dev/null

  # 🏴‍☠️ Run Nuclei
  if [ -s "$OUTPUT_DIR/classified_urls.txt" ]; then
    nuclei -t "$NUCLEI_TEMPLATES" -tags "$INJECTION_TAGS" -severity critical,high,medium -exclude-tags "misc,info" \
      -l "$OUTPUT_DIR/classified_urls.txt" -random-agent -rate-limit "$RATE_LIMIT" -concurrency "$CONCURRENCY" \
      -retries 2 -disable-update-check -json -o "$OUTPUT_DIR/nuclei_results.json"

    # 🔔 Notify Findings
    if [ -s "$OUTPUT_DIR/nuclei_results.json" ]; then
      send_telegram_file "$OUTPUT_DIR/nuclei_results.json"
    fi
  fi
}

# 🚀 Main Execution
if [ -f "$INPUT" ]; then
  # Process each line in the input file
  while IFS= read -r target; do
    # Normalize the target (remove http:// or https://)
    target=$(echo "$target" | sed -E 's#^https?://##')
    process_target "$target"
  done < "$INPUT"
else
  # Process a single target
  target=$(echo "$INPUT" | sed -E 's#^https?://##')
  process_target "$target"
fi

# ✅ Results Ready
echo "📁 Results stored in: $OUTPUT_DIR/"
