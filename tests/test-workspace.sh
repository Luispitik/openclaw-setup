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
cleanup() { rm -rf "$TEST_DIR"; }
trap cleanup EXIT

source "$ROOT_DIR/src/lib/workspace.sh"
echo "=== Test: workspace.sh (temp: $TEST_DIR) ==="
create_workspace "$ROOT_DIR"

for dir in "00_CORE" "01_AGENTS/cami/memory/daily" "01_AGENTS/dev_agent/memory/daily" \
  "02_PROJECTS" "03_MEMORY/daily" "04_SKILLS/proposal_service" "05_TOOLS" \
  "06_CRON/heartbeat" "07_OUTPUTS/reports" "08_LOGS/agent_activity"; do
  if [ -d "$OPENCLAW_WORKSPACE/$dir" ]; then
    echo -e "  ${GREEN}PASS${NC}: $dir"; ((PASS++))
  else
    echo -e "  ${RED}FAIL${NC}: $dir"; ((FAIL++))
  fi
done
[ -d "$TEST_DIR/ClawWork" ] && { echo -e "  ${GREEN}PASS${NC}: ClawWork"; ((PASS++)); } || { echo -e "  ${RED}FAIL${NC}: ClawWork"; ((FAIL++)); }

echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
