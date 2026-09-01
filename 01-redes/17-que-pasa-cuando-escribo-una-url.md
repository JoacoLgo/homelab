# Qué pasa exactamente cuando escribo una URL

**Entregable del Bloque 1 · Paso 17** · Análisis con capturas propias de Wireshark

> Es la pregunta de entrevista técnica más frecuente que existe. La diferencia entre recitarla y
> responderla con capturas propias es la diferencia entre un candidato y otro.

---

## Escenario

- **Máquina:** MacBook Air (ARM64), macOS
- **Interfaz capturada:** `en0`
- **URL de prueba:** `https://______`
- **Fecha de la captura:**
- **Archivo:** `captura-url.pcapng`

---

## 1. Resolución del nombre — DNS

**Filtro:** `dns`

*(Captura acá. Qué se ve: la consulta tipo A al resolver, y la respuesta con la IP.)*

**Qué observé:**

- Puerto y protocolo de transporte usados:
- Servidor DNS consultado:
- IP devuelta:
- Tiempo de respuesta:

**Pregunta a responder:** ¿por qué la consulta salió a ese servidor y no a otro?

---

## 2. Encontrar al vecino — ARP

**Filtro:** `arp`

**Qué observé:**

- ¿A quién le preguntó la Mac por su MAC, y por qué a ese y no al servidor destino?

**El concepto clave:** la trama que sale de mi máquina hacia un destino en otra red lleva la MAC
del **gateway**, no la del servidor. La IP de destino sí es la del servidor. Esa disociación
entre capa 2 y capa 3 es el corazón del encapsulamiento.

---

## 3. Establecer la conexión — handshake TCP

**Filtro:** `tcp.flags.syn == 1`

**Qué observé:**

| Paso | Origen | Destino | Flags | Seq | Ack |
|---|---|---|---|---|---|
| 1 | | | SYN | | |
| 2 | | | SYN, ACK | | |
| 3 | | | ACK | | |

- Puerto de origen (efímero):
- Puerto de destino:
- MSS negociado:

---

## 4. Cifrar el canal — handshake TLS

**Filtro:** `tls.handshake`

**Qué observé:**

- **Client Hello:** versiones ofrecidas, SNI (¿se ve el dominio en claro?), suites de cifrado
- **Server Hello:** versión y suite elegidas
- **Certificate:** emisor, cadena, validez
- ¿A partir de qué paquete deja de verse el contenido?

**Pregunta a responder:** ¿qué información sigue siendo visible para alguien que observa la red
aunque el tráfico esté cifrado? *(Pista: mirá el SNI y el DNS.)*

---

## 5. Pedir la página — HTTP

**Filtro:** `http` *(sobre un sitio sin HTTPS, para poder verlo en claro)*

**Qué observé:**

- Método, ruta, versión:
- Cabeceras que envía el navegador:
- Código de respuesta:

---

## 6. Línea de tiempo completa

| # | Tiempo | Protocolo | Qué pasó |
|---|---|---|---|
| 1 | 0.000 s | DNS | |
| 2 | | ARP | |
| 3 | | TCP | |
| 4 | | TLS | |
| 5 | | HTTP | |

---

## Qué aprendí

*(Tres o cuatro líneas. Lo que te sorprendió, lo que creías que era de otra manera, la parte que
tuviste que mirar dos veces.)*
