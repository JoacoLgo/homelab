# 00 · Diseño

**Bloque 0 (pasos 1–3 y 10)** del plan de estudio.

El laboratorio se diseña antes de construirse. Esta carpeta es la respuesta a "¿por qué el lab es
así y no de otra manera?", que es exactamente lo que se pregunta en una entrevista de
infraestructura.

## Qué va acá

Los documentos de diseño y los conceptos que hay que tener firmes **antes** de crear la primera VM.
La construcción propiamente dicha se documenta en [`03-windows-ad/`](../03-windows-ad/) y
[`02-linux/`](../02-linux/); la configuración que corre en las máquinas, en [`lab/`](../lab/).

`capturas/` guarda las imágenes y diagramas que acompañan los documentos.

## Índice

- [x] [`arquitectura.md`](arquitectura.md) — el diseño completo: host, switches, presupuesto de RAM, inventario objetivo de VMs, convenciones y decisiones descartadas
- [ ] [`01-conceptos-virtualizacion.md`](01-conceptos-virtualizacion.md) — los seis conceptos de virtualización explicados con palabras propias *(Paso 1 · en curso)*
- [ ] `02-topologia.md` + `diagrama-lab.png` — segmento, switch, rango IP, gateway, qué VMs viven ahí y para qué existe cada uno *(Paso 2)*
- [ ] `03-router-firewall.md` — la decisión entre Debian + `nftables` y pfSense, con su justificación y el resultado de la prueba de aislamiento *(Paso 3)*
- [ ] `10-guia-de-reproduccion.md` — cómo levantar este laboratorio de cero desde este repositorio, más la estrategia de checkpoints y backup *(Paso 10)*

> **Criterio del Paso 1:** el documento de conceptos está hecho cuando se puede escribir **sin
> copiar de ninguna fuente**. Si hay que copiar, el paso no está hecho.
