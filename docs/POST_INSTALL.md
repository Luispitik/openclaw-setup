# Guia Post-Instalacion: Tus Primeros 30 Dias

## Semana 1: Solo Observar

El sistema ya corre. El heartbeat late cada 15 min.

- [ ] Habla con Limón por Telegram: "Hola, estoy listo"
- [ ] Pide algo simple: "Resume las noticias de hoy sobre [tu sector]"
- [ ] Aprueba o rechaza propuestas que te lleguen
- [ ] NO actives nada mas esta semana

## Semana 2: Activar Detectores de Problemas

```bash
sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 1 WHERE name = 'mission_failed_diagnosis';"
sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 1 WHERE name = 'agent_blocked_escalation';"
```

Ahora los agentes detectan problemas solos.

## Semana 3: Reacciones Entre Agentes

Las reacciones ya estan configuradas. Crea misiones mas complejas:
- "Investiga [tema] y luego crea un borrador de articulo"
- "Revisa este codigo y sugiere mejoras"

## Semana 4+: Trabajo Proactivo

Activa UN trigger a la vez. Espera 3-5 dias entre cada uno.

```bash
# 1. Rex busca info cada 3h
sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 1 WHERE name = 'proactive_scan_signals';"

# 2. Sage prepara borradores cada 4h
sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 1 WHERE name = 'proactive_draft_content';"

# 3. Dev revisa codigo cada 4h
sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 1 WHERE name = 'proactive_code_review';"

# 4. Limón analiza operaciones cada 8h
sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 1 WHERE name = 'proactive_analyze_ops';"
```

## Actualizar tu Contexto

Si cambian tus objetivos o tu proyecto evoluciona:

```bash
# Editar directamente
nano ~/.openclaw/interview_context.env

# O editar el CONTEXT.md que leen los agentes
nano ~/.openclaw/workspace/00_CORE/CONTEXT.md
```

## Rutina Diaria

**Manana (5 min):** Revisar Telegram, aprobar/rechazar propuestas
**Mediodia (2 min):** "Estado" por Telegram
**Noche (5 min):** Revisar trabajo del dia

## Comandos Utiles

```bash
openclaw gateway status
openclaw sessions list
openclaw channels status
sudo systemctl status openclaw-gateway
tail -20 ~/.openclaw/logs/heartbeat.log

# Consultar DB
sqlite3 ~/.openclaw/data/openclaw.db "SELECT title, status FROM proposals ORDER BY created_at DESC LIMIT 5;"
sqlite3 ~/.openclaw/data/openclaw.db "SELECT name, status FROM agents;"
```
