#!/usr/bin/env bash
# ============================================================
#  interview.sh - Human-in-the-Loop onboarding interview
#  Collects user context to personalize agents
# ============================================================

# Interview context storage
declare -A INTERVIEW_DATA

conduct_interview() {
  local setup_dir="${1:-.}"

  log_phase "Entrevista de Contexto - Conociendo a tu equipo"

  echo ""
  echo -e "${CYAN}┌────────────────────────────────────────────────────────────┐${NC}"
  echo -e "${CYAN}│${NC}  Este paso personaliza tus agentes para que entiendan       ${CYAN}│${NC}"
  echo -e "${CYAN}│${NC}  quien eres, que haces y como pueden ayudarte mejor.       ${CYAN}│${NC}"
  echo -e "${CYAN}│${NC}                                                            ${CYAN}│${NC}"
  echo -e "${CYAN}│${NC}  Duracion: 5-10 minutos. Puedes saltar preguntas (Enter).  ${CYAN}│${NC}"
  echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"
  echo ""

  if ! confirm "Empezar la entrevista de contexto?" "y"; then
    log_warn "Entrevista omitida. Los agentes usaran configuracion generica."
    INTERVIEW_DATA[skipped]="true"
    save_interview_context "$setup_dir"
    return 0
  fi

  echo ""

  # ── Section 1: Identity ──────────────────────────────────
  interview_identity

  # ── Section 2: Project / Business ────────────────────────
  interview_project

  # ── Section 3: Goals & Tasks ─────────────────────────────
  interview_goals

  # ── Section 4: Communication & Work Style ────────────────
  interview_workstyle

  # ── Section 5: Technical Context ─────────────────────────
  interview_technical

  # ── Section 6: Deep Dive ─────────────────────────────────
  interview_deepdive

  # ── Summary & Confirmation ──────────────────────────────
  interview_summary

  # Save to file
  save_interview_context "$setup_dir"
  register_rollback "rollback_interview" "Eliminar contexto de entrevista"

  log_success "Entrevista completada. Tus agentes te conocen."
  return 0
}

# ── Section 1: Identity ──────────────────────────────────────
interview_identity() {
  echo -e "  ${BOLD}${CYAN}[ 1/6 ] Tu Identidad${NC}"
  echo -e "  ${DIM}─────────────────────────────────────────${NC}"
  echo ""

  read -r -p "  Como te llamas? (nombre o apodo): " answer
  INTERVIEW_DATA[user_name]="${answer:-Usuario}"

  read -r -p "  Cual es tu rol principal? (ej: CEO, dev, freelancer, estudiante): " answer
  INTERVIEW_DATA[user_role]="${answer:-Profesional}"

  read -r -p "  Trabajas en una empresa o proyecto? Cual?: " answer
  INTERVIEW_DATA[company]="${answer:-Proyecto personal}"

  if [ -n "${INTERVIEW_DATA[company]}" ] && [ "${INTERVIEW_DATA[company]}" != "Proyecto personal" ]; then
    read -r -p "  Cuantas personas hay en tu equipo? (1, 2-5, 5-20, 20+): " answer
    INTERVIEW_DATA[team_size]="${answer:-1}"
  else
    INTERVIEW_DATA[team_size]="1"
  fi

  echo ""
}

# ── Section 2: Project / Business ────────────────────────────
interview_project() {
  echo -e "  ${BOLD}${CYAN}[ 2/6 ] Tu Proyecto o Negocio${NC}"
  echo -e "  ${DIM}─────────────────────────────────────────${NC}"
  echo ""

  echo "  Describeme en 2-3 frases: Que es tu proyecto o negocio?"
  echo -e "  ${DIM}(Cuanto mas detalle, mejor te ayudaran los agentes)${NC}"
  read -r -p "  > " answer
  INTERVIEW_DATA[project_description]="${answer:-No especificado}"

  if [ -n "$answer" ]; then
    read -r -p "  Que industria o sector? (ej: SaaS, ecommerce, educacion, salud): " answer
    INTERVIEW_DATA[industry]="${answer:-General}"

    echo "  En que fase esta tu proyecto?"
    echo "    1) Idea / investigacion"
    echo "    2) MVP / prototipo"
    echo "    3) Crecimiento / primeros clientes"
    echo "    4) Maduro / consolidado"
    read -r -p "  Fase [1/2/3/4]: " answer
    case "${answer:-2}" in
      1) INTERVIEW_DATA[project_stage]="idea" ;;
      2) INTERVIEW_DATA[project_stage]="mvp" ;;
      3) INTERVIEW_DATA[project_stage]="crecimiento" ;;
      4) INTERVIEW_DATA[project_stage]="maduro" ;;
      *) INTERVIEW_DATA[project_stage]="mvp" ;;
    esac

    read -r -p "  Quien es tu cliente ideal? (describe brevemente): " answer
    INTERVIEW_DATA[target_audience]="${answer:-No especificado}"

    read -r -p "  Quienes son tus principales competidores? (nombres o URLs): " answer
    INTERVIEW_DATA[competitors]="${answer:-No especificado}"
  else
    INTERVIEW_DATA[industry]="General"
    INTERVIEW_DATA[project_stage]="mvp"
    INTERVIEW_DATA[target_audience]="No especificado"
    INTERVIEW_DATA[competitors]="No especificado"
  fi

  echo ""
}

