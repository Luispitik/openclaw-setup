#!/usr/bin/env bash
# ============================================================
#  config.sh - Write openclaw.json configuration
# ============================================================

write_config() {
  local setup_dir="${1:-.}"
  local config_file="$OPENCLAW_CONFIG"

  [ -f "$config_file" ] && { cp "$config_file" "${config_file}.bak"; log_info "Backup: ${config_file}.bak"; }

  log_step "Escribiendo configuracion de OpenClaw..."

  mkdir -p "$(dirname "$config_file")"

  cat > "$config_file" << JSONEOF
{
  "gateway": {
    "host": "127.0.0.1",
    "port": 3000
  },
  "security": {
    "dm_policy": "pairing",
    "sandbox_mode": "non-main",
    "config_patch_enabled": false
  },
  "models": {
    "default": "gemini-2.5-flash",
    "routing": {
      "simple_tasks": "gemini-2.5-flash",
      "medium_tasks": "gemini-2.5-pro",
      "complex_reasoning": "gemini-3-pro",
      "code_development": "codex-5.2"
    }
  },
  "memory": {
    "auto_load": false,
    "max_file_size_kb": 8
  },
  "workspace": {
    "root": "$OPENCLAW_WORKSPACE",
    "allowed_paths": [
      "$OPENCLAW_WORKSPACE",
      "$OPENCLAW_HOME/ClawWork"
    ]
  },
  "database": {
    "type": "sqlite",
    "path": "$OPENCLAW_HOME/.openclaw/data/openclaw.db"
  }
}
JSONEOF

  [ -f "$config_file" ] && log_success "openclaw.json escrito" || { log_error "No se pudo escribir openclaw.json"; return 1; }
  register_rollback "rollback_config" "Restaurar configuracion"
  return 0
}
