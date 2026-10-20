### 1. Topologia
┌───────────────────┬──────────────┬────────────┬──────────┬───────────┬─────────┐
│ Desde ↓ / Hacia → │ WAN/Internet │ Servidores │ Clientes │ Seguridad │ Aislada │
├───────────────────┼──────────────┼────────────┼──────────┼───────────┼─────────┤
│ Servidores        │ DENEGAR      │ -          | DENEGAR  │ DENEGAR   | DENEGAR │
├───────────────────┼──────────────┼────────────┼──────────┼───────────┼─────────┤
│ Clientes          │ PERMITIR     | PERMITIR   │ -        │ DENEGAR   │ DENEGAR │
├───────────────────┼──────────────┼────────────┼──────────┼───────────┼─────────┤
│ Seguridad         │ PERMITIR     |  PERMITIR  |  PERMITIR| -         | PERMITIR|
├───────────────────┼──────────────┼────────────┼──────────┼───────────┼─────────┤
│ Aislada           │ DENEGAR      │ DENEGAR    │ DENEGAR  │ DENEGAR   | -       │
└───────────────────┴──────────────┴────────────┴──────────┴───────────┴─────────┘

### 2. Detalle de Segmentos y VMs

- **WAN / Internet** (`LAB-WAN` - Interno + NAT)
  - Gateway: IP del host
  - VMs: Ninguna (Interfaz de salida de `FW01`)
  - Propósito: Simula la conexión de la red externa o módem del proveedor.

- **Servidores** (`LAB-SERVIDORES` - Privado | `10.10.10.0/24` | GW: `10.10.10.1`)
  - VMs: `DC01`, `SRV01`
  - Propósito: Aloja infraestructura crítica de directorio activo, DNS y servicios Linux.

- Clientes (`LAB-CLIENTES` - Privado | `10.10.20.0/24` | GW: `10.10.20.1`)
  - VMs: `WS01`
  - Propósito: Estaciones de trabajo de empleados para probar GPOs y endpoints.

- **Seguridad** (`LAB-SEGURIDAD` - Privado | `10.10.30.0/24` | GW: `10.10.30.1`)
  - VMs: `SEC01` *(temporal)*
  - Propósito: Red dedicada de auditoría y análisis de vulnerabilidades.

- **Aislada** (`LAB-AISLADA` - Privado | `10.10.40.0/24` | GW: bloqueado)
  - VMs: `KALI` *(opcional)*
  - Propósito: Zona completamente incomunicada para pruebas de ataque.