# lab · Configuración de la infraestructura

Los archivos que **se aplican sobre las máquinas** del laboratorio: reglas de firewall,
configuraciones de agentes, infraestructura como código y datos de ejemplo.

La diferencia con el resto del repositorio: las carpetas numeradas (`00-` a `06-`) contienen
**documentación** — qué aprendí y cómo lo entendí. Esta contiene **artefactos** — lo que corre.
Si se pierde el laboratorio entero, esta carpeta más la guía de reproducción del Paso 10 tienen que
alcanzar para levantarlo de nuevo.

## Contenido

| Carpeta | Qué va adentro | Paso |
|---|---|---|
| `fw01/` | Reglas de `nftables` (o la config exportada de pfSense) del router del laboratorio | 3 |
| `sysmon/` | Configuración de Sysmon desplegada en los endpoints, con las modificaciones propias comentadas | 28 |
| `docker/` | `docker-compose.yml` de los stacks levantados en `SRV01` | 40 |
| `terraform/` | Código que despliega la parte del lab que vive en Azure | 64 |
| `ansible/` | Playbooks de hardening y configuración | 65 |
| `data/` | Datos de ejemplo: `usuarios.csv` para poblar el dominio, exports anonimizados | 6 |

Los **scripts** (Bash, PowerShell, Python) no van acá: viven en
[`04-scripting/`](../04-scripting/), ordenados por lenguaje.

> La hoja de ruta menciona rutas tipo `lab/scripts/audit-linux.sh`. En este repositorio ese archivo
> vive en `04-scripting/bash/audit-linux.sh`: código y configuración separados, cada cosa con un
> solo lugar posible.

## Reglas de esta carpeta

1. **Ninguna credencial, clave ni token.** Ni de laboratorio. Si un archivo necesita un secreto, va
   una versión `.example` con los valores en blanco y el real queda fuera por `.gitignore`.
2. **Cada archivo con un comentario arriba** que diga en qué máquina se aplica y qué hace.
3. **Nada que no se haya aplicado de verdad.** Esta carpeta describe el laboratorio que existe, no
   el que me gustaría tener.
