# Hardening de SRV01

**Paso 23 del plan** · Hecho el 17/11/2026 sobre `SRV01` (Ubuntu Server 26.04 LTS)

---

## Qué problema resuelve

Un servidor recién instalado viene pensado para funcionar, no para ser seguro. El objetivo es
reducir lo que se puede atacar y **medir** cuánto mejoró, en lugar de decir "lo endurecí".

La medición la hace **Lynis**, que audita el sistema y da un índice de hardening de 0 a 100 más una
lista de advertencias y sugerencias. Lo corrí antes y después de los cambios.

## Punto de partida

```
sudo lynis audit system --quick
```

| Métrica | Antes |
|---|---|
| Índice de hardening | **56** |
| Advertencias | 2: paquetes con vulnerabilidades conocidas y un reinicio pendiente por el kernel |
| Sugerencias | 48 |
| Firewall | Ninguno activo |

Revisando a mano encontré dos cosas que Lynis no marcó como advertencia:

### 1. La contraseña por SSH seguía habilitada

En `/etc/ssh/sshd_config` había escrito `PasswordAuthentication no`. Pero conectándome desde afuera
con un usuario inventado, el servidor ofrecía:

```
$ ssh -v -o PubkeyAuthentication=no nadie@10.10.10.20
debug1: Authentications that can continue: publickey,password
```

**Por qué:** `sshd_config` incluye en la línea 24 los archivos de `/etc/ssh/sshd_config.d/`, y mi
`no` estaba en la línea 78. Ubuntu deja ahí `50-cloud-init.conf` con `PasswordAuthentication yes`,
y **en sshd gana el primer valor que se lee**, no el último.

### 2. UFW estaba instalado pero apagado

`systemctl is-active ufw` respondía `active`, pero `/etc/ufw/ufw.conf` decía `ENABLED=no` y las
reglas eran las de fábrica. El servicio corriendo no significa que el firewall filtre.

## Cómo lo abordé

| Cambio | Cómo | Por qué |
|---|---|---|
| SSH solo con clave | Borré `50-cloud-init.conf` y creé `sshd_config.d/10-lab.conf` con `PasswordAuthentication no`, `KbdInteractiveAuthentication no` y `PermitRootLogin no` | Sin contraseña no hay fuerza bruta posible por SSH |
| Firewall con denegación por defecto | `ufw default deny incoming` y una sola regla: SSH desde `10.10.10.1` | Todo lo que entra a `SRV01` desde afuera llega por `FW01` (Tailscale reescribe el origen). Cualquier otra cosa se descarta |
| Paquetes actualizados | `apt upgrade` y reinicio | Resuelve las dos advertencias de Lynis |

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.10.10.1 to any port 22 proto tcp comment "SSH solo desde FW01 (Tailscale)"
sudo ufw logging on
sudo ufw enable
```

Antes de activar UFW verifiqué desde qué IP llegaba mi propia conexión (`echo $SSH_CLIENT` →
`10.10.10.1`). Si la regla hubiera tenido otra IP, me dejaba afuera.

## Cómo lo verifiqué

| Métrica | Antes | Después |
|---|---|---|
| Índice de hardening de Lynis | 56 | **65** |
| Advertencias | 2 | **0** |
| Sugerencias | 48 | 46 |
| Firewall activo según Lynis | No | Sí |
| Métodos SSH ofrecidos | `publickey,password` | `publickey` |

Pruebas de que el firewall bloquea lo que tiene que bloquear:

| Prueba | Esperado | Resultado |
|---|---|---|
| Servicio de prueba en el puerto 8080, consultado desde el propio `SRV01` | Responde | ✅ 200 |
| El mismo puerto 8080 desde `FW01` | Bloqueado por UFW | ✅ |
| SSH desde `FW01` | Permitido | ✅ |
| UFW y la regla después de reiniciar | Siguen activos | ✅ |

## Qué aprendí

- **Verificar desde afuera.** El archivo decía una cosa y el servidor hacía otra. La única forma
  de saberlo fue mirarlo como lo mira un atacante.
- **El orden de lectura de una configuración es parte de la configuración.** En sshd gana el
  primer valor; en otros programas, el último.
- **Un servicio "active" no es un firewall activo.** Hay que mirar las reglas cargadas.
- **El índice de Lynis es una guía, no una nota.** Subió 9 puntos con tres cambios, pero lo que
  importa es qué riesgo cerró cada uno.

## Pendiente

Las 46 sugerencias que quedan, ordenadas por lo que más aportan en este servidor:

- `fail2ban` (DEB-0880). Con SSH solo por clave el riesgo es bajo, pero suma visibilidad.
- Política de contraseñas en `/etc/login.defs` (AUTH-9286, AUTH-9230) y `umask 027` (AUTH-9328).
- Contraseña en GRUB (BOOT-5122).
- `auditd` para registrar cambios en archivos sensibles. Es el paso previo a mandar estos logs al SIEM.
