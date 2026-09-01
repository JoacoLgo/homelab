# 01 · Redes

**Bloque 1 (pasos 11–17)** del plan de estudio.

Fundamentos de TCP/IP, subnetting y análisis de tráfico real. Es el bloque que se puede avanzar en
paralelo al laboratorio, porque no depende de que haya VMs levantadas: lo único que hace falta es
Packet Tracer, Wireshark y la red que ya existe.

## Qué va acá

| Carpeta | Contenido |
|---|---|
| `packet-tracer/` | Topologías `.pkt` con su explicación al lado |
| `subnetting/` | Ejercicios resueltos a mano, con el procedimiento escrito |
| `capturas/` | Imágenes de Wireshark que acompañan los writeups |

Los archivos `.pcapng` **no se versionan** (los bloquea el `.gitignore`: pesan y suelen traer datos
propios adentro). Si una captura ilustra algo y está revisada, se sube a mano con
`git add -f` y se explica en el writeup qué se está mirando.

## Índice

- [ ] `11-modelo-osi.md` — tabla de capas: protocolo de ejemplo, unidad de datos y problema típico de cada una *(Paso 11)*
- [ ] `12-subnetting.md` — 20 ejercicios resueltos y el procedimiento con palabras propias, más los segmentos del lab recalculados y justificados *(Paso 12)*
- [ ] `13-vlans-stp.md` + topología en `packet-tracer/` — 3 VLANs con routing entre ellas (router-on-a-stick) *(Paso 13)*
- [ ] `14-routing.md` — el recorrido completo de un paquete desde `WS01` hasta internet, salto por salto, con la tabla de routing de cada equipo *(Paso 14)*
- [ ] `15-servicios.md` — capturas propias de una consulta DNS, un DORA de DHCP y un handshake TLS, explicadas campo por campo *(Paso 15)*
- [ ] `16-wireshark.md` — filtros de captura y de display, seguir un flujo, leer una conversación *(Paso 16)*
- [ ] [`17-que-pasa-cuando-escribo-una-url.md`](17-que-pasa-cuando-escribo-una-url.md) — el entregable del bloque, con capturas propias *(Paso 17)*

> **Objetivo medible del bloque:** hacer subnetting a mano en menos de 60 segundos, y poder
> explicar qué MAC de destino lleva una trama que va hacia otra red — y por qué.
