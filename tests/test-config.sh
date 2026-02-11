#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/src/lib/colors.sh"
source "$ROOT_DIR/src/lib/detect-os.sh"
source "$ROOT_DIR/src/lib/rollback.sh"

PASS=0 FAIL=0
TEST_DIR="$(mktemp -d)"
OPENCLAW_HOME="$TEST_DIR"
OPENCLAW_WORKSPACE="$TEST_DIR/.openclaw/workspace"
OPENCLAW_CONFIG="$TEST_DIR/.openclaw/openclaw.json"
mkdir -p "$TEST_DIR/.openclaw"
cleanup() { rm -rf "$TEST_DIR"; }
trap cleanup EXIT

source "$ROOT_DIR/src/lib/config.sh"
echo "=== Test: config.sh ==="
write_config "$ROOT_DIR"

chk() {
  if grep -q "$2" "$OPENCLAW_CONFIG" 2>/dev/null; then
    echo -e "  ${GREEN}PASS${NC}: $1"; ((PASS++))
  else
    echo -e "  ${RED}FAIL${NC}: $1"; ((FAIL++))
  fi
}

[ -f "$OPENCLAW_CONFIG" ] && { echo -e "  ${GREEN}PASS${NC}: File created"; ((PASS++)); } || { echo -e "  ${RED}FAIL${NC}: File missing"; ((FAIL++)); }
chk "Host 127.0.0.1" '"127.0.0.1"'
chk "Port 3000" '"port": 3000'
chk "Pairing" '"pairing"'
chk "Sandbox non-main" '"non-main"'
chk "Config patch off" '"config_patch_enabled": false'
chk "Flash default" '"gemini-2.5-flash"'
chk "Auto load off" '"auto_load": false'
chk "Max 8kb" '"max_file_size_kb": 8'

echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
