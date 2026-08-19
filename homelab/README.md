# homelab

Laboratorio de infraestructura y seguridad construido desde cero para practicar administración de
sistemas y detección de amenazas en un entorno que replica el de una empresa pequeña.

**Estado:** en construcción · **Inicio:** agosto de 2026

---

## Qué hay acá

Un entorno virtualizado sobre **Proxmox VE** con segmentación de red real: firewall pfSense,
dominio de Active Directory, clientes Windows, servidor Linux, SIEM y un segmento ofensivo
aislado. Cada componente está documentado con las decisiones de diseño detrás, no solo con los
pasos de instalación.

```mermaid
graph LR
    FW[FW01 · pfSense]:::fw
    FW --- V10[VLAN 10<br/>SERVIDORES<br/>10.10.10.0/24]:::v
    FW --- V20[VLAN 20<br/>CLIENTES<br/>10.10.20.0/24]:::v
    FW --- V30[VLAN 30<br/>SEGURIDAD<br/>10.10.30.0/24]:::v
    FW -.sin salida.- V99[VLAN 99<br/>AISLADA<br/>10.10.99.0/24]:::k

    classDef fw fill:#fff4e5,stroke:#b76e00,color:#5c3a00
    classDef v fill:#e5f0fb,stroke:#1a6dbd,color:#0d3c6b
    classDef k fill:#fdeaea,stroke:#c0392b,color:#5c1a13
```

El diagrama completo, el inventario de VMs, el plan de direccionamiento y las reglas de firewall
están en [`00-diseno/arquitectura.md`](00-diseno/arquitectura.md).

---

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| [`00-diseno/`](00-diseno/) | Arquitectura del lab, diagramas y decisiones de diseño |
| [`01-redes/`](01-redes/) | Topologías de Packet Tracer, subnetting y análisis de tráfico |
| [`02-linux/`](02-linux/) | Administración de Linux, hardening y scripting de sistema |
| [`03-windows-ad/`](03-windows-ad/) | Windows Server, Active Directory y políticas de grupo |
| [`04-scripting/`](04-scripting/) | Automatización en Bash, PowerShell y Python |
| [`05-blue-team/`](05-blue-team/) | SIEM, detecciones, análisis de incidentes y forense |
| [`bitacora/`](bitacora/) | Una entrada por semana. Qué se hizo, qué se rompió, qué se aprendió |

---

## Stack

**Virtualización:** Proxmox VE
**Red:** pfSense CE · VLANs 802.1Q
**Windows:** Windows Server 2022 (AD DS, DNS, DHCP) · Windows 11 Pro
**Linux:** Ubuntu Server 24.04 LTS
**Seguridad:** Wazuh · Sysmon · Suricata · Kali Linux
**Herramientas:** Wireshark · Packet Tracer · Nmap

---

## Cómo leer este repo

Cada carpeta tiene su propio `README.md` con el índice de lo que contiene. Los documentos siguen
siempre la misma estructura: **qué problema resuelve**, **cómo lo abordé**, **qué aprendí**.

Si venís de una oferta de trabajo y tenés poco tiempo, mirá
[`00-diseno/arquitectura.md`](00-diseno/arquitectura.md) y la entrada más reciente de
[`bitacora/`](bitacora/).
