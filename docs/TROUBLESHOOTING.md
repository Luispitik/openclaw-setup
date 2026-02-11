# Resolucion de Problemas

## Gateway no arranca

```bash
# Ver error
sudo journalctl -u openclaw-gateway --no-pager | tail -20

# Puerto ocupado
sudo lsof -i:3000
sudo kill $(sudo lsof -t -i:3000)
sudo systemctl restart openclaw-gateway
```

## Agente no responde

1. `openclaw gateway status` → debe decir "running"
2. `openclaw sessions list` → verificar sesiones
3. `openclaw sessions restart agent:limon:main` → reiniciar

## Telegram no funciona

```bash
openclaw channels status
# Si no aparece:
openclaw channels remove telegram
openclaw channels add telegram --token "TOKEN" --session "agent:limon:main" --allowed-users "TU_ID"
```

## Tokens se gastan rapido

1. Verificar session-logs eliminado: `ls ~/.openclaw/workspace/skills/session-logs`
2. Default model = gemini-2.5-flash en openclaw.json
3. Reducir heartbeat: cambiar */15 a */30 en crontab
4. Desactivar triggers no necesarios:
   ```bash
   sqlite3 ~/.openclaw/data/openclaw.db "UPDATE trigger_rules SET enabled = 0 WHERE name = 'NOMBRE';"
   ```

## Base de datos SQLite

### Verificar estado
```bash
sqlite3 ~/.openclaw/data/openclaw.db "SELECT COUNT(*) FROM sqlite_master WHERE type='table';"
# Debe devolver 11

sqlite3 ~/.openclaw/data/openclaw.db "SELECT name, status FROM agents;"
# Debe mostrar 5 agentes
```

### Backup manual
```bash
cp ~/.openclaw/data/openclaw.db ~/.openclaw/data/openclaw.db.backup
```

### Restaurar backup
```bash
cp ~/.openclaw/data/openclaw.db.backup ~/.openclaw/data/openclaw.db
```

### Permisos de archivo
```bash
ls -la ~/.openclaw/data/openclaw.db
# Debe ser -rw------- (solo tu usuario)
chmod 600 ~/.openclaw/data/openclaw.db
```

## Servicio systemd falla

```bash
sudo systemctl status openclaw-gateway
sudo journalctl -u openclaw-gateway -n 50 --no-pager
which openclaw   # Verificar ruta
```

## Comandos de Emergencia

```bash
# Parar todo
sudo systemctl stop openclaw-gateway
crontab -l | grep -v heartbeat | crontab -

# Reiniciar todo
sudo systemctl restart openclaw-gateway

# Logs en tiempo real
sudo journalctl -u openclaw-gateway -f
tail -f ~/.openclaw/logs/heartbeat.log
```
