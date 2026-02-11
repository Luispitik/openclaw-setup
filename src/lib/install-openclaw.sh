#!/usr/bin/env bash
# ============================================================
#  install-openclaw.sh - Install OpenClaw CLI and daemon
# ============================================================

install_openclaw() {
  local setup_dir="${1:-.}"

  if command -v openclaw &>/dev/null; then
    log_success "OpenClaw ya instalado: $(openclaw --version 2>/dev/null || echo 'unknown')"
    start_gateway; return 0
  fi

  log_step "Instalando OpenClaw via npm..."
  if [ "$OPENCLAW_IS_ROOT" = true ] || [ "$OPENCLAW_OS" = "windows" ]; then
    npm install -g openclaw 2>&1 | tail -1
  else
    $SUDO npm install -g openclaw 2>&1 | tail -1
  fi

  command -v openclaw &>/dev/null || { log_error "No se pudo instalar OpenClaw."; return 1; }
  log_success "OpenClaw instalado: $(openclaw --version 2>/dev/null)"

  log_step "Configurando OpenClaw (onboarding)..."
  echo -e "yes\nGoogle Gemini\ngemini-2.5-flash\nskip" | openclaw onboard --install-daemon 2>&1 | tail -3 || {
    log_warn "Onboarding puede necesitar configuracion manual."
  }

  start_gateway
  register_rollback "rollback_openclaw" "Desinstalar OpenClaw"
  return 0
}

start_gateway() {
  log_step "Iniciando Gateway..."
  if openclaw gateway status 2>&1 | grep -qi "running\|active"; then
    log_success "Gateway ya esta corriendo"; return 0
  fi
  openclaw gateway start 2>&1 | tail -1 || true
  local retries=15
  while [ $retries -gt 0 ]; do
    openclaw gateway status 2>&1 | grep -qi "running\|active" && { log_success "Gateway corriendo en 127.0.0.1:3000"; return 0; }
    sleep 1; ((retries--))
  done
  log_warn "Gateway no confirmo inicio."
  return 0
}
