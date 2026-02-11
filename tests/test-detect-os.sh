#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/src/lib/colors.sh"
source "$ROOT_DIR/src/lib/detect-os.sh"

PASS=0 FAIL=0
assert_not_empty() {
  if [ -n "$2" ]; then echo -e "  ${GREEN}PASS${NC}: $1 = $2"; ((PASS++))
  else echo -e "  ${RED}FAIL${NC}: $1 empty"; ((FAIL++)); fi
}

echo "=== Test: detect-os.sh ==="
detect_os
assert_not_empty "OPENCLAW_OS" "$OPENCLAW_OS"
assert_not_empty "OPENCLAW_ARCH" "$OPENCLAW_ARCH"
assert_not_empty "OPENCLAW_HOME" "$OPENCLAW_HOME"
assert_not_empty "OPENCLAW_WORKSPACE" "$OPENCLAW_WORKSPACE"
assert_not_empty "OPENCLAW_CONFIG" "$OPENCLAW_CONFIG"

case "$OPENCLAW_OS" in
  linux|darwin|windows) echo -e "  ${GREEN}PASS${NC}: OS valid"; ((PASS++)) ;;
  *) echo -e "  ${RED}FAIL${NC}: Unknown OS"; ((FAIL++)) ;;
esac
case "$OPENCLAW_ARCH" in
  x64|arm64) echo -e "  ${GREEN}PASS${NC}: Arch valid"; ((PASS++)) ;;
  *) echo -e "  ${RED}FAIL${NC}: Unknown arch"; ((FAIL++)) ;;
esac

echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
