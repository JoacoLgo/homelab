# Arquitectura del laboratorio

**Versión 3 — Hyper-V.** Vigente desde el 27/08/2026 · Datos verificados sobre la máquina el 31/08/2026.
Reemplaza a la v1 (Proxmox sobre servidor propio) y a la v2 (nube), ambas descartadas. El porqué del
descarte está al final: las decisiones revertidas también son parte del diseño.

---

## 1. Qué se busca construir

Replicar la infraestructura de una empresa chica con el nivel de segmentación que se considera
buena práctica, para poder hacer tres cosas sobre el mismo entorno:

1. **Administrarla** como un sysadmin: dominio, usuarios, políticas, permisos, backups.
2. **Atacarla** desde un segmento aislado, de forma controlada.
3. **Detectar** esos ataques desde un SIEM, como lo haría un analista de SOC.

Tres restricciones guían todas las decisiones:

- **Aislamiento del segmento ofensivo.** El tráfico de ataque no sale del laboratorio.
- **Segmentación real.** Servidores, clientes y seguridad separados, no una red plana.
- **Reproducibilidad.** Todo documentado como para reconstruirlo de cero desde este repositorio.

---

## 2. El host

| Componente | Detalle |
|---|---|
| Nombre | `ESSAWI28` |
| CPU | AMD Ryzen 7 8700G — 8 núcleos / 16 hilos (Zen 4) |
| RAM | 16 GB DDR5-4800 en 1 de 2 slots · 15,1 GB visibles al SO · tope de placa 128 GB |
| Disco | NVMe de 477 GB — 205,9 GB libres al 31/08/2026 |
| Red | LAN 2,5 Gb |
| Sistema operativo | Windows 11 Pro 25H2 (build 10.0.26200.9278), fuera de dominio |
| Virtualización | Habilitada en BIOS · `systeminfo` devuelve *"A hypervisor has been detected"*, o sea que el Windows del host ya corre como partición raíz sobre el hipervisor |
| Acceso remoto | OpenSSH Server sobre Tailscale (vía principal) · RDP como respaldo y para consolas gráficas |

Es una PC de escritorio de uso laboral, asignada a un solo usuario y **con autorización explícita
para usarla como laboratorio**. Su licencia de Windows es OEM y está atada al hardware: por eso el
sistema del host no se reinstala ni se virtualiza, el laboratorio se monta **al lado**.

---

## 3. Por qué Hyper-V y no Proxmox

| Criterio | Peso en la decisión |
|---|---|
| **No destruye nada** | No hay que reinstalar el host ni migrar el sistema existente. Es reversible con un comando. |
| **No rompe el acceso remoto** | Si algo falla, la máquina arranca en el Windows de siempre. Un arranque dual o un hipervisor bare-metal podían dejar la máquina inaccesible en remoto: ese era el defecto fatal de la v1. |
| **Ya está incluido** | Windows 11 Pro lo trae; no hace falta hardware ni licencias extra. |
| **El escritorio sigue vivo** | El equipo se sigue usando para trabajar mientras las VMs corren al lado. |

**Contras que se aceptan a conciencia:** sin interfaz web (se administra con Hyper-V Manager y
PowerShell), sin passthrough de USB/PCIe, sin contenedores LXC ni ZFS, y las VLANs se configuran
por PowerShell. Proxmox queda disponible como VM anidada si en algún momento hace falta aprenderlo.

---

## 4. Estado verificado al 31/08/2026

### Switches virtuales

Salida de `Get-VMSwitch`:

| Nombre | Tipo | Situación |
|---|---|---|
| `LAB-SERVIDORES` | Private | Isla: sin router, no habla con nadie |
| `LAB-CLIENTES` | Private | Isla |
| `LAB-SEGURIDAD` | Private | Isla |
| `LAB-AISLADA` | Private | Isla — y va a seguir aislada a propósito |
| `Default Switch` | Internal | NAT + DHCP administrados por Windows. Es la única salida a internet |

Un switch **privado** en Hyper-V conecta VMs entre sí y **nada más**: ni con el host ni con otras
redes. Cuatro switches privados sin router son cuatro islas.

### Máquinas virtuales del laboratorio

**Ninguna todavía.** El host aloja una VM ajena a este proyecto, que se apaga durante las sesiones
de laboratorio; la única consecuencia para el diseño es el presupuesto de memoria de la sección
siguiente.

### Presupuesto de memoria

| Escenario | RAM disponible para el laboratorio |
|---|---|
| Con la VM ajena encendida | ~3,2 GB — insuficiente |
| Con la VM ajena apagada | ~10 GB — alcanza para el laboratorio planificado |

El laboratorio completo con todo prendido a la vez suma ~11 GB (FW01 1 GB + DC01 4 GB + WS01 4 GB +
SRV01 2 GB). Entra usando **memoria dinámica** en las VMs ociosas y sin encender todo
simultáneamente. Ampliar a 32 GB deja de ser urgente y pasa a ser deseable.

---

## 5. Decisión abierta: el router del laboratorio

Es el próximo paso del diseño y la pieza que convierte cuatro islas en una red. Hace falta una VM
con **una placa en cada switch**, que rutee, haga NAT hacia el `Default Switch` y filtre entre
segmentos.

