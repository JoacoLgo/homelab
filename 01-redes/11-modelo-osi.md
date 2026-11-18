# Modelo OSI y TCP/IP

**Paso 11 del plan**

---

## Qué problema resuelve

El modelo OSI divide la comunicación en capas. Sirve para dos cosas: tener un vocabulario común
("es un problema de capa 2") y diagnosticar en orden, de abajo hacia arriba, sin saltar a
conclusiones.

## Las capas

| # | Capa OSI | Qué hace | Protocolo de ejemplo | PDU | Problema típico |
|---|---|---|---|---|---|
| 7 | Aplicación | Lo que usa el programa | HTTP, DNS, SMB, SSH | Datos | La app responde con error (un 500, un login rechazado) |
| 6 | Presentación | Formato, cifrado, compresión | TLS, codificación de texto | Datos | Certificado vencido o caracteres rotos |
| 5 | Sesión | Abrir, mantener y cerrar el diálogo | RPC, sesiones SMB | Datos | La sesión se corta por timeout |
| 4 | Transporte | Puertos, entrega confiable o rápida | TCP, UDP | Segmento / datagrama | Puerto cerrado o bloqueado por firewall |
| 3 | Red | Direcciones IP y ruteo entre redes | IPv4, ICMP | Paquete | Falta el gateway o una ruta |
| 2 | Enlace | Entrega dentro de la misma red, por MAC | Ethernet, ARP, 802.1Q | Trama | VLAN equivocada, ARP sin respuesta |
| 1 | Física | Bits en el cable o en el aire | Cobre, fibra, Wi-Fi | Bit | Cable roto, placa desconectada |

TCP/IP agrupa las capas 5, 6 y 7 en una sola (Aplicación) y la 1 y la 2 en Acceso a la red. En la
práctica se habla con los números de OSI.

## Encapsulamiento

Cuando un equipo manda algo, cada capa le agrega su encabezado al bloque que recibe de la capa de
arriba. Para pedir una página web:

```
[ HTTP GET ]                                         capa 7  datos
[ TCP: puerto origen, 443 ] [ datos ]                capa 4  segmento
[ IP: origen, destino ] [ TCP ] [ datos ]            capa 3  paquete
[ Ethernet: MAC origen, MAC destino ] [ IP ] ... [ FCS ]   capa 2  trama
```

El receptor hace el camino inverso: cada capa saca su encabezado y le pasa el resto a la de arriba.

**El detalle que más se pregunta:** si el destino está en **otra** red, la IP de destino es la del
servidor final, pero la **MAC de destino es la del gateway**. Las IPs se mantienen de punta a punta;
las MAC cambian en cada salto.

## Direccionamiento IPv4

- Una IPv4 son 32 bits; la máscara dice cuántos son red y cuántos son host.
- Rangos privados (RFC 1918): `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`. No salen a internet
  sin NAT. El lab usa `10.10.0.0/16`.
- `127.0.0.0/8` es loopback, y `169.254.0.0/16` aparece cuando un equipo no consiguió DHCP.

## Cómo lo uso en el lab

Diagnosticando `FW01` usé el orden de las capas. La IP del gateway de Clientes (capa 3) estaba
configurada en una placa conectada al switch de Aislada (capa 2). Visto desde Clientes, el gateway
no existía: ningún equipo de ese segmento podía resolver su MAC con ARP. Está en [`00-diseno/03-router-firewall.md`](../00-diseno/03-router-firewall.md).
