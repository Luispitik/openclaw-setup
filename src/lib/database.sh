#!/usr/bin/env bash
# ============================================================
#  database.sh - SQLite local database setup
# ============================================================

setup_database() {
  local setup_dir="${1:-.}"
  local sql_dir="$setup_dir/src/templates/sql"
  local db_dir="$OPENCLAW_HOME/.openclaw/data"
  local db_file="$db_dir/openclaw.db"

  log_step "Configurando base de datos SQLite local..."

  mkdir -p "$db_dir"

  # Check if database already exists
  if [ -f "$db_file" ]; then
    log_warn "Base de datos existente detectada: $db_file"
    if confirm "Quieres resetear la base de datos?" "n"; then
      mv "$db_file" "${db_file}.backup.$(date +%s)"
      log_info "Backup creado"
    else
      log_info "Manteniendo base de datos existente"
      verify_database "$db_file"
      return 0
    fi
  fi

  # Execute SQL files in order
  for sql_file in "$sql_dir"/001_schema.sql "$sql_dir"/002_indexes.sql "$sql_dir"/003_seed.sql; do
    if [ -f "$sql_file" ]; then
      log_info "Ejecutando $(basename "$sql_file")..."
      if ! sqlite3 "$db_file" < "$sql_file" 2>/dev/null; then
        log_error "Error ejecutando $(basename "$sql_file")"
        return 1
      fi
    fi
  done

  # Add context-aware proposals if interview was completed
  local context_file="$OPENCLAW_HOME/.openclaw/interview_context.env"
  if [ -f "$context_file" ]; then
    generate_context_proposals "$db_file" "$context_file"
  fi

  verify_database "$db_file"
  register_rollback "rollback_database" "Eliminar base de datos"
  log_success "Base de datos SQLite configurada en $db_file"
  return 0
}

verify_database() {
  local db_file="$1"
  log_step "Verificando base de datos..."

  local table_count
  table_count=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';" 2>/dev/null || echo "0")

  local agent_count
  agent_count=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM agents;" 2>/dev/null || echo "0")

  if [ "$table_count" -ge 11 ] && [ "$agent_count" -ge 5 ]; then
    log_success "DB verificada: $table_count tablas, $agent_count agentes"
  else
    log_warn "Verificacion incompleta: $table_count tablas, $agent_count agentes"
  fi
}

generate_context_proposals() {
  local db_file="$1" context_env="$2"

  # Source interview context safely
  local user_name="" primary_goal="" industry="" specific_tasks="" shortterm_goal="" project_description=""
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    value="${value%\"}"
    value="${value#\"}"
    case "$key" in
      USER_NAME) user_name="$value" ;;
      PRIMARY_GOAL) primary_goal="$value" ;;
      INDUSTRY) industry="$value" ;;
      SPECIFIC_TASKS) specific_tasks="$value" ;;
      SHORTTERM_GOAL) shortterm_goal="$value" ;;
      PROJECT_DESCRIPTION) project_description="$value" ;;
    esac
  done < "$context_env"

  [ -z "$primary_goal" ] && [ -z "$industry" ] && return 0

  log_step "Creando propuestas iniciales personalizadas..."

  # Escape single quotes for SQL
  primary_goal="${primary_goal//\'/\'\'}"
  industry="${industry//\'/\'\'}"
  specific_tasks="${specific_tasks//\'/\'\'}"
  shortterm_goal="${shortterm_goal//\'/\'\'}"
  project_description="${project_description//\'/\'\'}"

  sqlite3 "$db_file" << EOSQL
INSERT INTO proposals (agent_id, title, description, status, source)
SELECT id,
  'Investigar: ${industry}',
  'Analizar tendencias actuales en ${industry} para ${project_description}',
  'pending',
  'setup'
FROM agents WHERE name = 'research_agent';

INSERT INTO proposals (agent_id, title, description, status, source)
SELECT id,
  'Evaluar automatizacion: ${specific_tasks}',
  'Evaluar como automatizar: ${specific_tasks}',
  'pending',
  'setup'
FROM agents WHERE name = 'dev_agent';

INSERT INTO proposals (agent_id, title, description, status, source)
SELECT id,
  'Plan 30 dias: ${shortterm_goal}',
  'Crear plan de accion para: ${shortterm_goal}. Objetivo principal: ${primary_goal}',
  'pending',
  'setup'
FROM agents WHERE name = 'limon';
EOSQL

  log_success "3 propuestas iniciales creadas basadas en tu entrevista"
}
