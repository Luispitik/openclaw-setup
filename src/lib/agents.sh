#!/usr/bin/env bash
# ============================================================
#  agents.sh - Deploy agent personality and config files
#  Injects user context from interview into SOUL.md files
# ============================================================

deploy_agents() {
  local setup_dir="${1:-.}"
  local templates_dir="$setup_dir/src/templates/agents"
  local agents_dir="$OPENCLAW_WORKSPACE/01_AGENTS"
  local core_dir="$OPENCLAW_WORKSPACE/00_CORE"
  local core_templates="$setup_dir/src/templates/core"
  local context_file="$OPENCLAW_HOME/.openclaw/interview_context.env"

  # Deploy core files
  log_step "Desplegando archivos del sistema..."
  if [ -d "$core_templates" ]; then
    cp "$core_templates/SECURITY.md" "$core_dir/SECURITY.md"
    cp "$core_templates/OPERATING_CONTRACT.md" "$core_dir/OPERATING_CONTRACT.md"
    cp "$core_templates/MODELS_CONFIG.md" "$core_dir/MODELS_CONFIG.md"

    # Generate CONTEXT.md from interview data
    if [ -f "$context_file" ] && [ -f "$core_templates/CONTEXT.md.tmpl" ]; then
      generate_context_file "$core_templates/CONTEXT.md.tmpl" "$core_dir/CONTEXT.md" "$context_file"
      log_success "CONTEXT.md generado con tu informacion personalizada"
    else
      cp "$core_templates/CONTEXT.md.tmpl" "$core_dir/CONTEXT.md"
      log_info "CONTEXT.md creado con plantilla generica"
    fi

    log_success "Archivos core copiados"
  fi

  # Deploy agent files with context injection
  local agents=("cami" "dev_agent" "research_agent" "content_agent" "security_agent")
  local count=0
  for agent in "${agents[@]}"; do
    local ad="$agents_dir/$agent"
    if [ -d "$templates_dir/$agent" ]; then
      for file in SOUL.md IDENTITY.md SKILLS.md RULES.md; do
        if [ -f "$templates_dir/$agent/$file" ]; then
          if [ "$file" = "SOUL.md" ] && [ -f "$context_file" ]; then
            inject_context_into_soul "$templates_dir/$agent/$file" "$ad/$file" "$context_file"
          else
            cp "$templates_dir/$agent/$file" "$ad/$file"
          fi
        fi
      done
    fi
    ((count++))
    log_success "Agente configurado: $agent ($count/5)"
  done

  log_success "5 agentes desplegados con personalidad personalizada"
  return 0
}

