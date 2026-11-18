# homelab

Laboratorio de infraestructura y seguridad montado sobre **Hyper-V**, construido a mano y
documentado paso a paso para practicar administración de sistemas Windows/Linux y detección de
amenazas en un entorno que imita al de una empresa chica.

**Autor:** Joaquín Lagoria — estudiante de Seguridad Informática, trabajando en infraestructura IT.
**Objetivo del proyecto:** llegar a un puesto de **Analista SOC L1 / Service Desk** con evidencia
verificable en vez de una lista de cursos.

> **Estado: en construcción.** Arrancó el 31/08/2026 y se levanta de cero, en público.
> Este README dice en cada punto **qué está hecho y qué todavía no**. Nada de lo que figura acá
> como terminado está inventado.

---

## En 40 segundos

| | |
|---|---|
| **Qué es** | Un entorno virtualizado con segmentación de red, dominio de Active Directory, cliente Windows, servidor Linux y envío de telemetría a un SIEM. |
| **Dónde corre** | Hyper-V sobre `HOST-LAB`, una PC de escritorio con Windows 11 Pro (Ryzen 7 8700G, 16 GB), administrada en remoto por SSH sobre Tailscale. |
| **Qué demuestra** | Diseño de red segmentada, administración de AD y GPOs, hardening, scripting (Bash/PowerShell/Python) y detección de ataques con reglas propias. |
| **Cómo se sigue** | Un plan de 75 pasos en 10 bloques. Cada paso termina con un archivo en este repositorio: si no está escrito, no está hecho. |
| **Por dónde empezar a leer** | [`00-diseno/03-router-firewall.md`](00-diseno/03-router-firewall.md): el firewall del lab, lo que estaba mal y cómo lo probé. |

---

## Estado real del laboratorio

Actualizado el **17/11/2026**.

| Pieza | Estado |
|---|---|
| Hipervisor Hyper-V habilitado y corriendo | ✅ Hecho |
| Cuatro switches privados: Servidores, Clientes, Seguridad y Aislada | ✅ Hecho |
| Switch interno `LAB-WAN` con NAT del host (`10.10.0.0/24`) | ✅ Hecho |
| Acceso remoto: SSH sobre Tailscale (RDP como respaldo) | ✅ Hecho |
| Estructura de carpetas del host (`C:\Lab\{VMs,Discos,ISOs}`) | ✅ Hecho |
| `FW01` — router/firewall en Debian 13 con `nftables`, cinco placas, matriz de tráfico probada | ✅ Hecho |
| `SRV01` — Ubuntu Server 26.04, SSH solo con clave, UFW con denegación por defecto, Lynis de 56 a 65 | ✅ Hecho |
| Checkpoint base de las cuatro VMs | ✅ Hecho |
| `DC01` — Windows Server 2022 con AD DS y DNS (`lab.interno`) | 🔨 En curso |
| `WS01` — cliente Windows 11 en `LAB-CLIENTES`, unión al dominio y GPOs | 🔨 En curso |
| Repositorio y documentación | 🔨 En curso |
| Sysmon en los endpoints | ⏳ Pendiente |
| Telemetría hacia Microsoft Sentinel + consultas KQL | ⏳ Pendiente |

La red está armada y probada: los segmentos pasan por `FW01`, que rutea, filtra según la matriz y
hace NAT hacia `LAB-WAN`. Las VMs se administran desde afuera por Tailscale, usando `FW01` como
única puerta. Lo que sigue es terminar el dominio en `DC01` y unir `WS01`.

---

## Topología

```mermaid
graph TB
    HOST["HOST-LAB · Windows 11 Pro<br/>Hyper-V (partición raíz)"]:::host
    WAN["LAB-WAN · Internal<br/>10.10.0.0/24 · NAT del host<br/>gateway 10.10.0.1"]:::nat
    FW["FW01 · Debian 13 + nftables<br/>WAN 10.10.0.2"]:::fw

    S1["LAB-SERVIDORES · 10.10.10.0/24<br/>DC01, SRV01"]:::seg
    S2["LAB-CLIENTES · 10.10.20.0/24<br/>WS01"]:::seg
    S3["LAB-SEGURIDAD · 10.10.30.0/24<br/>colector de logs"]:::seg
    S4["LAB-AISLADA · 10.10.40.0/24<br/>sin ruta a los demás"]:::iso

    HOST --- WAN
    WAN --- FW
    FW --- S1
    FW --- S2
    FW --- S3
    FW -.sin ruta.- S4

    classDef host fill:#eef2f7,stroke:#4a5568,color:#1a202c
    classDef nat fill:#e5f0fb,stroke:#1a6dbd,color:#0d3c6b
    classDef fw fill:#fff4e5,stroke:#b76e00,color:#5c3a00
    classDef seg fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20
    classDef iso fill:#fdeaea,stroke:#c0392b,color:#5c1a13
```

