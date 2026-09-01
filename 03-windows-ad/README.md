# 03 · Windows y Active Directory

**Bloque 0 (pasos 4–8)** — la construcción del dominio — y **Bloque 3 (pasos 25–30)** — la
seguridad de la identidad.

El entorno del 90% de las empresas reales, y el terreno donde ocurre la mayoría de los ataques que
después hay que detectar en el Bloque 7. Este bloque produce la telemetría con la que se trabaja
más adelante: sin dominio no hay eventos, y sin eventos no hay detecciones.

## Qué va acá

Los writeups de construcción y de análisis. Los **scripts de PowerShell** viven en
[`04-scripting/powershell/`](../04-scripting/powershell/); la **config de Sysmon** y el **CSV de
usuarios**, en [`lab/`](../lab/).

## Índice

### Construcción del dominio (Bloque 0)

- [ ] `04-dc01.md` — la VM del controlador de dominio: Windows Server 2022 de evaluación, Generación 2, IP fija. Creada a mano y después reproducida con PowerShell para entender qué hace cada clic *(Paso 4)*
- [ ] `05-dominio.md` — promoción a controlador de dominio, `dcdiag` sin errores críticos y resolución DNS funcionando *(Paso 5)*
- [ ] `06-usuarios-ous.md` — OUs, grupos y usuarios importados por CSV *(Paso 6 · script y CSV en `04-scripting/powershell/` y `lab/data/`)*
- [ ] `07-ws01.md` — el cliente Windows 11 unido al dominio, con el evento 4624 visible en el DC *(Paso 7)*
- [ ] `08-gpos.md` — 5 GPOs verificadas desde el cliente con `gpresult`, cada una con qué hace y por qué *(Paso 8)*

### Seguridad de la identidad (Bloque 3)

- [ ] `25-kerberos.md` — Kerberos y NTLM: el flujo dibujado a mano y las capturas donde se ve cada mensaje *(Paso 25)*
- [ ] `26-permisos-ntfs.md` — estructura de carpetas departamental con su matriz de permisos *(Paso 26)*
- [ ] `27-event-ids.md` — tabla de Event IDs: qué significa cada uno, qué campos leer, y cómo se ve el mismo evento cuando es benigno y cuando es sospechoso *(Paso 27)*
- [ ] `28-sysmon.md` — Sysmon en los dos equipos y una comparación del mismo evento con y sin Sysmon *(Paso 28)*
- [ ] `29-hardening-ad.md` — informe de PingCastle antes, controles aplicados con su justificación, informe después *(Paso 29)*

> **Objetivo medible del bloque:** tener un dominio con GPOs configuradas a mano y poder explicar
> qué hace cada una, sin leerlo de ningún lado.
