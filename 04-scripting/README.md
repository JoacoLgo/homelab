# 04 · Scripting

**Bloque 4 (pasos 31–37)**, más los entregables de automatización de los Bloques 2 y 3.

Automatización real de tareas del laboratorio. No ejercicios de tutorial: scripts que resuelven un
problema concreto de este entorno y que se corren de verdad.

## Qué va acá

Todo el **código**, ordenado por lenguaje. La configuración de infraestructura va en
[`lab/`](../lab/).

| Carpeta | Lenguaje | Para qué |
|---|---|---|
| `bash/` | Bash | Auditoría y hardening de servidores Linux |
| `powershell/` | PowerShell | Creación de VMs, administración y auditoría de Active Directory |
| `python/` | Python | Enriquecimiento de IOCs, consumo de APIs, procesamiento de logs |

Cada script lleva su propio README o una cabecera que explique **qué chequea, por qué eso importa y
cómo se corre**, más una salida de ejemplo.

## Índice

- [ ] `powershell/new-lab-vm.ps1` — crea una VM del laboratorio con parámetros, en vez de repetir el asistente gráfico *(Paso 4)*
- [ ] `powershell/import-usuarios.ps1` — puebla el dominio con OUs, grupos y usuarios desde `lab/data/usuarios.csv` *(Paso 6)*
- [ ] `powershell/lab-start.ps1` · `lab-stop.ps1` — encienden y apagan el laboratorio en orden *(Paso 10)*
- [ ] `bash/audit-linux.sh` — auditoría de servidor: usuarios, puertos abiertos, servicios, permisos anómalos. Con manejo de errores y corriendo por cron en `SRV01` *(Paso 24)*
- [ ] `31-powershell-objetos.md` — el salto conceptual de texto a objetos, con el mismo problema resuelto en Bash y en PowerShell *(Paso 31)*
- [ ] `32-funciones-powershell.md` — una función propia con parámetros, ayuda comentada (`Get-Help` funciona sobre ella) y manejo de errores *(Paso 32)*
- [ ] `powershell/audit-ad.ps1` — auditoría del dominio: cuentas inactivas, contraseñas viejas, miembros de Domain Admins. Con informe de ejemplo *(Paso 33)*
- [ ] `34-git.md` — ramas, `merge`, `rebase`, resolución de un conflicto a mano y qué hacer cuando algo se rompe *(Paso 34)*
- [ ] `35-python.md` — de cero a útil, con un script que resuelva un problema propio real *(Paso 35)*
- [ ] `python/enrich-ips.py` — toma una lista de IPs, consulta dos APIs de threat intel y devuelve un CSV con reputación, país y ASN *(Paso 36)*

> **Regla que no se negocia:** las API keys van en variables de entorno. **Nunca** commiteadas, ni
> siquiera "temporalmente" — un secreto que entró al historial de Git hay que darlo por quemado.
