#!/usr/bin/env bash
# ============================================================
#  main.sh - Master orchestrator for OpenClaw setup
# ============================================================

run_installer() {
  local SETUP_DIR="${1:-.}"

  # Source all library modules
  for lib in "$SETUP_DIR"/src/lib/*.sh; do
    source "$lib"
  done

  local TOTAL_PHASES=15
  local CURRENT_PHASE=0

  run_phase() {
    local name="$1" fn="$2"
    ((CURRENT_PHASE++))
    show_progress "$CURRENT_PHASE" "$TOTAL_PHASES" "$name"
    log_phase "Fase $CURRENT_PHASE/$TOTAL_PHASES: $name"
    if ! $fn "$SETUP_DIR"; then
      log_error "Fase '$name' fallo."
      execute_rollback
      echo ""
      log_error "La instalacion no se pudo completar."
      log_info "Revisa los mensajes de error arriba y vuelve a intentar."
      exit 1
    fi
  }

  echo ""
  echo -e "${BOLD}  Iniciando instalacion de OpenClaw...${NC}"
  echo -e "  ${DIM}Esto tardara unos 15-20 minutos (incluye entrevista de contexto).${NC}"
  echo ""

  run_phase "Detectando sistema operativo"      detect_os_phase
  run_phase "Verificando requisitos"             install_prerequisites
  run_phase "Configurando credenciales"          collect_credentials
  run_phase "Entrevista de contexto"             conduct_interview
  run_phase "Instalando OpenClaw"                install_openclaw
  run_phase "Creando estructura de carpetas"     create_workspace
  run_phase "Escribiendo configuracion"          write_config
  run_phase "Desplegando agentes"                deploy_agents
  run_phase "Creando base de datos local"        setup_database
  run_phase "Configurando servicio del sistema"  configure_services
  run_phase "Programando heartbeat"              setup_heartbeat
  run_phase "Configurando Telegram"              setup_telegram
  run_phase "Aplicando seguridad"                harden_security
  run_phase "Verificacion final"                 run_verification
  run_phase "Completado"                         print_summary_phase

  cleanup_credentials
}

detect_os_phase() {
  detect_os
  print_detected_os
  return 0
}

print_summary_phase() {
  print_summary
  return 0
}
