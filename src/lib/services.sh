#!/usr/bin/env bash
# ============================================================
#  services.sh - Configure auto-start service per platform
# ============================================================

configure_services() {
  local setup_dir="${1:-.}"
  log_step "Configurando servicio de auto-arranque..."
  case "$OPENCLAW_OS" in
    linux)   configure_systemd "$setup_dir" ;;
    darwin)  configure_launchd "$setup_dir" ;;
    windows) configure_windows_service "$setup_dir" ;;
    *) log_warn "Plataforma no soportada: $OPENCLAW_OS"; return 0 ;;
  esac
}

configure_systemd() {
  local openclaw_path; openclaw_path="$(which openclaw 2>/dev/null || echo '/usr/bin/openclaw')"
  openclaw gateway stop 2>/dev/null || true

  log_step "Creando servicio systemd..."
  $SUDO tee /etc/systemd/system/openclaw-gateway.service > /dev/null << SVCEOF
[Unit]
Description=OpenClaw Gateway - Sistema de Agentes IA
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$OPENCLAW_HOME/.openclaw
ExecStart=$openclaw_path gateway start --foreground
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
SVCEOF

  $SUDO systemctl daemon-reload
  $SUDO systemctl enable openclaw-gateway >/dev/null 2>&1
  $SUDO systemctl start openclaw-gateway
  sleep 3
  systemctl is-active openclaw-gateway >/dev/null 2>&1 && log_success "Servicio systemd activo" || \
    log_warn "Verifica con: sudo systemctl status openclaw-gateway"
  register_rollback "rollback_service_linux" "Eliminar servicio systemd"
  return 0
}

configure_launchd() {
  local plist_dir="$OPENCLAW_HOME/Library/LaunchAgents"
  local plist_file="$plist_dir/com.openclaw.gateway.plist"
  local openclaw_path; openclaw_path="$(which openclaw 2>/dev/null || echo '/usr/local/bin/openclaw')"
  mkdir -p "$plist_dir"
  openclaw gateway stop 2>/dev/null || true
  launchctl unload "$plist_file" 2>/dev/null || true

  cat > "$plist_file" << PEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.openclaw.gateway</string>
  <key>ProgramArguments</key>
  <array><string>$openclaw_path</string><string>gateway</string><string>start</string><string>--foreground</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>WorkingDirectory</key><string>$OPENCLAW_HOME/.openclaw</string>
  <key>StandardOutPath</key><string>$OPENCLAW_HOME/.openclaw/logs/gateway.log</string>
  <key>StandardErrorPath</key><string>$OPENCLAW_HOME/.openclaw/logs/gateway-error.log</string>
</dict>
</plist>
PEOF

  launchctl load "$plist_file"
  sleep 2
  launchctl list | grep -q "com.openclaw.gateway" && log_success "Servicio launchd activo" || \
    log_warn "Verifica con: launchctl list | grep openclaw"
  register_rollback "rollback_service_darwin" "Eliminar servicio launchd"
  return 0
}

configure_windows_service() {
  local openclaw_path; openclaw_path="$(which openclaw 2>/dev/null || echo 'openclaw')"
  if command -v nssm &>/dev/null; then
    nssm stop OpenClawGateway 2>/dev/null || true
    nssm remove OpenClawGateway confirm 2>/dev/null || true
    nssm install OpenClawGateway "$openclaw_path" "gateway start --foreground"
    nssm set OpenClawGateway AppDirectory "$OPENCLAW_HOME/.openclaw"
    nssm start OpenClawGateway
    log_success "Servicio Windows (nssm) configurado"
    register_rollback "rollback_service_windows" "Eliminar servicio Windows"
  else
    schtasks //Create //TN "OpenClaw Gateway" //TR "$openclaw_path gateway start" //SC ONSTART //RU "$USERNAME" //F 2>/dev/null || {
      log_warn "Crea manualmente: Task Scheduler > openclaw gateway start al inicio"
    }
  fi
  return 0
}
