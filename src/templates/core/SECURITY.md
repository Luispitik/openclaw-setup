# SEGURIDAD DEL SISTEMA

- Gateway: solo acepta conexiones locales (127.0.0.1)
- Acceso remoto: solo via SSH
- Mensajes: requieren aprobacion explicita (pairing)
- Canales externos: aislados del sistema principal
- Archivos: los agentes solo pueden tocar su workspace y ClawWork
- Configuracion: no se puede cambiar remotamente
- session-logs: ELIMINADO (ahorra dinero)
- Contrasenas: nunca en archivos de texto, siempre en variables de entorno
