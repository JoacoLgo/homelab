# Arquitectura del laboratorio

**Versión 3 — Hyper-V.** Vigente desde el 27/08/2026 · Actualizado el 17/11/2026.
Reemplaza a la v1 (Proxmox sobre servidor propio) y a la v2 (nube), ambas descartadas. El porqué del
descarte está al final: las decisiones revertidas también son parte del diseño.

---

## 1. Qué se busca construir

Replicar la infraestructura de una empresa chica con el nivel de segmentación que se considera buena práctica, para poder hacer tres cosas sobre el mismo entorno:

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
| Nombre | `HOST-LAB` |
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

## 4. Estado al 17/11/2026

### Switches virtuales

| Nombre | Tipo | Situación |
|---|---|---|
| `LAB-WAN` | Internal + NAT del host | Red `10.10.0.0/24`. El host es el gateway (`10.10.0.1`) y hace NAT hacia internet. Es la WAN de `FW01` |
| `LAB-SERVIDORES` | Private | Conectado a `FW01` |
| `LAB-CLIENTES` | Private | Conectado a `FW01` |
| `LAB-SEGURIDAD` | Private | Conectado a `FW01` |
| `LAB-AISLADA` | Private | Conectado a `FW01`, sin ruta hacia los demás segmentos |
| `Default Switch` | Internal | Lo crea Windows y no se puede borrar. El lab no lo usa |

Un switch **privado** conecta VMs entre sí y nada más. Por eso los cuatro segmentos necesitan a
`FW01` en el medio: es la única máquina con una placa en cada uno.

El lab usa `LAB-WAN` en lugar del `Default Switch`: el `Default Switch` puede cambiar de rango
cuando se reinicia el host, y el firewall necesita una WAN con dirección fija.

### Máquinas virtuales del laboratorio

| VM | Estado |
|---|---|
| `FW01` | ✅ Funcionando y probada. Detalle en la sección 5 |
| `SRV01` | ✅ Funcionando y endurecida ([Paso 9](../02-linux/09-srv01.md), [Paso 23](../02-linux/23-hardening.md)) |
| `DC01` | 🔨 Creada, con AD DS y DNS para `lab.interno` respondiendo |
| `WS01` | 🔨 Creada en `LAB-CLIENTES` |

Las cuatro tienen un checkpoint base del 10/11/2026.

El host aloja además una VM ajena a este proyecto, que se apaga durante las sesiones de
laboratorio. La única consecuencia para el diseño es el presupuesto de memoria.

### Presupuesto de memoria

| Escenario | RAM disponible para el laboratorio |
|---|---|
| Con la VM ajena encendida | ~3,2 GB — insuficiente |
| Con la VM ajena apagada | ~10 GB — alcanza para el laboratorio planificado |

El laboratorio completo con todo prendido a la vez suma ~11 GB (FW01 1 GB + DC01 4 GB + WS01 4 GB +
SRV01 2 GB). Entra usando memoria dinámica en las VMs Windows y sin prender todo a la vez.
Ampliar a 32 GB deja de ser urgente y pasa a ser deseable.

---

## 5. El router del laboratorio: `FW01`

Las dos opciones que evalué:

| Opción | A favor | En contra |
|---|---|---|
| **Debian + `nftables`** *(elegida)* | Las reglas se escriben a mano, que es justo lo que quiero aprender. Consume ~1 GB, un tercio de la alternativa. | Curva más empinada, sin interfaz gráfica. |
| **pfSense / OPNsense** | Interfaz web, es lo que se ve en muchas empresas. | Obligatoriamente Generación 1 (FreeBSD no arranca con el UEFI de Gen 2) y sin memoria dinámica. Más RAM, y clickear una GUI enseña menos. |

Elegí **Debian 13** (la estable actual) en lugar de Debian 12, que era lo que tenía anotado al
principio.

| Propiedad | Valor | Por qué |
|---|---|---|
| Generación | 2 (UEFI) | Debian la soporta, y no se puede cambiar después de creada la VM |
| Secure Boot | Plantilla **Microsoft UEFI Certificate Authority** | La plantilla por defecto (*Microsoft Windows*) solo confía en el cargador de Windows. Con esa plantilla, la ISO de Debian no arranca |
| Placas de red | 5: `LAB-WAN` + los cuatro segmentos | Una por red que tiene que rutear |
| Direcciones MAC | Fijadas a mano | Con MAC dinámica, Hyper-V puede cambiarla y Debian deja de saber qué placa es cuál. Fijándola, cada interfaz queda siempre atada a su switch |
| WAN | `10.10.0.2/24`, gateway `10.10.0.1` | IP fija dentro de `LAB-WAN` |
| Firewall | `nftables`, reglas aplicadas y probadas | Siguen la matriz de tráfico de [`02-topologia.md`](02-topologia.md). Archivos en [`lab/fw01/`](../lab/fw01/) |