# ── Section 3: Goals & Tasks ─────────────────────────────────
interview_goals() {
  echo -e "  ${BOLD}${CYAN}[ 3/6 ] Objetivos y Tareas${NC}"
  echo -e "  ${DIM}─────────────────────────────────────────${NC}"
  echo ""

  echo "  Que quieres que tus agentes IA te ayuden a hacer?"
  echo -e "  ${DIM}(Ej: investigar competencia, escribir contenido, automatizar reportes,${NC}"
  echo -e "  ${DIM} revisar codigo, gestionar redes sociales, analizar datos...)${NC}"
  read -r -p "  > " answer
  INTERVIEW_DATA[primary_goal]="${answer:-Tareas generales de asistencia}"

  if [ -n "$answer" ]; then
    echo ""
    echo "  Lista las tareas concretas que quieras automatizar (separadas por comas):"
    echo -e "  ${DIM}(Ej: analizar tendencias de mercado, generar posts para LinkedIn,${NC}"
    echo -e "  ${DIM} revisar PRs en GitHub, crear informes semanales)${NC}"
    read -r -p "  > " answer
    INTERVIEW_DATA[specific_tasks]="${answer:-Ninguna especifica aun}"

    echo ""
    read -r -p "  Cual es tu objetivo principal para los proximos 30 dias?: " answer
    INTERVIEW_DATA[shortterm_goal]="${answer:-Explorar capacidades del sistema}"

    read -r -p "  Y tu vision a 6 meses?: " answer
    INTERVIEW_DATA[longterm_vision]="${answer:-No definida aun}"
  else
    INTERVIEW_DATA[specific_tasks]="Ninguna especifica aun"
    INTERVIEW_DATA[shortterm_goal]="Explorar capacidades del sistema"
    INTERVIEW_DATA[longterm_vision]="No definida aun"
  fi

  echo ""
}

# ── Section 4: Communication & Work Style ────────────────────
interview_workstyle() {
  echo -e "  ${BOLD}${CYAN}[ 4/6 ] Estilo de Trabajo${NC}"
  echo -e "  ${DIM}─────────────────────────────────────────${NC}"
  echo ""

  echo "  Como prefieres que tus agentes se comuniquen contigo?"
  echo "    1) Solo lo importante - resumen diario"
  echo "    2) Notificaciones frecuentes - cada tarea completada"
  echo "    3) Bajo demanda - solo cuando pregunto"
  echo "    4) Proactivo - que me propongan ideas constantemente"
  read -r -p "  Tu preferencia [1/2/3/4]: " answer
  case "${answer:-1}" in
    1) INTERVIEW_DATA[communication_style]="resumen_diario" ;;
    2) INTERVIEW_DATA[communication_style]="frecuente" ;;
    3) INTERVIEW_DATA[communication_style]="bajo_demanda" ;;
    4) INTERVIEW_DATA[communication_style]="proactivo" ;;
    *) INTERVIEW_DATA[communication_style]="resumen_diario" ;;
  esac

  echo ""
  echo "  Como prefieres que te hablen los agentes?"
  echo "    1) Formal y profesional"
  echo "    2) Casual pero respetuoso"
  echo "    3) Directo y sin rodeos"
  echo "    4) Amigable y motivador"
  read -r -p "  Tono [1/2/3/4]: " answer
  case "${answer:-2}" in
    1) INTERVIEW_DATA[tone]="formal" ;;
    2) INTERVIEW_DATA[tone]="casual" ;;
    3) INTERVIEW_DATA[tone]="directo" ;;
    4) INTERVIEW_DATA[tone]="amigable" ;;
    *) INTERVIEW_DATA[tone]="casual" ;;
  esac

  echo ""
  read -r -p "  En que zona horaria trabajas? (ej: Europe/Madrid, America/Mexico_City): " answer
  INTERVIEW_DATA[timezone]="${answer:-UTC}"

  read -r -p "  Horario de trabajo habitual? (ej: 9-18, flexible, nocturno): " answer
  INTERVIEW_DATA[work_hours]="${answer:-flexible}"

  echo ""
  echo "  En que idioma prefieres que trabajen los agentes?"
  echo "    1) Espanol"
  echo "    2) Ingles"
  echo "    3) Ambos"
  read -r -p "  Idioma [1/2/3]: " answer
  case "${answer:-1}" in
    1) INTERVIEW_DATA[language]="espanol" ;;
    2) INTERVIEW_DATA[language]="ingles" ;;
    3) INTERVIEW_DATA[language]="bilingue" ;;
    *) INTERVIEW_DATA[language]="espanol" ;;
  esac

  echo ""
}

