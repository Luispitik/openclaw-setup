# OpenClaw Setup

> **Un solo comando para desplegar un sistema de agentes IA autonomo y listo para produccion.**
> 5 agentes · SQLite local · Entrevista HITL · Heartbeat auto-healing · Mac · Linux VPS · Windows

```
  ╔═╗╔═╗╔═╗╔╗╔  ╔═╗╦  ╔═╗╦ ╦
  ║ ║╠═╝║╣ ║║║  ║  ║  ╠═╣║║║
  ╚═╝╩  ╚═╝╝╚╝  ╚═╝╩═╝╩ ╩╚╩╝
```

---

## Quick Start

### Linux / macOS
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Zie619/openclaw-setup/main/install.sh)
```

### Windows (Git Bash)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Zie619/openclaw-setup/main/install.sh)
```

### Desde repo clonado
```bash
git clone https://github.com/Zie619/openclaw-setup.git
cd openclaw-setup
bash install.sh
```

---

## Que necesitas antes de empezar

- [ ] Una cuenta de Google (para Gemini AI)
- [ ] Node.js 22+ (el instalador lo instala si falta)
- [ ] 15-20 minutos

---

## Tu equipo de agentes IA

| Agente | Rol | Cerebro | Nivel |
|--------|-----|---------|-------|
| **Cami** | CEO - Coordinadora | gemini-2.5-pro | 3 (Autonomo) |
| **Dev** | Desarrollador Principal | codex-5.2 | 2 (Advisor) |
| **Rex** | Analista de Investigacion | gemini-2.5-pro | 2 (Advisor) |
| **Sage** | Creador de Contenido | gemini-2.5-pro | 2 (Advisor) |
| **Shield** | Monitor de Seguridad | gemini-2.5-flash | 2 (Advisor) |

---

## Que hace el instalador

El script ejecuta **15 fases** automaticamente:

1. Detecta tu sistema operativo (Linux/Mac/Windows)
2. Instala prerequisites (Node.js 22, git, curl, jq, sqlite3)
3. Pide credenciales de forma segura (nunca se guardan en texto plano)
4. **Entrevista de contexto** - te conoce para personalizar los agentes
5. Instala OpenClaw y configura el gateway
6. Crea la estructura de workspace (9 departamentos, 5 oficinas de agentes)
7. Escribe openclaw.json con seguridad hardened
8. Despliega personalidad de agentes (SOUL.md x5) con tu contexto inyectado
9. Crea base de datos SQLite local con 11 tablas + datos iniciales
10. Configura auto-start (systemd / launchd / Task Scheduler)
11. Programa heartbeat cada 15 minutos
12. Conecta Telegram (opcional)
13. Aplica hardening de seguridad (firewall, loopback, session-logs)
14. Ejecuta 22+ verificaciones PASS/FAIL
15. Muestra resumen y proximos pasos

Si algo falla → **rollback automatico** en orden inverso.

---

## Entrevista HITL (Human-in-the-Loop)

Durante la instalacion, el sistema te hace una entrevista exhaustiva de 6 secciones:

1. **Tu identidad** - nombre, rol, empresa
2. **Tu proyecto** - descripcion, industria, fase, competidores
3. **Tus objetivos** - que automatizar, metas a 30 dias y 6 meses
4. **Tu estilo de trabajo** - comunicacion, tono, horario, idioma
5. **Contexto tecnico** - nivel, tech stack, herramientas
6. **Profundizacion** - contenido, restricciones, KPIs

Esta informacion se usa para:
- Personalizar cada SOUL.md de los agentes
- Generar `CONTEXT.md` en el workspace
- Crear propuestas iniciales adaptadas a tus objetivos

---

## Seguridad

- Gateway solo en `127.0.0.1` (sin acceso externo)
- Credenciales en variables de entorno (nunca archivos de texto)
- DM policy: `pairing` (cada mensaje requiere aprobacion)
- Config patch deshabilitado (sin cambios remotos)
- session-logs eliminado (95% ahorro de tokens)
- Firewall UFW configurado (Linux)
- Base de datos local (sin datos en la nube)

---

## Plataformas soportadas

| Plataforma | Estado |
|------------|--------|
| Ubuntu 22.04+ (VPS) | Recomendado |
| macOS 14+ (Apple Silicon / Intel) | Soportado |
| Windows 10/11 (via Git Bash) | Soportado |
| Debian 12+ | Soportado |

---

## Coste mensual estimado

| Servicio | Coste |
|----------|-------|
| VPS (Hetzner CX22) | ~4 EUR |
| Gemini API | 0-20 EUR |
| Telegram | Gratis |
| **Total** | **4-25 EUR/mes** |

---

## Documentacion

- [Arquitectura del sistema](docs/ARCHITECTURE.md)
- [Guia post-instalacion (30 dias)](docs/POST_INSTALL.md)
- [Resolucion de problemas](docs/TROUBLESHOOTING.md)
- [Tu equipo de agentes](docs/AGENTS.md)
- [Estimacion de costes](docs/COST_ESTIMATE.md)

---

## Estructura del repositorio

```
openclaw-setup/
├── install.sh              # Punto de entrada (curl-pipe)
├── src/
│   ├── main.sh             # Orquestador de 15 fases
│   ├── lib/                # Modulos (1 por fase)
│   │   ├── interview.sh    # Entrevista HITL
│   │   ├── database.sh     # SQLite local
│   │   └── ...
│   └── templates/          # Configs, SQL, SOUL.md, CONTEXT.md
├── tests/                  # Tests automaticos
├── docs/                   # Documentacion
└── .github/workflows/      # CI (shellcheck + tests)
```

---

## Licencia

MIT

---

> Inspirado por [snarktank/antfarm](https://github.com/snarktank/antfarm)
