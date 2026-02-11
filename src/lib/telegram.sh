#!/usr/bin/env bash
# ============================================================
#  telegram.sh - Optional Telegram bot integration
# ============================================================

setup_telegram() {
  local setup_dir="${1:-.}"
  if [ "$WANT_TELEGRAM" != true ]; then
    log_info "Telegram no configurado (opcional). Configura despues con:"
    log_info "  openclaw channels add telegram --token TOKEN --session agent:cami:main --allowed-users USER_ID"
    return 0
  fi

  log_step "Conectando Telegram..."
  [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_USER_ID" ] && { log_warn "Credenciales Telegram no disponibles."; return 0; }

  openclaw channels add telegram \
    --token "$TELEGRAM_TOKEN" \
    --session "agent:cami:main" \
    --allowed-users "$TELEGRAM_USER_ID" 2>&1 | tail -3

  openclaw channels status 2>&1 | grep -qi "telegram" && \
    log_success "Telegram conectado. Enviale 'Hola' a tu bot." || \
    log_warn "Verifica con: openclaw channels status"

  register_rollback "rollback_telegram" "Desconectar Telegram"
  return 0
}
