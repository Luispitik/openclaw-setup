#!/usr/bin/env bash
# ============================================================
#  security.sh - Security hardening
# ============================================================

harden_security() {
  local setup_dir="${1:-.}"
  log_step "Aplicando medidas de seguridad..."

  # Remove session-logs
  if [ -d "$OPENCLAW_WORKSPACE/skills/session-logs" ]; then
    rm -rf "$OPENCLAW_WORKSPACE/skills/session-logs"
    log_success "session-logs eliminado (ahorro: 95% tokens)"
  else
    log_success "session-logs ya eliminado"
  fi

  # Verify config
  grep -q '"127.0.0.1"' "$OPENCLAW_CONFIG" 2>/dev/null && \
    log_success "Gateway en loopback (127.0.0.1)" || log_warn "Gateway NO en loopback"
  grep -q '"pairing"' "$OPENCLAW_CONFIG" 2>/dev/null && \
    log_success "DM policy: pairing" || log_warn "DM policy no es pairing"
  grep -q '"config_patch_enabled": false' "$OPENCLAW_CONFIG" 2>/dev/null && \
    log_success "Config patch deshabilitado" || log_warn "Config patch activo"

  # Platform firewall
  case "$OPENCLAW_OS" in
    linux) setup_firewall_linux ;;
    darwin) log_info "macOS: verifica Firewall en Preferencias > Seguridad" ;;
    windows) log_info "Windows: verifica Firewall en Configuracion > Seguridad" ;;
  esac

  log_success "Seguridad configurada"
  return 0
}

setup_firewall_linux() {
  command -v ufw &>/dev/null || {
    $SUDO apt-get install -y -qq ufw >/dev/null 2>&1 || { log_warn "No se pudo instalar ufw."; return 0; }
  }
  $SUDO ufw allow ssh >/dev/null 2>&1
  echo "y" | $SUDO ufw enable >/dev/null 2>&1
  $SUDO ufw status | grep -q "active" && \
    log_success "Firewall UFW activo (SSH permitido, 3000 NO expuesto)" || \
    log_warn "Activa manualmente: sudo ufw enable"
}
