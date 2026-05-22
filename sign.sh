#!/usr/bin/env bash
# =============================================================================
# Sophon Light Node — Sign & Register
#
# Requirements: cast (Foundry)
# Install Foundry: curl -L https://foundry.paradigm.xyz | bash && foundryup
# =============================================================================

set -euo pipefail

# ─── Load config ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config"

[[ ! -f "$CONFIG_FILE" ]] && { echo "ERROR: sophon.conf not found at $CONFIG_FILE"; exit 1; }
# shellcheck source=/dev/null
source "$CONFIG_FILE"

# ─── Map config vars ──────────────────────────────────────────────────────────
OPERATOR_ADDRESS="${OPERATOR}"
DESTINATION_ADDRESS="${DESTINATION}"
NEW_SERVER_IP="${IP}"
PORT="${PORT:-7007}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ─── Validate ─────────────────────────────────────────────────────────────────
[[ -z "${PRIVATE_KEY// }" ]]      && error "PRIVATE_KEY is not set in sophon.conf."
[[ -z "$OPERATOR_ADDRESS" ]]      && error "OPERATOR is not set in sophon.conf."
[[ -z "$NEW_SERVER_IP" ]]         && error "IP is not set in sophon.conf."

NEW_URL="http://${NEW_SERVER_IP}:${PORT}"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Sophon Light Node — Sign & Register        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
info "Version   : ${VERSION}"
info "Operator  : $OPERATOR_ADDRESS"
info "Destination: $DESTINATION_ADDRESS"
info "Node URL  : $NEW_URL"
echo ""

# ─── Step 1: Timestamp ────────────────────────────────────────────────────────
TIMESTAMP=$(date +%s)
EXPIRY=$((TIMESTAMP + 900))
info "Timestamp : $TIMESTAMP"
info "Expires   : $(date -d @$EXPIRY 2>/dev/null || date -r $EXPIRY) (15 min)"
echo ""

# ─── Step 2: Sign ─────────────────────────────────────────────────────────────
if ! command -v cast &>/dev/null; then
    error "'cast' not found. Install Foundry:\n  curl -L https://foundry.paradigm.xyz | bash && foundryup"
fi

info "Signing with operator wallet..."
SIGNED_MESSAGE=$(cast sign --private-key "$PRIVATE_KEY" "$TIMESTAMP" 2>/dev/null) \
    || error "Signing failed. Check PRIVATE_KEY in sophon.conf."
success "Signed."
echo ""

# ─── Step 3: Send PUT request ─────────────────────────────────────────────────
info "Registering node with monitor.sophon.xyz..."

PAYLOAD=$(cat <<JSONEOF
{
  "operator": "${OPERATOR_ADDRESS}",
  "url": "${NEW_URL}",
  "destination": "${DESTINATION_ADDRESS}",
  "timestamp": ${TIMESTAMP}
}
JSONEOF
)

HTTP_STATUS=$(curl -s -o /tmp/sophon_response.json -w "%{http_code}" \
    -X PUT "https://monitor.sophon.xyz/nodes" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${SIGNED_MESSAGE}" \
    -d "$PAYLOAD")

RESPONSE=$(cat /tmp/sophon_response.json 2>/dev/null || echo "(no response body)")

echo ""
if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "201" ]]; then
    success "Node registered successfully! (HTTP $HTTP_STATUS)"
    echo -e "  Response: $RESPONSE"
else
    error "Request failed with HTTP $HTTP_STATUS.\n  Response: $RESPONSE"
fi

echo ""
info "Bearer token (valid 15 min):"
echo -e "  ${CYAN}Authorization: Bearer ${SIGNED_MESSAGE}${NC}"
echo ""
