#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/src/lib/colors.sh"

PASS=0 FAIL=0
assert_match() { [[ "$3" =~ $2 ]] && { echo -e "  ${GREEN}PASS${NC}: $1"; ((PASS++)); } || { echo -e "  ${RED}FAIL${NC}: $1"; ((FAIL++)); }; }
assert_no_match() { [[ ! "$3" =~ $2 ]] && { echo -e "  ${GREEN}PASS${NC}: $1 rejected"; ((PASS++)); } || { echo -e "  ${RED}FAIL${NC}: $1 should not match"; ((FAIL++)); }; }

echo "=== Test: credential validation patterns ==="

TP='^[0-9]+:[A-Za-z0-9_-]+$'
assert_match "Valid TG token" "$TP" "123456789:AABBCCDDEEFFtest-token_123"
assert_no_match "Invalid (no colon)" "$TP" "123456789AABBCCDDEEFFtest"

TI='^[0-9]{5,15}$'
assert_match "Valid user ID" "$TI" "123456789"
assert_no_match "Invalid (too short)" "$TI" "123"

echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
