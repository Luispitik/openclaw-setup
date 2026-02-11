#!/usr/bin/env bash
# ============================================================
#  detect-os.sh - Platform detection
# ============================================================

detect_os() {
  local uname_out
  uname_out="$(uname -s 2>/dev/null || echo "Unknown")"

  case "$uname_out" in
    Linux*)
      OPENCLAW_OS="linux"
      if [ -f /etc/os-release ]; then
        source /etc/os-release
        OPENCLAW_DISTRO="${ID:-unknown}"
        OPENCLAW_DISTRO_VERSION="${VERSION_ID:-unknown}"
      else
        OPENCLAW_DISTRO="unknown"; OPENCLAW_DISTRO_VERSION="unknown"
      fi
      ;;
    Darwin*)
      OPENCLAW_OS="darwin"
      OPENCLAW_DISTRO="macos"
      OPENCLAW_DISTRO_VERSION="$(sw_vers -productVersion 2>/dev/null || echo 'unknown')"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      OPENCLAW_OS="windows"
      OPENCLAW_DISTRO="windows"
      OPENCLAW_DISTRO_VERSION="$(cmd.exe /c 'ver' 2>/dev/null | grep -oP '\d+\.\d+' | head -1 || echo 'unknown')"
      ;;
    *)
      log_error "Sistema operativo no reconocido: $uname_out"
      exit 1
      ;;
  esac

  OPENCLAW_ARCH="$(uname -m 2>/dev/null || echo 'unknown')"
  case "$OPENCLAW_ARCH" in
    x86_64|amd64) OPENCLAW_ARCH="x64" ;;
    aarch64|arm64) OPENCLAW_ARCH="arm64" ;;
  esac

  case "$OPENCLAW_OS" in
    linux)
      command -v apt-get &>/dev/null && OPENCLAW_PKG_MGR="apt" || \
      command -v dnf &>/dev/null && OPENCLAW_PKG_MGR="dnf" || \
      command -v yum &>/dev/null && OPENCLAW_PKG_MGR="yum" || \
      OPENCLAW_PKG_MGR="unknown"
      ;;
    darwin)
      command -v brew &>/dev/null && OPENCLAW_PKG_MGR="brew" || OPENCLAW_PKG_MGR="none"
      ;;
    windows)
      command -v choco &>/dev/null && OPENCLAW_PKG_MGR="choco" || \
      command -v winget &>/dev/null 2>&1 && OPENCLAW_PKG_MGR="winget" || \
      OPENCLAW_PKG_MGR="none"
      ;;
  esac

  case "$OPENCLAW_OS" in
    linux)  command -v systemctl &>/dev/null && OPENCLAW_SERVICE_MGR="systemd" || OPENCLAW_SERVICE_MGR="none" ;;
    darwin) OPENCLAW_SERVICE_MGR="launchd" ;;
    windows) command -v nssm &>/dev/null && OPENCLAW_SERVICE_MGR="nssm" || OPENCLAW_SERVICE_MGR="schtasks" ;;
  esac

  case "$OPENCLAW_OS" in
    windows) OPENCLAW_HOME="${USERPROFILE:-$HOME}" ;;
    *) OPENCLAW_HOME="$HOME" ;;
  esac

  OPENCLAW_WORKSPACE="$OPENCLAW_HOME/.openclaw/workspace"
  OPENCLAW_CONFIG="$OPENCLAW_HOME/.openclaw/openclaw.json"

  OPENCLAW_IS_ROOT=false
  [ "$(id -u 2>/dev/null)" = "0" ] && OPENCLAW_IS_ROOT=true

  if [ "$OPENCLAW_IS_ROOT" = true ]; then SUDO=""; else SUDO="sudo"; fi

  export OPENCLAW_OS OPENCLAW_ARCH OPENCLAW_DISTRO OPENCLAW_DISTRO_VERSION
  export OPENCLAW_PKG_MGR OPENCLAW_SERVICE_MGR OPENCLAW_HOME
  export OPENCLAW_WORKSPACE OPENCLAW_CONFIG OPENCLAW_IS_ROOT SUDO
}

print_detected_os() {
  log_success "Sistema detectado:"
  log_info "  OS: $OPENCLAW_OS ($OPENCLAW_DISTRO $OPENCLAW_DISTRO_VERSION)"
  log_info "  Arquitectura: $OPENCLAW_ARCH"
  log_info "  Gestor de paquetes: $OPENCLAW_PKG_MGR"
  log_info "  Gestor de servicios: $OPENCLAW_SERVICE_MGR"
  log_info "  Home: $OPENCLAW_HOME"
}
