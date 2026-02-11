#!/usr/bin/env bash
# ============================================================
#  rollback.sh - Rollback mechanism for failed installations
# ============================================================

ROLLBACK_STACK=()
ROLLBACK_ENABLED=true

register_rollback() {
  local fn_name="$1"
  local description="${2:-$fn_name}"
  ROLLBACK_STACK+=("$fn_name|$description")
}

execute_rollback() {
  [ "$ROLLBACK_ENABLED" != true ] && return 0
  echo ""
  log_warn "La instalacion fallo. Deshaciendo cambios..."
  echo ""
  local total=${#ROLLBACK_STACK[@]}
  [ "$total" -eq 0 ] && { log_info "No hay cambios que deshacer."; return 0; }
  for ((i = total - 1; i >= 0; i--)); do
    local entry="${ROLLBACK_STACK[$i]}"
    local fn_name="${entry%%|*}" description="${entry#*|}"
    log_step "Deshaciendo: $description"
    if type "$fn_name" &>/dev/null; then
      $fn_name 2>/dev/null && log_success "OK" || log_warn "Problema (no critico)"
    fi
  done
  echo ""
  log_info "Rollback completado."
}

rollback_workspace() {
  [ -d "$OPENCLAW_WORKSPACE" ] && rm -rf "$OPENCLAW_WORKSPACE"
  [ -d "$OPENCLAW_HOME/ClawWork" ] && rm -rf "$OPENCLAW_HOME/ClawWork"
}

rollback_config() {
  if [ -f "${OPENCLAW_CONFIG}.bak" ]; then
    mv "${OPENCLAW_CONFIG}.bak" "$OPENCLAW_CONFIG"
  elif [ -f "$OPENCLAW_CONFIG" ]; then
    rm -f "$OPENCLAW_CONFIG"
  fi
}

rollback_database() {
  local db_file="$OPENCLAW_HOME/.openclaw/data/openclaw.db"
  if [ -f "$db_file" ]; then
    log_info "Eliminando base de datos: $db_file"
    rm -f "$db_file"
  fi
  rm -f "${db_file}.backup."* 2>/dev/null || true
}

rollback_interview() {
  local context_file="$OPENCLAW_HOME/.openclaw/interview_context.env"
  [ -f "$context_file" ] && rm -f "$context_file"
}

rollback_service_linux() {
  if [ -f /etc/systemd/system/openclaw-gateway.service ]; then
    $SUDO systemctl stop openclaw-gateway 2>/dev/null || true
    $SUDO systemctl disable openclaw-gateway 2>/dev/null || true
    $SUDO rm -f /etc/systemd/system/openclaw-gateway.service
    $SUDO systemctl daemon-reload 2>/dev/null || true
  fi
}

rollback_service_darwin() {
  local plist="$OPENCLAW_HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
  [ -f "$plist" ] && { launchctl unload "$plist" 2>/dev/null || true; rm -f "$plist"; }
}

rollback_service_windows() {
  command -v nssm &>/dev/null && {
    nssm stop OpenClawGateway 2>/dev/null || true
    nssm remove OpenClawGateway confirm 2>/dev/null || true
  }
}

rollback_heartbeat_linux() {
  crontab -l 2>/dev/null | grep -v "openclaw.*heartbeat" | crontab - 2>/dev/null || true
}

rollback_heartbeat_darwin() {
  local plist="$OPENCLAW_HOME/Library/LaunchAgents/com.openclaw.heartbeat.plist"
  [ -f "$plist" ] && { launchctl unload "$plist" 2>/dev/null || true; rm -f "$plist"; }
}

rollback_telegram() {
  openclaw channels remove telegram 2>/dev/null || true
}

rollback_openclaw() {
  openclaw gateway stop 2>/dev/null || true
  if [ "$OPENCLAW_IS_ROOT" = true ]; then
    npm uninstall -g openclaw 2>/dev/null || true
  else
    $SUDO npm uninstall -g openclaw 2>/dev/null || true
  fi
}
