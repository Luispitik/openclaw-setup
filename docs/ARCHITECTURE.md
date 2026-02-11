# Arquitectura del Sistema OpenClaw

## Vista General

```
┌─────────────────────────────────────────────────────┐
│                  TU TELEFONO (Telegram)              │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│            GATEWAY (127.0.0.1:3000)                  │
│       Recepcionista - gestiona todo                  │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────┐│
│  │ Cami   │ │  Dev   │ │  Rex   │ │ Sage   │ │Shld││
│  └────────┘ └────────┘ └────────┘ └────────┘ └────┘│
└────────────────────┬────────────────────────────────┘
        ┌────────────┼────────────┐
        ▼            ▼            ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│  SQLite  │  │ Workspace│  │  Models  │
│  (local) │  │  (.md)   │  │ (Gemini) │
└──────────┘  └──────────┘  └──────────┘
```

## El Bucle Cerrado (Closed Loop)

```
Propuesta → Cap Gates → Auto-Approve? → Mision
    ↑                                      │
    │                                      ▼
    │                               Pasos (Steps)
    │                                      │
    │                                      ▼
Reaccion ← Trigger ← Evento ← Ejecucion
```

1. Un agente **propone** una accion
2. **Cap Gates** verifican limites (presupuesto, permisos)
3. Si es de bajo riesgo, se **auto-aprueba**
4. Se crea una **mision** con pasos
5. Los pasos se **ejecutan** secuencialmente
6. Cada ejecucion genera un **evento**
7. Los eventos activan **triggers** (si estan habilitados)
8. Los triggers generan **reacciones** en otros agentes
9. Las reacciones crean nuevas **propuestas** → vuelta al paso 1

## Base de Datos (SQLite Local)

La base de datos se almacena en `~/.openclaw/data/openclaw.db`.

| Tabla | Que guarda | Analogia |
|-------|------------|----------|
| agents | Los 5 agentes y su estado | Lista de empleados |
| proposals | Ideas de los agentes | Bandeja de entrada |
| missions | Propuestas aprobadas | Proyectos en curso |
| mission_steps | Tareas de cada mision | Lista de tareas |
| agent_events | Todo lo que pasa | Registro de actividad |
| agent_memory | Lo que aprenden | Archivo personal |
| policies | Configuracion del sistema | Constitucion |
| trigger_rules | Despertadores automaticos | Alarmas programadas |
| agent_reactions | Reacciones entre agentes | Conversaciones internas |
| action_runs | Log de ejecuciones | Historial de trabajo |
| agent_insights | Descubrimientos | Notas de investigacion |

### Consultar la DB

```bash
sqlite3 ~/.openclaw/data/openclaw.db "SELECT name, status FROM agents;"
sqlite3 ~/.openclaw/data/openclaw.db "SELECT title, status FROM proposals ORDER BY created_at DESC LIMIT 10;"
```

## Entrevista HITL

```
Instalacion → Credenciales → ENTREVISTA → Workspace → Agentes → DB
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
              CONTEXT.md    SOUL.md x5    Proposals
              (00_CORE/)    (append)      (SQLite)
```

## Estructura del Workspace

```
~/.openclaw/workspace/
├── 00_CORE/          ← Reglas del sistema + CONTEXT.md
├── 01_AGENTS/        ← Un "despacho" por agente (SOUL.md)
├── 02_PROJECTS/      ← Proyectos activos
├── 03_MEMORY/        ← Memoria compartida
├── 04_SKILLS/        ← Habilidades del sistema
├── 05_TOOLS/         ← Reglas de herramientas
├── 06_CRON/          ← Heartbeat config
├── 07_OUTPUTS/       ← Entregables
└── 08_LOGS/          ← Registros
```

## Modelos de IA

| Modelo | Uso | Coste |
|--------|-----|-------|
| gemini-2.5-flash | Tareas simples (default) | Barato |
| gemini-2.5-pro | Analisis, investigacion | Medio |
| gemini-3-pro | Razonamiento complejo | Caro |
| codex-5.2 | Escribir codigo | Especializado |
