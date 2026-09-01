# 05 · Blue Team

**Bloque 7 (pasos 50–63)** del plan de estudio.

Detección, análisis e informes: la parte del portfolio que apunta directo al puesto de Analista SOC
L1. Tres de los seis proyectos del plan salen de acá.

Depende del Bloque 0: sin dominio, sin cliente y sin Sysmon no hay telemetría, y sin telemetría no
hay nada que detectar. Por eso llega después y no antes.

## Qué va acá

Writeups, análisis e informes. **SIEM elegido: Microsoft Sentinel + KQL** — Wazuh quedó descartado
por requerimientos de hardware, y KQL además es lo que efectivamente se pide en las ofertas.

Las **reglas de detección** van a vivir en un repositorio propio (`detections`), separado de este:
es el proyecto que más diferencia el perfil y se sostiene solo.

## Índice

- [ ] `50-que-es-un-soc.md` — el recorrido de una alerta desde que se genera hasta que se cierra, y qué hace un L1 en cada etapa *(Paso 50)*
- [ ] `51-sentinel.md` — 4 fuentes del lab reportando a Sentinel, verificado con una consulta KQL. **Con alerta de presupuesto activa** *(Paso 51)*
- [ ] `52-kql.md` — 30 consultas propias comentadas, de la más simple a una con `join` y ventana temporal *(Paso 52)*
- [ ] `53-analisis-windows.md` — 10 preguntas de investigación con su consulta y su respuesta: quién se logueó fuera de horario, qué procesos lanzó Word, qué cuentas fallaron el login más de 5 veces *(Paso 53)*
- [ ] `54-attack-navigator.md` — capa propia de MITRE ATT&CK Navigator marcando qué técnicas se pueden detectar con la telemetría actual *(Paso 54)*
- [ ] `55-detecciones.md` — metodología de escritura de reglas Sigma *(Paso 55 · las reglas van al repo `detections`)*
- [ ] `56-matriz-cobertura.md` — técnica ejecutada con Atomic Red Team · ¿generó telemetría? · ¿disparó alerta? · qué hay que ajustar *(Paso 56)*
- [ ] `57-respuesta-incidentes.md` — el método, más la plantilla propia de informe *(Paso 57)*
- [ ] `58-informe-incidente.md` — el entregable mayor: cadena de ataque completa, detectada y reportada, con resumen ejecutivo, línea de tiempo, mapeo ATT&CK, IOCs, contención y lecciones aprendidas *(Paso 58)*
- [ ] `59-phishing/` — 3 análisis completos con veredicto, evidencia, IOCs y recomendación. **Con los datos personales tachados** *(Paso 59)*
- [ ] `60-pcaps/` — 3 PCAPs resueltos: qué pasó, cómo lo determiné, qué IOCs saqué *(Paso 60)*
- [ ] `61-triage-malware.md` — procedimiento propio paso a paso y 2 muestras analizadas. **Nunca malware real sobre una máquina conectada a la red del trabajo** *(Paso 61)*
- [ ] `62-vulnerabilidades.md` — hallazgos priorizados, remediación aplicada y segundo escaneo que muestre la mejora en números *(Paso 62)*
- [ ] `63-casos/` — 15+ casos de triage cronometrados, cada uno con tiempo empleado, hipótesis, evidencia y veredicto *(Paso 63)*

> **Regla de seguridad de esta carpeta:** todo lo que venga de una muestra real se analiza aislado y
> se publica anonimizado. Nada de datos personales de terceros, direcciones de la red del trabajo ni
> muestras ejecutables en el repositorio.
