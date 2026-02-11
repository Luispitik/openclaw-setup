#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  OpenClaw Setup - One-command installer
#  https://github.com/Zie619/openclaw-setup
# ============================================================

REPO_URL="https://github.com/Zie619/openclaw-setup.git"
INSTALL_DIR=""

cleanup() {
  if [ -n "$INSTALL_DIR" ] && [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
  fi
}
trap cleanup EXIT

print_banner() {
  echo ""
  echo "  ╔═══════════════════════════════════════════════════════╗"
  echo "  ║                                                       ║"
  echo "  ║     ╔═╗╔═╗╔═╗╔╗╔  ╔═╗╦  ╔═╗╦ ╦                     ║"
  echo "  ║     ║ ║╠═╝║╣ ║║║  ║  ║  ╠═╣║║║                     ║"
  echo "  ║     ╚═╝╩  ╚═╝╝╚╝  ╚═╝╩═╝╩ ╩╚╩╝                     ║"
  echo "  ║                                                       ║"
  echo "  ║     One-command AI multi-agent system setup            ║"
  echo "  ║     5 agents · SQLite · HITL Interview · Heartbeat    ║"
  echo "  ║     Mac · Linux VPS · Windows                          ║"
  echo "  ║                                                       ║"
  echo "  ╚═══════════════════════════════════════════════════════╝"
  echo ""
}

check_bash_version() {
  local major="${BASH_VERSINFO[0]:-0}"
  if [ "$major" -lt 4 ]; then
    echo "ERROR: Se necesita Bash 4+. Tienes Bash $BASH_VERSION"
    echo "  macOS: brew install bash"
    echo "  Windows: usa Git Bash (https://git-scm.com)"
    exit 1
  fi
}

check_basic_tools() {
  for tool in curl git; do
    if ! command -v "$tool" &>/dev/null; then
      echo "ERROR: '$tool' no esta instalado."
      echo "  Ubuntu/Debian: sudo apt-get install -y $tool"
      echo "  macOS: brew install $tool"
      echo "  Windows: instala Git for Windows (https://git-scm.com)"
      exit 1
    fi
  done
}

main() {
  print_banner
  echo "  Verificando requisitos basicos..."
  echo ""

  check_bash_version
  echo "  [OK] Bash ${BASH_VERSION}"

  check_basic_tools
  echo "  [OK] curl y git disponibles"
  echo ""

  # Detect if running from cloned repo
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || pwd)"
  if [ -f "$SCRIPT_DIR/src/main.sh" ]; then
    INSTALL_DIR="$SCRIPT_DIR"
    trap - EXIT
  else
    INSTALL_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'openclaw-setup')"
    echo "  Descargando openclaw-setup..."
    git clone --depth 1 --quiet "$REPO_URL" "$INSTALL_DIR" 2>/dev/null || {
      echo "ERROR: No se pudo descargar el instalador."
      echo "  Verifica tu conexion a internet e intentalo de nuevo."
      exit 1
    }
    echo "  [OK] Instalador descargado"
  fi

  echo ""
  source "$INSTALL_DIR/src/main.sh"
  run_installer "$INSTALL_DIR"
}

main "$@"
