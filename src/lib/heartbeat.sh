#!/usr/bin/env bash
# ============================================================
#  heartbeat.sh - Configure recurring heartbeat per platform
# ============================================================

setup_heartbeat() {
  local setup_dir="${1:-.}"
  log_step "Configurando heartbeat (cada 15 minutos)..."
  mkdir -p "$OPENCLAW_HOME/.openclaw/logs"
  case "$OPENCLAW_OS" in
    linux)   setup_heartbeat_cron ;;
    darwin)  setup_heartbeat_launchd ;;
    windows) setup_heartbeat_windows ;;
  esac
}

setup_heartbeat_cron() {
  local openclaw_path; openclaw_path="$(which openclaw 2>/dev/null || echo '/usr/bin/openclaw')"
  local cron_line="*/15 * * * * $openclaw_path cron run heartbeat >> $OPENCLAW_HOME/.openclaw/logs/heartbeat.log 2>&1"
  crontab -l 2>/dev/null | grep -q "openclaw.*heartbeat" && {
    crontab -l 2>/dev/null | grep -v "openclaw.*heartbeat" | crontab - 2>/dev/null
  }
  (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
  crontab -l 2>/dev/null | grep -q "heartbeat" && log_success "Heartbeat en crontab (cada 15 min)" || \
    { log_error "No se pudo configurar heartbeat"; return 1; }
  register_rollback "rollback_heartbeat_linux" "Eliminar heartbeat"
  return 0
}

setup_heartbeat_launchd() {
  local plist="$OPENCLAW_HOME/Library/LaunchAgents/com.openclaw.heartbeat.plist"
  local openclaw_path; openclaw_path="$(which openclaw 2>/dev/null || echo '/usr/local/bin/openclaw')"
  mkdir -p "$(dirname "$plist")"
  launchctl unload "$plist" 2>/dev/null || true

  cat > "$plist" << HEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.openclaw.heartbeat</string>
  <key>ProgramArguments</key>
  <array><string>$openclaw_path</string><string>cron</string><string>run</string><string>heartbeat</string></array>
  <key>StartInterval</key><integer>900</integer>
  <key>StandardOutPath</key><string>$OPENCLAW_HOME/.openclaw/logs/heartbeat.log</string>
  <key>StandardErrorPath</key><string>$OPENCLAW_HOME/.openclaw/logs/heartbeat-error.log</string>
</dict>
</plist>
HEOF

  launchctl load "$plist"
  log_success "Heartbeat via launchd (cada 15 min)"
  register_rollback "rollback_heartbeat_darwin" "Eliminar heartbeat launchd"
  return 0
}

setup_heartbeat_windows() {
  local openclaw_path; openclaw_path="$(which openclaw 2>/dev/null || echo 'openclaw')"
  schtasks //Create //TN "OpenClaw Heartbeat" //TR "$openclaw_path cron run heartbeat" //SC MINUTE //MO 15 //RU "$USERNAME" //F 2>/dev/null || {
    log_warn "Crea manualmente: Task Scheduler > heartbeat cada 15 min"
    return 0
  }
  log_success "Heartbeat en Task Scheduler (cada 15 min)"
  return 0
}