| Opción | A favor | En contra |
|---|---|---|
| **Debian 12 + `nftables`** *(candidata)* | Las reglas se escriben a mano, que es exactamente la habilidad que este laboratorio existe para construir. Consume ~1 GB, un tercio de la alternativa. | Curva más empinada, sin interfaz gráfica. |
| **pfSense / OPNsense** | Interfaz web, es lo que se ve en muchas empresas. | Obligatoriamente **Generación 1** (FreeBSD no arranca con el UEFI de Gen 2) y **sin memoria dinámica**. Más RAM, y clickear una GUI enseña menos. |

**Sin decidir.** Se resuelve en el Paso 3 del plan y queda registrado acá con su justificación.

---

## 6. Plan de direccionamiento propuesto

⚠️ **Propuesta, todavía sin implementar.** Se valida y se corrige en el Paso 2 (topología) y se
recalcula en el Paso 12 (subnetting), cuando el subnetting esté hecho a mano y no copiado.

| Segmento | Switch | Rango | Para qué existe |
|---|---|---|---|
| WAN | `Default Switch` | DHCP de Windows | Salida a internet por el NAT del host |
| Servidores | `LAB-SERVIDORES` | `10.10.10.0/24` | `DC01`, `SRV01` |
| Clientes | `LAB-CLIENTES` | `10.10.20.0/24` | `WS01` y futuros clientes del dominio |
| Seguridad | `LAB-SEGURIDAD` | `10.10.30.0/24` | Colector de logs y herramientas defensivas |
| Aislada | `LAB-AISLADA` | `10.10.40.0/24` | Kali y muestras. **Sin ruta hacia los demás segmentos** |

## 7. Inventario objetivo de VMs

Ninguna existe todavía. Es el destino del Bloque 0 del plan.

| VM | Rol | SO | Recursos previstos | Segmento | Paso |
|---|---|---|---|---|---|
| `FW01` | Router, firewall e inter-segmento | Debian 12 *(a confirmar)* | 1 GB · 1 vCPU · 5 placas | Todos | 3 |
| `DC01` | AD DS, DNS, DHCP | Windows Server 2022 (evaluación 180 días) | 4 GB · 2 vCPU · 60 GB | Servidores | 4–6 |
| `WS01` | Cliente unido al dominio | Windows 11 Pro | 4 GB dinámicos · 2 vCPU | Clientes | 7–8 |
| `SRV01` | Servidor Linux, servicios y logs | Debian / Ubuntu Server | 2 GB dinámicos · 2 vCPU | Servidores | 9 |

---

## 8. Convenciones

- **Generación 2 (UEFI)** para todo lo que la soporte. La elección es irreversible una vez creada
  la VM: no se puede convertir una Gen 1 en Gen 2.
- **Memoria dinámica** en las VMs ociosas, **estática** donde el servicio la necesite reservada.
- **Checkpoints con nombre** en los hitos (`01-SO-limpio`, `02-en-dominio`), y fusionados cuando
  dejan de hacer falta: un checkpoint vivo deja la VM corriendo sobre un disco diferencial.
- **Rutas en el host:** `C:\Lab\{VMs,Discos,ISOs}`. Queda por definir si se mantiene la separación
  VMs/Discos o se adopta el layout por defecto de Hyper-V, que arma
  `C:\Lab\VMs\<VM>\Virtual Hard Disks\`.
- **Nada de credenciales en el repositorio.** Las contraseñas del laboratorio no se versionan ni
  aunque sean de laboratorio: la costumbre es lo que importa.

---

## 9. Decisiones descartadas

Se documentan porque explican por qué el diseño es el que es.

| Alternativa | Por qué se descartó | Fecha |
|---|---|---|
| **Proxmox VE sobre servidor propio** (lab v1) | Sin hardware viable. El servidor disponible era un IBM System x3650 de 2008 (Xeon E5405, 8 GB): dramáticamente inferior al Ryzen 7 8700G, y la instalación de Proxmox dio problemas. | 27/08/2026 |
| **Arranque dual con hipervisor bare-metal** | Riesgo de dejar la máquina inaccesible en remoto, que es el modo de uso principal. | 27/08/2026 |
| **Lab en la nube** (lab v2: Azure + VPS) | Descartado como arquitectura principal por costo y por no practicar administración de hardware. Sobreviven los datasets públicos y la biblioteca de detecciones, que no dependen de ningún hardware. | 27/08/2026 |
| **MacBook Air ARM como host de VMs** | No existe Windows Server para ARM64 y la emulación x86 es inusable. Queda como estación de trabajo: Wireshark, Packet Tracer, terminal, Git, Python y cliente SSH/RDP. | 26/08/2026 |
| **Wazuh como SIEM** | Requerimientos de hardware incompatibles con 16 GB de RAM compartidos. Se reemplaza por Microsoft Sentinel + KQL, que además es lo que se pide en las ofertas de SOC. | 26/08/2026 |

---

## 10. Orden de construcción

1. **Paso 1** — Conceptos de virtualización, escritos con palabras propias. *(En curso)*
2. **Paso 2** — Topología en papel: segmentos, rangos, gateways y diagrama.
3. **Paso 3** — `FW01`: la decisión de arriba, construida y con reglas versionadas en `lab/fw01/`.
4. **Pasos 4–8** — `DC01`, dominio, usuarios por CSV, `WS01` unido al dominio y GPOs con auditoría.
5. **Paso 9** — `SRV01` y acceso por clave SSH.
6. **Paso 10** — Checkpoints, backup y guía de reproducción de todo el laboratorio.
