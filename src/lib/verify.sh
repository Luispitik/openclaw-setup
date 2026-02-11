#!/usr/bin/env bash
# ============================================================
#  verify.sh - Full system verification suite
# ============================================================

run_verification() {
  local setup_dir="${1:-.}"

  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}   VERIFICACION FINAL - OpenClaw Setup${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  local pass_count=0 fail_count=0

  check() {
    if eval "$2" > /dev/null 2>&1; then
      log_pass "$1"; ((pass_count++))
    else
      log_fail "$1"; ((fail_count++))
    fi
  }

  echo -e "  ${BOLD}HERRAMIENTAS${NC}"
  check "Node.js instalado" "node --version | grep -q 'v2'"
  check "npm instalado" "npm --version"
  check "git instalado" "git --version"
  check "sqlite3 instalado" "sqlite3 --version"

  echo ""
  echo -e "  ${BOLD}OPENCLAW${NC}"
  check "OpenClaw instalado" "command -v openclaw"
  check "Gateway accesible" "openclaw gateway status 2>&1 | grep -qi 'running\|active'"
  check "Gateway en 127.0.0.1" "grep -q '127.0.0.1' '$OPENCLAW_CONFIG'"

  echo ""
  echo -e "  ${BOLD}SEGURIDAD${NC}"
  check "DM policy = pairing" "grep -q 'pairing' '$OPENCLAW_CONFIG'"
  check "Config patch off" "grep -q '\"config_patch_enabled\": false' '$OPENCLAW_CONFIG'"
  check "session-logs eliminado" "[ ! -d '$OPENCLAW_WORKSPACE/skills/session-logs' ]"
  check "SECURITY.md" "[ -f '$OPENCLAW_WORKSPACE/00_CORE/SECURITY.md' ]"
  check "OPERATING_CONTRACT.md" "[ -f '$OPENCLAW_WORKSPACE/00_CORE/OPERATING_CONTRACT.md' ]"

  echo ""
  echo -e "  ${BOLD}BASE DE DATOS${NC}"
  local db_file="$OPENCLAW_HOME/.openclaw/data/openclaw.db"
  check "DB file existe" "[ -f '$db_file' ]"
  check "DB tiene 11+ tablas" "[ \$(sqlite3 '$db_file' 'SELECT COUNT(*) FROM sqlite_master WHERE type=\"table\";' 2>/dev/null) -ge 11 ]"
  check "5 agentes en DB" "[ \$(sqlite3 '$db_file' 'SELECT COUNT(*) FROM agents;' 2>/dev/null) -ge 5 ]"

  case "$OPENCLAW_OS" in
    linux)
      echo ""
      echo -e "  ${BOLD}AUTOMATIZACION (Linux)${NC}"
      check "Firewall activo" "sudo ufw status 2>/dev/null | grep -q 'active'"
      check "Servicio systemd" "systemctl is-active openclaw-gateway 2>/dev/null"
      check "Servicio habilitado" "systemctl is-enabled openclaw-gateway 2>/dev/null"
      check "Heartbeat crontab" "crontab -l 2>/dev/null | grep -q 'heartbeat'"
      ;;
    darwin)
      echo ""
      echo -e "  ${BOLD}AUTOMATIZACION (macOS)${NC}"
      check "Servicio launchd" "launchctl list 2>/dev/null | grep -q 'com.openclaw.gateway'"
      check "Heartbeat launchd" "launchctl list 2>/dev/null | grep -q 'com.openclaw.heartbeat'"
      ;;
    windows)
      echo ""
      echo -e "  ${BOLD}AUTOMATIZACION (Windows)${NC}"
      check "Gateway tarea" "schtasks //Query //TN 'OpenClaw Gateway' 2>/dev/null || nssm status OpenClawGateway 2>/dev/null"
      ;;
  esac

  echo ""
  echo -e "  ${BOLD}WORKSPACE${NC}"
  check "00_CORE" "[ -d '$OPENCLAW_WORKSPACE/00_CORE' ]"
  check "01_AGENTS/cami" "[ -d '$OPENCLAW_WORKSPACE/01_AGENTS/cami' ]"
  check "04_SKILLS" "[ -d '$OPENCLAW_WORKSPACE/04_SKILLS/proposal_service' ]"
  check "SOUL Cami" "[ -f '$OPENCLAW_WORKSPACE/01_AGENTS/cami/SOUL.md' ]"
  check "SOUL Dev" "[ -f '$OPENCLAW_WORKSPACE/01_AGENTS/dev_agent/SOUL.md' ]"
  check "SOUL Rex" "[ -f '$OPENCLAW_WORKSPACE/01_AGENTS/research_agent/SOUL.md' ]"
  check "SOUL Sage" "[ -f '$OPENCLAW_WORKSPACE/01_AGENTS/content_agent/SOUL.md' ]"
  check "SOUL Shield" "[ -f '$OPENCLAW_WORKSPACE/01_AGENTS/security_agent/SOUL.md' ]"
  check "CONTEXT.md" "[ -f '$OPENCLAW_WORKSPACE/00_CORE/CONTEXT.md' ]"

  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${BOLD}RESULTADO: ${GREEN}$pass_count OK${NC}, ${RED}$fail_count FAIL${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  [ "$fail_count" -gt 0 ] && log_warn "$fail_count verificaciones fallidas."
  return 0
}

print_summary() {
  echo ""
  echo -e "${GREEN}"
  echo "  ╔═══════════════════════════════════════════════════╗"
  echo "  ║   INSTALACION COMPLETADA CON EXITO               ║"
  echo "  ╚═══════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo "  Tu equipo de agentes IA esta listo:"
  echo ""
  echo -e "    ${CYAN}Cami${NC}   - CEO y Coordinadora (gemini-2.5-pro)"
  echo -e "    ${CYAN}Dev${NC}    - Desarrollador Principal (codex-5.2)"
  echo -e "    ${CYAN}Rex${NC}    - Analista de Investigacion (gemini-2.5-pro)"
  echo -e "    ${CYAN}Sage${NC}   - Creador de Contenido (gemini-2.5-pro)"
  echo -e "    ${CYAN}Shield${NC} - Monitor de Seguridad (gemini-2.5-flash)"
  echo ""
  echo "  Proximos pasos:"
  if [ "$WANT_TELEGRAM" = true ]; then
    echo "    1. Abre Telegram y habla con tu bot"
    echo "    2. Escribele: 'Hola, estoy listo'"
  else
    echo "    1. Configura Telegram:"
    echo "       openclaw channels add telegram --token TOKEN --session agent:cami:main --allowed-users TU_ID"
  fi
  echo "    3. Semana 1: Solo observa."
  echo "    4. Semana 2+: Activa triggers (ver docs/POST_INSTALL.md)"
  echo ""
  echo -e "  ${DIM}DB local: ~/.openclaw/data/openclaw.db${NC}"
  echo -e "  ${DIM}Docs: docs/POST_INSTALL.md | Problemas: docs/TROUBLESHOOTING.md${NC}"
  echo ""
}
