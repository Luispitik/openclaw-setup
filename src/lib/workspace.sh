#!/usr/bin/env bash
# ============================================================
#  workspace.sh - Create workspace directory structure
# ============================================================

create_workspace() {
  local setup_dir="${1:-.}"

  if [ -f "$OPENCLAW_WORKSPACE/00_CORE/SECURITY.md" ]; then
    log_warn "Instalacion existente detectada."
    confirm "Sobrescribir archivos?" "n" || { log_info "Manteniendo configuracion existente."; return 0; }
  fi

  log_step "Creando estructura de carpetas..."

  local dirs=(
    "$OPENCLAW_WORKSPACE/00_CORE"
    "$OPENCLAW_WORKSPACE/01_AGENTS/limon/memory/daily"
    "$OPENCLAW_WORKSPACE/01_AGENTS/dev_agent/memory/daily"
    "$OPENCLAW_WORKSPACE/01_AGENTS/research_agent/memory/daily"
    "$OPENCLAW_WORKSPACE/01_AGENTS/content_agent/memory/daily"
    "$OPENCLAW_WORKSPACE/01_AGENTS/security_agent/memory/daily"
    "$OPENCLAW_WORKSPACE/02_PROJECTS"
    "$OPENCLAW_WORKSPACE/03_MEMORY/daily"
    "$OPENCLAW_WORKSPACE/04_SKILLS/proposal_service"
    "$OPENCLAW_WORKSPACE/04_SKILLS/trigger_evaluator"
    "$OPENCLAW_WORKSPACE/04_SKILLS/reaction_processor"
    "$OPENCLAW_WORKSPACE/05_TOOLS"
    "$OPENCLAW_WORKSPACE/06_CRON/heartbeat"
    "$OPENCLAW_WORKSPACE/06_CRON/scheduled_tasks"
    "$OPENCLAW_WORKSPACE/07_OUTPUTS/reports"
    "$OPENCLAW_WORKSPACE/07_OUTPUTS/code"
    "$OPENCLAW_WORKSPACE/07_OUTPUTS/content"
    "$OPENCLAW_WORKSPACE/07_OUTPUTS/handoffs"
    "$OPENCLAW_WORKSPACE/08_LOGS/agent_activity"
    "$OPENCLAW_WORKSPACE/08_LOGS/errors"
    "$OPENCLAW_WORKSPACE/08_LOGS/performance"
    "$OPENCLAW_HOME/ClawWork"
    "$OPENCLAW_HOME/.openclaw/logs"
  )

  for dir in "${dirs[@]}"; do mkdir -p "$dir"; done

  log_success "Estructura creada (${#dirs[@]} directorios)"
  register_rollback "rollback_workspace" "Eliminar workspace"
  return 0
}
