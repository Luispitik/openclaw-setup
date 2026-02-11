# Estimacion de Costes Mensuales

| Servicio | Coste | Notas |
|----------|-------|-------|
| **VPS** | 4-10 EUR/mes | Hetzner CX22 (4 EUR), Contabo (5 EUR) |
| **Gemini API** | 0-20 EUR/mes | Gratis hasta cierto uso |
| **Telegram** | 0 EUR/mes | Gratis |
| **Total** | **4-25 EUR/mes** | Depende del uso |

## Como Reducir Costes

1. **gemini-2.5-flash por defecto** (ya configurado): 70-80% mas barato
2. **session-logs eliminado** (ya configurado): ahorra 95% tokens
3. **Activar triggers gradualmente**: evita picos
4. **Aumentar cooldowns**: mas minutos entre triggers = menos llamadas

## Monitorizacion

```bash
sqlite3 ~/.openclaw/data/openclaw.db "SELECT name, fire_count, last_fired_at FROM trigger_rules WHERE enabled = 1 ORDER BY fire_count DESC;"
```

## Limites Configurados

- Max 20 propuestas/agente/dia
- Max 10 misiones/agente/dia
- Max 10 pasos/mision
- Alerta: >50 triggers o >30 reacciones/dia
