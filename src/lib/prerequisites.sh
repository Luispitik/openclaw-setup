#!/usr/bin/env bash
# ============================================================
#  prerequisites.sh - Check and install required tools
# ============================================================

install_prerequisites() {
  local setup_dir="${1:-.}"
  log_step "Verificando herramientas necesarias..."

  if command -v node &>/dev/null; then
    local node_version node_major
    node_version="$(node --version 2>/dev/null)"
    node_major="${node_version#v}"; node_major="${node_major%%.*}"
    if [ "$node_major" -ge 22 ] 2>/dev/null; then
      log_success "Node.js $node_version"
    else
      log_warn "Node.js $node_version (se necesita v22+). Actualizando..."
      install_nodejs
    fi
  else
    log_step "Node.js no encontrado. Instalando..."
    install_nodejs
  fi

  local tools_to_install=()
  for tool in git curl jq tmux sqlite3; do
    if command -v "$tool" &>/dev/null; then
      log_success "$tool"
    else
      tools_to_install+=("$tool")
    fi
  done
  [ ${#tools_to_install[@]} -gt 0 ] && {
    log_step "Instalando: ${tools_to_install[*]}"
    install_tools "${tools_to_install[@]}"
  }

  local all_ok=true
  for tool in node npm git curl jq sqlite3; do
    command -v "$tool" &>/dev/null || { log_fail "$tool no disponible"; all_ok=false; }
  done
  [ "$all_ok" = false ] && { log_error "Faltan herramientas necesarias."; return 1; }

  log_success "Todas las herramientas listas"
  return 0
}

install_nodejs() {
  case "$OPENCLAW_OS" in
    linux)
      case "$OPENCLAW_PKG_MGR" in
        apt) curl -fsSL https://deb.nodesource.com/setup_22.x | $SUDO bash - >/dev/null 2>&1; $SUDO apt-get install -y nodejs >/dev/null 2>&1 ;;
        dnf|yum) curl -fsSL https://rpm.nodesource.com/setup_22.x | $SUDO bash - >/dev/null 2>&1; $SUDO $OPENCLAW_PKG_MGR install -y nodejs >/dev/null 2>&1 ;;
        *) log_error "Instala Node.js 22+ manualmente: https://nodejs.org"; return 1 ;;
      esac ;;
    darwin)
      [ "$OPENCLAW_PKG_MGR" = "brew" ] && brew install node@22 >/dev/null 2>&1 || { log_error "Instala Homebrew: https://brew.sh"; return 1; } ;;
    windows)
      if [ "$OPENCLAW_PKG_MGR" = "choco" ]; then choco install nodejs --version=22 -y >/dev/null 2>&1
      elif [ "$OPENCLAW_PKG_MGR" = "winget" ]; then winget install OpenJS.NodeJS.LTS --silent 2>/dev/null
      else log_error "Instala Node.js 22+: https://nodejs.org"; return 1; fi ;;
  esac
  command -v node &>/dev/null && log_success "Node.js $(node --version) instalado" || { log_error "No se pudo instalar Node.js"; return 1; }
}

install_tools() {
  local tools=("$@")
  case "$OPENCLAW_OS" in
    linux)
      case "$OPENCLAW_PKG_MGR" in
        apt) $SUDO apt-get update -qq >/dev/null 2>&1; $SUDO apt-get install -y -qq "${tools[@]}" >/dev/null 2>&1 ;;
        dnf|yum) $SUDO $OPENCLAW_PKG_MGR install -y -q "${tools[@]}" >/dev/null 2>&1 ;;
      esac ;;
    darwin) [ "$OPENCLAW_PKG_MGR" = "brew" ] && brew install "${tools[@]}" >/dev/null 2>&1 ;;
    windows) for tool in "${tools[@]}"; do [ "$OPENCLAW_PKG_MGR" = "choco" ] && choco install "$tool" -y >/dev/null 2>&1; done ;;
  esac
}
