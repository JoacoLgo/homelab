# 06 · Nube y datos

**Bloque 5 (pasos 38–44)** y **Bloque 8 (pasos 64–68)** del plan de estudio.

Las dos patas de la Ruta B — la salida paralela hacia Service Desk, Sysadmin Jr. e infraestructura.
SQL aparece en el 45% de las ofertas de IT y se pide más que Python en la mayoría de los mercados;
Azure es el terreno donde hoy vive la identidad corporativa, que después es el objeto de estudio del
Bloque 7. Nada de esto es un desvío: `AZ-900` y `SC-900` son el vocabulario con el que se entra a
Microsoft Sentinel.

## Qué va acá

Los **documentos y writeups**. Los artefactos ejecutables (`docker-compose.yml`, código de
Terraform, playbooks de Ansible) viven en [`lab/`](../lab/), porque son configuración de
infraestructura y no material de estudio.

`capturas/` guarda las imágenes que acompañan los documentos.

## Índice

### Bloque 5 — SQL, contenedores y nube (pasos 38–44)

- [ ] `38-sql.md` — 40+ ejercicios resueltos, agrupados por tipo de problema *(Paso 38)*
- [ ] `39-sql-datos-propios.md` — base con datos reales del lab, 10 consultas analíticas y una consulta optimizada con su `EXPLAIN` antes y después *(Paso 39)*
- [ ] `40-docker.md` — imagen vs. contenedor, capas, volúmenes, redes, y por qué un contenedor no es una VM *(Paso 40)*
- [ ] `41-azure-fundamentos.md` — responsabilidad compartida, IaaS/PaaS/SaaS, redes virtuales, identidad y modelo de costos (ruta AZ-900) *(Paso 41)*
- [ ] `42-identidad-cloud.md` — la identidad on-premise del lab (AD, Kerberos, GPO) comparada con la de la nube (Entra ID, tokens, acceso condicional) *(Paso 42)*
- [ ] `43-lab-hibrido.md` — workspace de Log Analytics conectado al lab, con alerta de presupuesto *(Paso 43)*

### Bloque 8 — Infraestructura como código y datos (pasos 64–68)

- [ ] `64-terraform.md` — el lab desplegado desde código, y destruido para no gastar el crédito *(Paso 64)*
- [ ] `65-ansible.md` — el hardening del Bloque 2 convertido en playbook *(Paso 65)*
- [ ] `66-pandas.md` — análisis de un export real del lab, con 3 gráficos y conclusiones escritas *(Paso 66)*
- [ ] `67-observabilidad.md` — Prometheus y Grafana con métricas de las VMs y 2 alertas *(Paso 67)*
- [ ] `68-asistente-triage.md` — arquitectura del asistente de triage con IA, con su sección honesta de limitaciones *(Paso 68)*

> **Recordatorio de costos:** todo lo que toque Azure va con **alerta de presupuesto configurada
> antes** de crear el primer recurso. El crédito gratuito se gasta solo.