Qué tráfico se permite entre segmentos está en la matriz de
[`00-diseno/02-topologia.md`](00-diseno/02-topologia.md), y el diseño completo, en
[`00-diseno/arquitectura.md`](00-diseno/arquitectura.md).

---

## Estructura del repositorio

Las carpetas numeradas siguen los bloques del plan de estudio. Cada una tiene su propio `README.md`
con el índice de lo que va adentro y a qué pasos corresponde.

| Carpeta | Contenido | Bloques · pasos |
|---|---|---|
| [`00-diseno/`](00-diseno/) | Arquitectura, conceptos de virtualización, topología y guía de reproducción | Bloque 0 · 1–3, 10 |
| [`01-redes/`](01-redes/) | TCP/IP, subnetting, VLANs, Packet Tracer y análisis con Wireshark | Bloque 1 · 11–17 |
| [`02-linux/`](02-linux/) | Administración de Linux, análisis de logs y hardening de servidor | Bloque 2 · 18–24 |
| [`03-windows-ad/`](03-windows-ad/) | Windows Server, Active Directory, GPOs, Event IDs y Sysmon | Bloques 0 y 3 · 4–8, 25–30 |
| [`04-scripting/`](04-scripting/) | Automatización en Bash, PowerShell y Python | Bloque 4 · 31–37 |
| [`05-blue-team/`](05-blue-team/) | SIEM, KQL, MITRE ATT&CK, detecciones, respuesta a incidentes y forense | Bloque 7 · 50–63 |
| [`06-cloud-datos/`](06-cloud-datos/) | SQL, Docker, Azure, Terraform, Ansible, pandas y observabilidad | Bloques 5 y 8 · 38–44, 64–68 |
| [`lab/`](lab/) | Configuración de la infraestructura: reglas de firewall, Sysmon, IaC, datos de ejemplo | Transversal |
| [`bitacora/`](bitacora/) | Registro fechado: qué se hizo, qué se rompió, cómo se resolvió, qué se aprendió | Transversal |
| [`casos-reales/`](casos-reales/) | Problemas que resolví en mi trabajo, sin datos de la empresa | — |

**Convención de nombres:** los documentos llevan adelante el número del paso que los produce —
`00-diseno/01-conceptos-virtualizacion.md` es el resultado del Paso 1. Así se puede ir del plan al
archivo y del archivo al plan sin buscar.

---

## Stack

| Capa | Herramienta | Estado |
|---|---|---|
| Virtualización | Hyper-V (Windows 11 Pro) | En uso |
| Router / firewall | Debian 13 + `nftables` | En uso |
| Directorio | Windows Server 2022 — AD DS, DNS, GPO | En curso |
| Cliente | Windows 11 Pro unido al dominio | En curso |
| Servidor Linux | Ubuntu Server 26.04 LTS · UFW · Lynis | En uso |
| Telemetría de endpoint | Sysmon | Pendiente |
| SIEM | Microsoft Sentinel + KQL | Pendiente |
| Detecciones | Reglas Sigma mapeadas a MITRE ATT&CK | Pendiente |
| Análisis de red | Wireshark · Cisco Packet Tracer | En uso |
| Automatización | Bash · PowerShell · Python | En uso |
| Acceso remoto | Tailscale (subnet router en `FW01`) + OpenSSH con clave | En uso |

---

## Cómo leer este repositorio

Cada documento responde siempre las mismas cuatro preguntas: **qué problema resuelve**, **cómo lo
abordé**, **cómo lo verifiqué** y **qué aprendí**. Los errores están documentados a propósito: un laboratorio que salió
bien a la primera no enseñó nada.

Si venís de una búsqueda laboral y tenés cinco minutos:

1. [`00-diseno/03-router-firewall.md`](00-diseno/03-router-firewall.md) — el firewall del lab: un problema real, el diagnóstico y las pruebas.
2. [`02-linux/23-hardening.md`](02-linux/23-hardening.md) — hardening de un servidor Linux, medido con Lynis antes y después.
3. [`00-diseno/arquitectura.md`](00-diseno/arquitectura.md) — el diseño completo y las decisiones, con su justificación.
4. [`casos-reales/`](casos-reales/) — problemas resueltos en mi trabajo de infraestructura.