generate_context_file() {
  local template="$1" output="$2" context_env="$3"

  # Read context values
  local user_name="" user_role="" company="" team_size="" project_description=""
  local industry="" project_stage="" target_audience="" competitors=""
  local primary_goal="" specific_tasks="" shortterm_goal="" longterm_vision=""
  local communication_style="" tone="" timezone="" work_hours="" language=""
  local technical_level="" tech_stack="" tools="" repos=""
  local content_needs="" kpis="" restrictions="" additional_context=""

  while IFS='=' read -r key value; do
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    value="${value%\"}"
    value="${value#\"}"
    case "$key" in
      USER_NAME) user_name="$value" ;;
      USER_ROLE) user_role="$value" ;;
      COMPANY) company="$value" ;;
      TEAM_SIZE) team_size="$value" ;;
      PROJECT_DESCRIPTION) project_description="$value" ;;
      INDUSTRY) industry="$value" ;;
      PROJECT_STAGE) project_stage="$value" ;;
      TARGET_AUDIENCE) target_audience="$value" ;;
      COMPETITORS) competitors="$value" ;;
      PRIMARY_GOAL) primary_goal="$value" ;;
      SPECIFIC_TASKS) specific_tasks="$value" ;;
      SHORTTERM_GOAL) shortterm_goal="$value" ;;
      LONGTERM_VISION) longterm_vision="$value" ;;
      COMMUNICATION_STYLE) communication_style="$value" ;;
      TONE) tone="$value" ;;
      TIMEZONE) timezone="$value" ;;
      WORK_HOURS) work_hours="$value" ;;
      LANGUAGE) language="$value" ;;
      TECHNICAL_LEVEL) technical_level="$value" ;;
      TECH_STACK) tech_stack="$value" ;;
      TOOLS) tools="$value" ;;
      REPOS) repos="$value" ;;
      CONTENT_NEEDS) content_needs="$value" ;;
      KPIS) kpis="$value" ;;
      RESTRICTIONS) restrictions="$value" ;;
      ADDITIONAL_CONTEXT) additional_context="$value" ;;
    esac
  done < "$context_env"

  # Replace placeholders in template
  sed \
    -e "s|{{USER_NAME}}|${user_name}|g" \
    -e "s|{{USER_ROLE}}|${user_role}|g" \
    -e "s|{{COMPANY}}|${company}|g" \
    -e "s|{{TEAM_SIZE}}|${team_size}|g" \
    -e "s|{{PROJECT_DESCRIPTION}}|${project_description}|g" \
    -e "s|{{INDUSTRY}}|${industry}|g" \
    -e "s|{{PROJECT_STAGE}}|${project_stage}|g" \
    -e "s|{{TARGET_AUDIENCE}}|${target_audience}|g" \
    -e "s|{{COMPETITORS}}|${competitors}|g" \
    -e "s|{{PRIMARY_GOAL}}|${primary_goal}|g" \
    -e "s|{{SPECIFIC_TASKS}}|${specific_tasks}|g" \
    -e "s|{{SHORTTERM_GOAL}}|${shortterm_goal}|g" \
    -e "s|{{LONGTERM_VISION}}|${longterm_vision}|g" \
    -e "s|{{COMMUNICATION_STYLE}}|${communication_style}|g" \
    -e "s|{{TONE}}|${tone}|g" \
    -e "s|{{TIMEZONE}}|${timezone}|g" \
    -e "s|{{WORK_HOURS}}|${work_hours}|g" \
    -e "s|{{LANGUAGE}}|${language}|g" \
    -e "s|{{TECHNICAL_LEVEL}}|${technical_level}|g" \
    -e "s|{{TECH_STACK}}|${tech_stack}|g" \
    -e "s|{{TOOLS}}|${tools}|g" \
    -e "s|{{REPOS}}|${repos}|g" \
    -e "s|{{CONTENT_NEEDS}}|${content_needs}|g" \
    -e "s|{{KPIS}}|${kpis}|g" \
    -e "s|{{RESTRICTIONS}}|${restrictions}|g" \
    -e "s|{{ADDITIONAL_CONTEXT}}|${additional_context}|g" \
    "$template" > "$output"
}

inject_context_into_soul() {
  local template="$1" output="$2" context_env="$3"

  # Copy original SOUL.md first
  cp "$template" "$output"

  # Read key context values
  local user_name="" user_role="" project_description="" primary_goal=""
  local technical_level="" communication_style="" tone="" language=""
  local specific_tasks="" industry="" restrictions=""

  while IFS='=' read -r key value; do
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    value="${value%\"}"
    value="${value#\"}"
    case "$key" in
      USER_NAME) user_name="$value" ;;
      USER_ROLE) user_role="$value" ;;
      PROJECT_DESCRIPTION) project_description="$value" ;;
      PRIMARY_GOAL) primary_goal="$value" ;;
      TECHNICAL_LEVEL) technical_level="$value" ;;
      COMMUNICATION_STYLE) communication_style="$value" ;;
      TONE) tone="$value" ;;
      LANGUAGE) language="$value" ;;
      SPECIFIC_TASKS) specific_tasks="$value" ;;
      INDUSTRY) industry="$value" ;;
      RESTRICTIONS) restrictions="$value" ;;
      SKIPPED) [ "$value" = "true" ] && return 0 ;;
    esac
  done < "$context_env"

  # Append personalized context section to SOUL.md
  cat >> "$output" << EOF

---

## Contexto de tu Usuario

> Generado automaticamente. Lee 00_CORE/CONTEXT.md para el perfil completo.

**Nombre:** ${user_name}
**Rol:** ${user_role}
**Proyecto:** ${project_description}
**Industria:** ${industry}

**Objetivo principal:** ${primary_goal}
**Tareas prioritarias:** ${specific_tasks}

**Nivel tecnico:** ${technical_level}
**Tono de comunicacion:** ${tone}
**Idioma preferido:** ${language}
**Estilo de updates:** ${communication_style}

**Restricciones:** ${restrictions}
EOF
}
