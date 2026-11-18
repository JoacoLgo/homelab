# Subnetting

**Paso 12 del plan** · En curso

---

## Qué problema resuelve

Dada una IP y su máscara, saber al instante a qué red pertenece, qué rango de hosts tiene y cuál es
su broadcast. Se usa para diseñar redes, para leer una regla de firewall y para diagnosticar por qué
dos equipos "en la misma red" no se ven. Es además la pregunta técnica más común en entrevistas de
redes.

## Cómo lo abordé: el procedimiento

El método del **número mágico**, sin pasar todo a binario:

1. **Buscar el octeto interesante:** el primero cuya máscara no es 255 ni 0.
   `/26` → `255.255.255.192` → el cuarto octeto.
2. **Número mágico = 256 − valor de la máscara en ese octeto.** `256 − 192 = 64`. Las redes van de
   64 en 64: `.0`, `.64`, `.128`, `.192`.
3. **Red:** el múltiplo del número mágico que queda justo por debajo (o igual) del octeto de la IP.
   `.130` cae entre `.128` y `.192` → red `.128`.
4. **Broadcast:** la red siguiente menos 1 → `.191`.
5. **Hosts:** de red + 1 a broadcast − 1 → `.129` a `.190`.
6. **Cantidad de hosts:** `2^(bits de host) − 2`. `/26` tiene 6 bits de host → `64 − 2 = 62`.

Si el octeto interesante no es el último (por ejemplo `/20`), es igual, pero los octetos que siguen
van de `.0` (red) a `.255` (broadcast).

Las máscaras que conviene saber de memoria:

| Prefijo | Máscara | Número mágico | Hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |

## Los 20 ejercicios

| # | IP / prefijo | Máscara | Red | Rango de hosts | Broadcast | Hosts |
|---|---|---|---|---|---|---|
| 1 | `192.168.1.130/26` | `255.255.255.192` | `192.168.1.128` | `192.168.1.129` – `192.168.1.190` | `192.168.1.191` | 62 |
| 2 | `10.0.5.77/20` | `255.255.240.0` | `10.0.0.0` | `10.0.0.1` – `10.0.15.254` | `10.0.15.255` | 4094 |
| 3 | `172.16.200.15/23` | `255.255.254.0` | `172.16.200.0` | `172.16.200.1` – `172.16.201.254` | `172.16.201.255` | 510 |
| 4 | `192.168.10.200/28` | `255.255.255.240` | `192.168.10.192` | `192.168.10.193` – `192.168.10.206` | `192.168.10.207` | 14 |
| 5 | `10.10.20.37/27` | `255.255.255.224` | `10.10.20.32` | `10.10.20.33` – `10.10.20.62` | `10.10.20.63` | 30 |
| 6 | `172.20.33.190/25` | `255.255.255.128` | `172.20.33.128` | `172.20.33.129` – `172.20.33.254` | `172.20.33.255` | 126 |
| 7 | `192.168.50.9/30` | `255.255.255.252` | `192.168.50.8` | `192.168.50.9` – `192.168.50.10` | `192.168.50.11` | 2 |
| 8 | `10.1.1.255/22` | `255.255.252.0` | `10.1.0.0` | `10.1.0.1` – `10.1.3.254` | `10.1.3.255` | 1022 |
| 9 | `172.31.255.254/19` | `255.255.224.0` | `172.31.224.0` | `172.31.224.1` – `172.31.255.254` | `172.31.255.255` | 8190 |
| 10 | `192.168.100.64/29` | `255.255.255.248` | `192.168.100.64` | `192.168.100.65` – `192.168.100.70` | `192.168.100.71` | 6 |
| 11 | `10.200.15.3/21` | `255.255.248.0` | `10.200.8.0` | `10.200.8.1` – `10.200.15.254` | `10.200.15.255` | 2046 |
| 12 | `172.16.0.129/25` | `255.255.255.128` | `172.16.0.128` | `172.16.0.129` – `172.16.0.254` | `172.16.0.255` | 126 |
| 13 | `192.168.7.95/27` | `255.255.255.224` | `192.168.7.64` | `192.168.7.65` – `192.168.7.94` | `192.168.7.95` | 30 |
| 14 | `10.10.10.20/24` | `255.255.255.0` | `10.10.10.0` | `10.10.10.1` – `10.10.10.254` | `10.10.10.255` | 254 |
| 15 | `172.18.44.100/18` | `255.255.192.0` | `172.18.0.0` | `172.18.0.1` – `172.18.63.254` | `172.18.63.255` | 16382 |
| 16 | `192.168.33.240/28` | `255.255.255.240` | `192.168.33.240` | `192.168.33.241` – `192.168.33.254` | `192.168.33.255` | 14 |
| 17 | `10.0.0.200/26` | `255.255.255.192` | `10.0.0.192` | `10.0.0.193` – `10.0.0.254` | `10.0.0.255` | 62 |
| 18 | `172.25.130.1/17` | `255.255.128.0` | `172.25.128.0` | `172.25.128.1` – `172.25.255.254` | `172.25.255.255` | 32766 |
| 19 | `192.168.1.1/31` | `255.255.255.254` | `192.168.1.0` | `192.168.1.0` – `192.168.1.1` | — | 2 |
| 20 | `10.99.99.99/12` | `255.240.0.0` | `10.96.0.0` | `10.96.0.1` – `10.111.255.254` | `10.111.255.255` | 1048574 |

Casos que vale la pena mirar dos veces:

- **#13:** `192.168.7.95` parece un host, pero es el **broadcast** de su red.
- **#7 y #16:** la IP del enunciado es justo la primera usable o la propia dirección de red.
- **#19:** un `/31` no tiene red ni broadcast: las dos direcciones son usables. Se usa en enlaces
  punto a punto entre routers (RFC 3021).
- **#8:** `.255` en el tercer octeto no es broadcast en un `/22`: el broadcast es `10.1.3.255`.

## Los segmentos del lab, recalculados

| Segmento | Rango actual | Equipos previstos | Lo mínimo que alcanza |
|---|---|---|---|
| WAN | `10.10.0.0/24` | 2 (host y `FW01`) | `/30` |
| Servidores | `10.10.10.0/24` | ~4 | `/29` |
| Clientes | `10.10.20.0/24` | ~3 | `/29` |
| Seguridad | `10.10.30.0/24` | 1–2 | `/29` |
| Aislada | `10.10.40.0/24` | 1–2 | `/29` |

**Decisión: mantener los `/24`.** El espacio `10.0.0.0/8` es privado y sobra, así que achicar no
ahorra nada real. A cambio, el `/24` hace que el tercer octeto diga el segmento (`10` servidores,
`20` clientes, `30` seguridad, `40` aislada): leyendo una IP en un log ya sé de dónde viene, y las
reglas de firewall quedan más claras. Si fuera una red con direcciones escasas, la usaría con VLSM.

## Cómo lo verifiqué

Los resultados de la tabla están comprobados con el módulo `ipaddress` de Python. Para ganar
velocidad practico en `subnettingpractice.com`, sin calculadora.

## Qué aprendí

- No hace falta pasar todo a binario: con el número mágico alcanza para el 90% de los casos.
- El error más común es tomar como host una dirección que es red o broadcast. Siempre conviene
  ubicar los límites del bloque primero.

## Pendiente

- Bajar el tiempo por ejercicio a menos de 60 segundos, que es el objetivo del paso.
- VLSM: repartir un bloque entre subredes de distinto tamaño.
