# FW01: el router y firewall del laboratorio

**Paso 3 del plan** · VM creada el 16/10/2026 · Configuración corregida y probada el 17/11/2026

Los archivos que se aplican en la máquina están en [`lab/fw01/`](../lab/fw01/).

---

## Qué problema resuelve

Los cuatro segmentos del lab son switches **privados** de Hyper-V: cada uno es una isla. Hace falta
una máquina con una placa en cada switch que:

- **rutee** entre segmentos,
- **filtre** según la [matriz de tráfico](02-topologia.md),
- haga **NAT** hacia `LAB-WAN` para salir a internet,
- y sea la **única puerta de administración** desde afuera.

## Cómo lo abordé

### La decisión: Debian + nftables

Entre Debian con `nftables` y pfSense elegí Debian (13, la estable actual). Las reglas se escriben a
mano, que es lo que quiero aprender, y consume ~1 GB de RAM contra ~3 GB de pfSense. La comparación
completa está en [`arquitectura.md`](arquitectura.md#5-el-router-del-laboratorio-fw01).

### La VM

| Propiedad | Valor |
|---|---|
| Generación | 2 (UEFI) |
| Secure Boot | Plantilla *Microsoft UEFI Certificate Authority*. Con la plantilla por defecto (*Microsoft Windows*) la ISO de Debian no arranca |
| Memoria | 1 GB estática |
| Placas | 5, con la MAC fijada a mano en Hyper-V |

| Placa | MAC | Switch | Dirección |
|---|---|---|---|
| `wan` | `00:15:5d:09:0c:05` | `LAB-WAN` | `10.10.0.2/24`, gateway `10.10.0.1` |
| `srv` | `00:15:5d:09:0c:06` | `LAB-SERVIDORES` | `10.10.10.1/24` |
| `cli` | `00:15:5d:09:0c:07` | `LAB-CLIENTES` | `10.10.20.1/24` |
| `seg` | `00:15:5d:09:0c:08` | `LAB-SEGURIDAD` | `10.10.30.1/24` |
| `ais` | `00:15:5d:09:0c:09` | `LAB-AISLADA` | sin IP, a propósito |

### Administración remota

`FW01` tiene Tailscale y funciona como **subnet router**: anuncia `10.10.10.0/24` y `10.10.20.0/24`,
y desde mi Mac llego a las VMs a través de él. Así no hace falta abrir nada hacia la WAN, y el
firewall sigue decidiendo qué se puede administrar: solo SSH y RDP, y nunca hacia Aislada.

---

## Qué se rompió

Al revisar la máquina para documentarla encontré que **no estaba haciendo nada de lo que tenía que
hacer**, aunque a simple vista funcionaba:

1. **`net.ipv4.ip_forward = 0`.** Linux por defecto no reenvía paquetes entre placas. `FW01` tenía
   cinco placas, pero no ruteaba.
2. **`/etc/nftables.conf` era el de fábrica:** tres cadenas vacías, sin `policy drop` y sin NAT. No
   filtraba nada.
3. **La IP de Clientes estaba en la placa de Aislada.** En `/etc/network/interfaces` le había puesto
   `10.10.20.1` a `eth2` con el comentario `#red LAB-CLIENTES`. Pero cruzando las MAC con Hyper-V:

   ```
   eth2  00:15:5d:09:0c:09   →  en Hyper-V, 0C09 es LAB-AISLADA
   eth3  00:15:5d:09:0c:07   →  LAB-CLIENTES (sin IP, DOWN)
   ```

   Debian numera las placas `eth0…eth4` en el orden en que las detecta, y ese orden **no tiene por
   qué** coincidir con el orden en que las creé en Hyper-V. Asumí que sí.

## Cómo lo resolví

| Problema | Solución | Archivo |
|---|---|---|
| Nombres de placa que dependen del orden | Un archivo `.link` de systemd por placa, que le pone nombre según la MAC: `wan`, `srv`, `cli`, `seg`, `ais`. Por esto fijé las MAC a mano: ahora cada nombre queda atado a su switch | [`systemd/*.link`](../lab/fw01/systemd/) |
| IPs en la placa equivocada | `interfaces` reescrito con los nombres nuevos. Aislada queda levantada pero sin IP: nada de esa red puede usar a `FW01` de gateway | [`interfaces`](../lab/fw01/interfaces) |
| No rutea | `net.ipv4.ip_forward = 1` en `sysctl.d` | [`99-router.conf`](../lab/fw01/99-router.conf) |
| No filtra | La matriz traducida a reglas, con `policy drop` en `input` y `forward`, y NAT con `masquerade` hacia `wan` | [`nftables.conf`](../lab/fw01/nftables.conf) |
| Sin SSH | OpenSSH solo con clave, sin root, y accesible únicamente por Tailscale | [`sshd-lab.conf`](../lab/fw01/sshd-lab.conf) |

Un detalle de `nftables.conf`: **no usa `flush ruleset`**. Tailscale crea sus propias tablas, y un
`flush` las borra cada vez que se recarga el firewall. En su lugar el archivo borra y recrea solo
mis tablas (`inet lab` e `ip lab_nat`), así que recargarlo es seguro.

### DNS: un solo camino

Según el plan, `FW01` es el gateway y `DC01` es el DNS del lab. Para que el DNS respete la misma
lógica que el resto del tráfico (una sola salida, todo revisado):

```
WS01 / SRV01 ──DNS──► DC01 ──si no es de lab.interno──► FW01 ──► internet
```

- `DC01` es el **único** que puede consultar DNS de internet (puerto 53), y `FW01` registra cada
  consulta con el prefijo `LAB-DNS-DC01`.
- Cualquier otro equipo que intente usar un DNS externo directamente se descarta y queda registrado
  como `LAB-DNS-BLOQ`. Esto incluye a Clientes y Seguridad, que sí tienen salida a internet.

Descarté poner un segundo resolvedor DNS en `FW01`: duplicaba un rol que el diseño le da a `DC01`.

Todo se aplica con [`instalar.sh`](../lab/fw01/instalar.sh), que antes de tocar nada hace un backup
y valida la sintaxis con `nft -c`.

## Cómo lo verifiqué

Pruebas hechas el 17/11/2026, después de reiniciar `FW01`:

| Prueba | Esperado | Resultado |
|---|---|---|
| `ip -br a`: cada placa con su nombre e IP | `cli` con MAC `…0c:07` y `10.10.20.1` | ✅ |
| `/proc/sys/net/ipv4/ip_forward` | `1` | ✅ |
| `FW01` → internet | Sale | ✅ |
| Mac → `DC01` (ping, por Tailscale) | Pasa | ✅ |
| Mac → `SRV01:22` (por Tailscale) | Pasa | ✅ |
| Mac → `DC01:445` (SMB, por Tailscale) | Bloqueado: desde Tailscale solo SSH y RDP | ✅ |
| `SRV01` → internet | Bloqueado: Servidores no tiene salida | ✅ |
| SSH a `FW01` con contraseña | Rechazado, solo clave | ✅ |
| `SRV01` → `1.1.1.1:53` (DNS externo directo) | Bloqueado y registrado como `LAB-DNS-BLOQ` | ✅ |

**Pendiente de probar:** el tráfico que sale de Clientes, Seguridad y Aislada. Todavía no hay VMs
encendidas en esos segmentos.

Una excepción necesaria: para instalar paquetes en Servidores agregué una regla **temporal**, solo
en memoria, que les da salida a internet. Como no está en el archivo, desaparece con
`systemctl reload nftables`. Quedó registrada en la [bitácora](../bitacora/2026-11-17-fw01-y-srv01.md).

## Qué aprendí

- **"Anda" no es lo mismo que "está configurado".** `FW01` respondía pings y tenía Tailscale, pero
  no ruteaba ni filtraba. Hasta que no probé la matriz desde afuera, no lo sabía.
- **Los nombres de las placas no son estables.** Si una configuración depende de `eth2`, depende
  del orden de detección. Atarla a la MAC es lo que la hace reproducible.
- **Una regla de firewall hay que verificarla de los dos lados:** que pase lo que tiene que pasar, y
  que **no** pase lo que no tiene que pasar.
- **El orden importa en nftables:** una regla `accept` en otra tabla no alcanza si mi tabla descarta
  el paquete. Por eso el tráfico de Tailscale está permitido explícitamente en mis reglas.
