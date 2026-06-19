#!/bin/bash
# =============================================================
# M3 — ChainBreaker Attack Module
# Script : nmap_scan.sh
# Purpose: Network reconnaissance — host discovery, port scan,
#           service fingerprinting, vulnerability detection
# Author : Member 3 — Attacker
# Usage  : chmod +x nmap_scan.sh && ./nmap_scan.sh
# =============================================================

set -euo pipefail

TARGET="${1:-192.168.1.0/24}"   # Pass network range as arg or set default
OUTPUT_DIR="./nmap_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "============================================="
echo "  ChainBreaker — nmap Recon  [M3 Attacker]"
echo "  Target : $TARGET"
echo "  Output : $OUTPUT_DIR"
echo "============================================="

mkdir -p "$OUTPUT_DIR"

# ── PHASE 1: Host Discovery (ping sweep) ──────────────────────
echo ""
echo "[1/4] Running host discovery (ping sweep)..."
nmap -sn "$TARGET" \
  -oN "$OUTPUT_DIR/hosts_alive_${TIMESTAMP}.txt" \
  --exclude 127.0.0.1

LIVE_HOSTS="$OUTPUT_DIR/hosts_alive_${TIMESTAMP}.txt"
echo "[+] Live hosts saved → $LIVE_HOSTS"

# ── PHASE 2: Full Port + Service + OS Scan ────────────────────
echo ""
echo "[2/4] Running full port + service + OS detection..."
nmap -sV -sC -O -p- --open \
  -iL "$LIVE_HOSTS" \
  -oN "$OUTPUT_DIR/full_scan_${TIMESTAMP}.txt" \
  -oX "$OUTPUT_DIR/full_scan_${TIMESTAMP}.xml" \
  --min-rate 1000 \
  --max-retries 2

echo "[+] Full scan saved → $OUTPUT_DIR/full_scan_${TIMESTAMP}.txt"

# ── PHASE 3: Targeted HTTP/Auth Scan ─────────────────────────
echo ""
echo "[3/4] Running targeted HTTP + auth scripts..."
nmap -p 80,443,8080,8443,8888 \
  --script http-auth-finder,http-title,http-methods,http-headers \
  -iL "$LIVE_HOSTS" \
  -oN "$OUTPUT_DIR/http_scan_${TIMESTAMP}.txt"

echo "[+] HTTP scan saved → $OUTPUT_DIR/http_scan_${TIMESTAMP}.txt"

# ── PHASE 4: Vulnerability Scripts ───────────────────────────
echo ""
echo "[4/4] Running vulnerability NSE scripts..."
nmap --script vuln \
  -iL "$LIVE_HOSTS" \
  -oN "$OUTPUT_DIR/vuln_scan_${TIMESTAMP}.txt"

echo "[+] Vuln scan saved → $OUTPUT_DIR/vuln_scan_${TIMESTAMP}.txt"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "============================================="
echo " [DONE] All scans complete."
echo " Results folder : $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/"
echo "============================================="
