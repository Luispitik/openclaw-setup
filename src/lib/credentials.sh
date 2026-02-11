#!/usr/bin/env bash
# ============================================================
#  credentials.sh - Secure credential collection & validation
# ============================================================

GEMINI_AUTH_METHOD=""
GEMINI_API_KEY=""
TELEGRAM_TOKEN=""
TELEGRAM_USER_ID=""
WANT_TELEGRAM=false

cleanup_credentials() {
  unset GEMINI_API_KEY TELEGRAM_TOKEN TELEGRAM_USER_ID
}

collect_credentials() {
  local setup_dir="${1:-.}"
  trap cleanup_credentials EXIT INT TERM

  echo ""
  log_info "Las credenciales se piden de forma segura (no se muestran en pantalla)."
  log_info "Nunca se guardan en archivos de texto plano."
  echo ""

  # --- Gemini ---
  log_step "Configuracion de Gemini (el cerebro de tus agentes)"
  echo ""
  echo "  Elige como autenticarte con Google Gemini:"
  echo "    1) OAuth (recomendado) - Se abre un enlace, autorizas con Google"
  echo "    2) API Key - Pegas una clave de Google AI Studio"
  echo ""
  local gemini_choice
  read -r -p "  Tu eleccion [1/2]: " gemini_choice

  case "${gemini_choice:-1}" in
    2)
      GEMINI_AUTH_METHOD="apikey"
      echo ""
      log_info "Obtiene tu API key en: https://aistudio.google.com/apikey"
      echo ""
      while true; do
        read -r -s -p "  Gemini API Key: " GEMINI_API_KEY; echo ""
        if [ -n "$GEMINI_API_KEY" ]; then
          local resp; resp=$(curl -s -o /dev/null -w "%{http_code}" \
            "https://generativelanguage.googleapis.com/v1/models?key=$GEMINI_API_KEY" 2>/dev/null || echo "000")
          [ "$resp" = "200" ] && { log_success "Gemini API key verificada"; break; } || log_warn "Key no funciono (HTTP $resp). Reintenta."
        else log_warn "No puede estar vacia."; fi
      done
      ;;
    *)
      GEMINI_AUTH_METHOD="oauth"
      log_step "Ejecutando autenticacion OAuth con Gemini..."
      if command -v gemini &>/dev/null; then
        gemini auth 2>/dev/null || { log_warn "OAuth fallo. Configura despues con: gemini auth"; GEMINI_AUTH_METHOD="later"; }
      else
        log_info "Gemini CLI no instalado aun. Se configurara despues."
        GEMINI_AUTH_METHOD="later"
      fi
      ;;
  esac
  echo ""

  # --- Telegram (Optional) ---
  log_step "Configuracion de Telegram (opcional)"
  echo ""
  if confirm "Quieres configurar Telegram para hablar con tus agentes?" "n"; then
    WANT_TELEGRAM=true
    echo ""
    log_info "Necesitas: 1) Bot de @BotFather  2) Tu ID de @userinfobot"
    echo ""

    while true; do
      read -r -s -p "  Token del bot: " TELEGRAM_TOKEN; echo ""
      if [[ "$TELEGRAM_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
        local br; br=$(curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getMe" 2>/dev/null)
        if echo "$br" | grep -q '"ok":true'; then
          local bn; bn=$(echo "$br" | grep -o '"first_name":"[^"]*"' | cut -d'"' -f4)
          log_success "Bot verificado: $bn"; break
        else log_warn "Token invalido."; fi
      else log_warn "Formato: 123456789:AABBC..."; fi
    done

    while true; do
      read -r -p "  Tu ID de Telegram (numero): " TELEGRAM_USER_ID
      [[ "$TELEGRAM_USER_ID" =~ ^[0-9]{5,15}$ ]] && { log_success "ID registrado"; break; } || log_warn "Debe ser un numero de 5-15 digitos."
    done
  else
    WANT_TELEGRAM=false
    log_info "Telegram no configurado. Puedes hacerlo despues."
  fi

  echo ""
  log_success "Todas las credenciales recopiladas y verificadas"
  return 0
}
