# pfSense perdía el enlace cada vez que Suricata arrancaba o paraba

**Caso real** · Firewall perimetral con pfSense y Suricata como IDS/IPS

---

## Qué problema resuelve

El firewall de la oficina tenía Suricata para inspeccionar el tráfico. Cada vez que Suricata
arrancaba o se detenía, por un reinicio, una actualización de reglas o un cambio de configuración,
**las placas de red perdían el enlace** durante unos segundos. Además, **fallaba el DHCP de la
WAN**: el firewall se quedaba sin dirección del proveedor y la oficina, sin internet.

## Cómo lo abordé

1. **Relacionar el corte con un evento.** Los cortes coincidían con los arranques y paradas de
   Suricata, no con la carga de tráfico ni con el horario.
2. **Entender qué hace Suricata con la placa.** Para inspeccionar todo el tráfico, Suricata pone
   la interfaz en **modo promiscuo**, y en modo IPS (inline) la usa a través de *netmap*. Ese cambio
   de modo se aplica sobre el driver de la placa.
3. **Mirar el driver.** Las placas eran **Realtek**, que en FreeBSD (la base de pfSense) usan el
   driver `re`. Ese driver reinicia el enlace al cambiar de modo y tiene un soporte limitado de
   netmap. Las placas **Intel**, con el driver `igb`, son las que se recomiendan para pfSense con
   Suricata.
4. **Explicar el DHCP.** Con el enlace caído durante la renegociación, la solicitud DHCP de la WAN
   no llegaba a completarse.

## Cómo lo resolví

Pasé **LAN y WAN a placas Intel (`igb`)** y reasigné las interfaces en pfSense. Las Realtek quedaron
sin uso para el tráfico inspeccionado.

## Cómo lo verifiqué

- Reinicié Suricata con las interfaces nuevas: **el enlace no se cortó**.
- La WAN obtuvo su dirección por DHCP sin fallar.
- En los logs del sistema dejaron de aparecer los eventos de enlace caído y levantado en cada
  arranque de Suricata.

## Qué aprendí

- **El hardware importa en un firewall.** El mismo software se comporta distinto según el driver de
  la placa.
- Un síntoma de red (DHCP que falla) puede tener la causa en otra capa: acá era capa 1 y 2, el
  enlace, provocado por un cambio de modo de la placa.
- Antes de elegir placas para pfSense, revisar la lista de hardware recomendado y el soporte del
  driver para netmap si se va a usar Suricata en modo inline.