La construcción, los problemas que encontré y las pruebas están en
[`03-router-firewall.md`](03-router-firewall.md).

---

## 6. Plan de direccionamiento

Los rangos salen del Paso 2 ([`02-topologia.md`](02-topologia.md)) y se recalculan en el Paso 12
(subnetting), cuando lo haga a mano.

| Segmento | Switch | Rango | Gateway | Para qué existe |
|---|---|---|---|---|
| WAN | `LAB-WAN` | `10.10.0.0/24` | `10.10.0.1` (host) | Salida a internet por el NAT del host. `FW01` tiene la `.2` |
| Servidores | `LAB-SERVIDORES` | `10.10.10.0/24` | `10.10.10.1` (`FW01`) | `DC01`, `SRV01` |
| Clientes | `LAB-CLIENTES` | `10.10.20.0/24` | `10.10.20.1` (`FW01`) | `WS01` y futuros clientes del dominio |
| Seguridad | `LAB-SEGURIDAD` | `10.10.30.0/24` | `10.10.30.1` (`FW01`) | Colector de logs y herramientas defensivas |
| Aislada | `LAB-AISLADA` | `10.10.40.0/24` | — | Kali y muestras. **Sin ruta hacia los demás segmentos** |

## 7. Inventario de VMs

| VM | Rol | SO | Recursos | Segmento | Paso | Estado |
|---|---|---|---|---|---|---|
| `FW01` | Router, firewall e inter-segmento | Debian 13 | 1 GB estáticos · 5 placas | Todos | 3 | ✅ |
| `DC01` | AD DS, DNS | Windows Server 2022 (evaluación 180 días) | 4 GB dinámicos | Servidores · `10.10.10.10` | 4–6 | 🔨 |
| `WS01` | Cliente unido al dominio | Windows 11 Pro | 4 GB dinámicos | Clientes | 7–8 | 🔨 |
| `SRV01` | Servidor Linux, servicios y logs | Ubuntu Server 26.04 LTS | 2 GB estáticos | Servidores · `10.10.10.20` | 9 | ✅ |

---

## 8. Convenciones

- **Generación 2 (UEFI)** para todo lo que la soporte. La elección es irreversible una vez creada
  la VM: no se puede convertir una Gen 1 en Gen 2.
- **Memoria estática en todas las VMs Linux.** Es la regla del lab: en Hyper-V, la memoria dinámica
  en Linux depende del driver `hv_balloon` y no siempre se comporta bien, y en VMs de 1 o 2 GB el
  ahorro es mínimo. La dinámica queda para las VMs Windows.
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
| **Proxmox VE sobre servidor propio** (lab v1) | Sin hardware viable. El único servidor disponible era un equipo de 2008 (Xeon, 8 GB): dramáticamente inferior al Ryzen 7 8700G, y la instalación de Proxmox dio problemas. | 27/08/2026 |
| **Arranque dual con hipervisor bare-metal** | Riesgo de dejar la máquina inaccesible en remoto, que es el modo de uso principal. | 27/08/2026 |
| **Lab en la nube** (lab v2: Azure + VPS) | Descartado como arquitectura principal por costo y por no practicar administración de hardware. Sobreviven los datasets públicos y la biblioteca de detecciones, que no dependen de ningún hardware. | 27/08/2026 |
| **MacBook Air ARM como host de VMs** | No existe Windows Server para ARM64 y la emulación x86 es inusable. Queda como estación de trabajo: Wireshark, Packet Tracer, terminal, Git, Python y cliente SSH/RDP. | 26/08/2026 |
| **Wazuh como SIEM** | Requerimientos de hardware incompatibles con 16 GB de RAM compartidos. Se reemplaza por Microsoft Sentinel + KQL, que además es lo que se pide en las ofertas de SOC. | 26/08/2026 |

---

## 10. Orden de construcción

1. ✅ **Paso 1** — Conceptos de virtualización, escritos con palabras propias.
2. ✅ **Paso 2** — Topología: segmentos, rangos, gateways, matriz de tráfico y diagrama.
3. ✅ **Paso 3** — `FW01` con Debian 13 y `nftables`, reglas versionadas en `lab/fw01/`.
4. 🔨 **Pasos 4–8** — `DC01` y el dominio `lab.interno` creados. Falta: usuarios por CSV, `WS01` unido al dominio y GPOs con auditoría.
5. ✅ **Paso 9** — `SRV01` con acceso solo por clave SSH.
6. 🔨 **Paso 10** — Checkpoint base de las cuatro VMs hecho. Falta la guía de reproducción.
