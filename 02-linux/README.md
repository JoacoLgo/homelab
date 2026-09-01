# 02 · Linux

**Bloque 2 (pasos 18–24)** del plan de estudio, más el Paso 9 del Bloque 0 (`SRV01`).

Administración de servidores Linux, análisis de logs y hardening. Todo se practica sobre `SRV01`,
el servidor Linux del laboratorio, no sobre ejemplos de tutorial.

## Qué va acá

Los writeups y la documentación. El **script de auditoría** que produce el bloque vive en
[`04-scripting/bash/`](../04-scripting/bash/), con el resto del código.

## Índice

- [ ] `09-srv01.md` — instalación del servidor Linux, IP fija, SSH por clave desde la Mac vía Tailscale y autenticación por contraseña deshabilitada *(Paso 9)*
- [ ] `18-filesystem.md` — mapa de los directorios que importan y para qué sirve cada uno *(Paso 18)*
- [ ] `19-permisos.md` — usuarios, grupos, permisos y procesos, incluyendo cómo listar los binarios SUID del sistema y por qué eso importa *(Paso 19)*
- [ ] `20-bandit.md` — OverTheWire *Bandit*, niveles 0 a 20: qué pedía cada uno, cómo lo resolví, qué comando aprendí. **Sin publicar las contraseñas** *(Paso 20)*
- [ ] `21-grep-awk-sed.md` — 15 casos resueltos sobre logs reales: top de IPs que fallaron el login, quién usó `sudo`, intentos por hora *(Paso 21)*
- [ ] `22-systemd.md` — servicios, unidades y logs del sistema, con un servicio propio corriendo bajo systemd *(Paso 22)*
- [ ] `23-hardening.md` — qué cambié, por qué, y la salida de `ss -tulpn` antes y después *(Paso 23)*
- [ ] `24-auditoria-bash.md` — writeup del entregable del bloque *(Paso 24 · el script va en `04-scripting/bash/`)*

> **Objetivo medible del bloque:** moverse por Linux sin interfaz gráfica y encontrar cualquier cosa
> dentro de un log sin buscar el comando en internet.