# ── Section 5: Technical Context ─────────────────────────────
interview_technical() {
  echo -e "  ${BOLD}${CYAN}[ 5/6 ] Contexto Tecnico${NC}"
  echo -e "  ${DIM}─────────────────────────────────────────${NC}"
  echo ""

  echo "  Como calificarias tu nivel tecnico?"
  echo "    1) Principiante - necesito explicaciones simples"
  echo "    2) Intermedio - entiendo conceptos basicos de programacion"
  echo "    3) Avanzado - puedo leer codigo, usar APIs, configurar servidores"
  echo "    4) Experto - desarrollo software profesionalmente"
  read -r -p "  Nivel [1/2/3/4]: " answer
  case "${answer:-2}" in
    1) INTERVIEW_DATA[technical_level]="principiante" ;;
    2) INTERVIEW_DATA[technical_level]="intermedio" ;;
    3) INTERVIEW_DATA[technical_level]="avanzado" ;;
    4) INTERVIEW_DATA[technical_level]="experto" ;;
    *) INTERVIEW_DATA[technical_level]="intermedio" ;;
  esac

  echo ""
  read -r -p "  Lenguajes/tecnologias que usas? (ej: Python, React, WordPress, n8n): " answer
  INTERVIEW_DATA[tech_stack]="${answer:-No especificado}"

  read -r -p "  Herramientas que usas dia a dia? (ej: GitHub, Notion, Slack, Figma): " answer
  INTERVIEW_DATA[tools]="${answer:-No especificado}"

  read -r -p "  Tienes repos de codigo? (URLs de GitHub/GitLab, o 'no'): " answer
  INTERVIEW_DATA[repos]="${answer:-No}"

  echo ""
}

# ── Section 6: Deep Dive ─────────────────────────────────────
interview_deepdive() {
  echo -e "  ${BOLD}${CYAN}[ 6/6 ] Profundizando${NC}"
  echo -e "  ${DIM}─────────────────────────────────────────${NC}"
  echo ""

  echo "  Que tipo de contenido necesitas crear regularmente?"
  echo -e "  ${DIM}(Ej: posts de blog, newsletter, redes sociales, documentacion, informes)${NC}"
  read -r -p "  > " answer
  INTERVIEW_DATA[content_needs]="${answer:-No especificado}"

  echo ""
  echo "  Hay algo que NO quieres que hagan los agentes?"
  echo -e "  ${DIM}(Ej: no publicar sin mi aprobacion, no tocar codigo de produccion)${NC}"
  read -r -p "  > " answer
  INTERVIEW_DATA[restrictions]="${answer:-Nada especifico}"

  echo ""
  echo "  Que metricas o KPIs son mas importantes para ti?"
  echo -e "  ${DIM}(Ej: ventas, trafico web, velocidad de desarrollo, leads)${NC}"
  read -r -p "  > " answer
  INTERVIEW_DATA[kpis]="${answer:-No especificado}"

  echo ""
  echo "  Hay algo mas que quieras que tus agentes sepan sobre ti?"
  echo -e "  ${DIM}(Informacion adicional, preferencias, contexto especial...)${NC}"
  read -r -p "  > " answer
  INTERVIEW_DATA[additional_context]="${answer:-}"

  echo ""
}

