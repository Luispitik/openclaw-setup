#!/usr/bin/env bash
# ============================================================
#  colors.sh - Logging, colors, and UI utilities
# ============================================================

if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' NC=''
fi

log_phase() {
  echo ""
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

log_step() { echo -e "  ${CYAN}▸${NC} $1"; }
log_success() { echo -e "  ${GREEN}✔${NC} $1"; }
log_error() { echo -e "  ${RED}✘${NC} $1" >&2; }
log_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
log_info() { echo -e "  ${DIM}ℹ${NC} $1"; }
log_pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "  ${RED}[FAIL]${NC} $1"; }

show_progress() {
  local current=$1 total=$2 label=$3
  local pct=$((current * 100 / total))
  local filled=$((pct / 5))
  local empty=$((20 - filled))
  printf "\r  ${CYAN}[${NC}"
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
  printf "${CYAN}]${NC} %3d%% - %s" "$pct" "$label"
  [ "$current" -eq "$total" ] && echo ""
}

confirm() {
  local msg="${1:-Continuar?}" default="${2:-n}"
  if [ "$default" = "y" ]; then
    printf "  ${YELLOW}?${NC} %s [Y/n]: " "$msg"
  else
    printf "  ${YELLOW}?${NC} %s [y/N]: " "$msg"
  fi
  read -r response
  response="${response:-$default}"
  case "$response" in
    [yY][eE][sS]|[yY]|[sS][iI]|[sS]) return 0 ;;
    *) return 1 ;;
  esac
}