# ── Summary ──────────────────────────────────────────────────
interview_summary() {
  echo ""
  echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${BOLD}   RESUMEN DE TU CONTEXTO${NC}"
  echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${BOLD}Identidad:${NC} ${INTERVIEW_DATA[user_name]} - ${INTERVIEW_DATA[user_role]} @ ${INTERVIEW_DATA[company]}"
  echo -e "  ${BOLD}Proyecto:${NC} ${INTERVIEW_DATA[project_description]}"
  echo -e "  ${BOLD}Industria:${NC} ${INTERVIEW_DATA[industry]} (${INTERVIEW_DATA[project_stage]})"
  echo -e "  ${BOLD}Objetivo:${NC} ${INTERVIEW_DATA[primary_goal]}"
  echo -e "  ${BOLD}Tareas:${NC} ${INTERVIEW_DATA[specific_tasks]}"
  echo -e "  ${BOLD}Meta 30d:${NC} ${INTERVIEW_DATA[shortterm_goal]}"
  echo -e "  ${BOLD}Comunicacion:${NC} ${INTERVIEW_DATA[communication_style]} / ${INTERVIEW_DATA[tone]}"
  echo -e "  ${BOLD}Nivel:${NC} ${INTERVIEW_DATA[technical_level]}"
  echo -e "  ${BOLD}Idioma:${NC} ${INTERVIEW_DATA[language]}"
  echo ""

  if ! confirm "Es correcto este resumen?" "y"; then
    log_warn "Puedes re-ejecutar la entrevista despues editando ~/.openclaw/interview_context.env"
  fi
  echo ""
}

# ── Save to file ─────────────────────────────────────────────
save_interview_context() {
  local setup_dir="$1"
  local context_dir="$OPENCLAW_HOME/.openclaw"
  local context_file="$context_dir/interview_context.env"

  mkdir -p "$context_dir"

  cat > "$context_file" << EOF
# OpenClaw Interview Context
# Generated: $(date)
# Edit this file to update your agent context
USER_NAME="${INTERVIEW_DATA[user_name]:-Usuario}"
USER_ROLE="${INTERVIEW_DATA[user_role]:-Profesional}"
COMPANY="${INTERVIEW_DATA[company]:-Proyecto personal}"
TEAM_SIZE="${INTERVIEW_DATA[team_size]:-1}"
PROJECT_DESCRIPTION="${INTERVIEW_DATA[project_description]:-No especificado}"
INDUSTRY="${INTERVIEW_DATA[industry]:-General}"
PROJECT_STAGE="${INTERVIEW_DATA[project_stage]:-mvp}"
TARGET_AUDIENCE="${INTERVIEW_DATA[target_audience]:-No especificado}"
COMPETITORS="${INTERVIEW_DATA[competitors]:-No especificado}"
PRIMARY_GOAL="${INTERVIEW_DATA[primary_goal]:-Tareas generales}"
SPECIFIC_TASKS="${INTERVIEW_DATA[specific_tasks]:-Ninguna especifica}"
SHORTTERM_GOAL="${INTERVIEW_DATA[shortterm_goal]:-Explorar capacidades}"
LONGTERM_VISION="${INTERVIEW_DATA[longterm_vision]:-No definida}"
COMMUNICATION_STYLE="${INTERVIEW_DATA[communication_style]:-resumen_diario}"
TONE="${INTERVIEW_DATA[tone]:-casual}"
TIMEZONE="${INTERVIEW_DATA[timezone]:-UTC}"
WORK_HOURS="${INTERVIEW_DATA[work_hours]:-flexible}"
LANGUAGE="${INTERVIEW_DATA[language]:-espanol}"
TECHNICAL_LEVEL="${INTERVIEW_DATA[technical_level]:-intermedio}"
TECH_STACK="${INTERVIEW_DATA[tech_stack]:-No especificado}"
TOOLS="${INTERVIEW_DATA[tools]:-No especificado}"
REPOS="${INTERVIEW_DATA[repos]:-No}"
CONTENT_NEEDS="${INTERVIEW_DATA[content_needs]:-No especificado}"
RESTRICTIONS="${INTERVIEW_DATA[restrictions]:-Nada especifico}"
KPIS="${INTERVIEW_DATA[kpis]:-No especificado}"
ADDITIONAL_CONTEXT="${INTERVIEW_DATA[additional_context]:-}"
SKIPPED="${INTERVIEW_DATA[skipped]:-false}"
EOF

  chmod 600 "$context_file"
  log_info "Contexto guardado en: $context_file"
}
