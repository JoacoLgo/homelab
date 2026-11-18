# GPOs

**Paso 8 del plan** · Revisadas y corregidas el 18/11/2026

---

## Qué problema resuelve

Las GPOs son la forma de administrar cientos de equipos Windows sin tocarlos uno por uno. La
auditoría de procesos, además, es la que le da datos al SIEM del Bloque 7.

## Cómo lo abordé

| GPO | Qué hace | Lado | Vinculada a |
|---|---|---|---|
| `Bloqueo-USB` | Niega el acceso a todo almacenamiento extraíble | Equipo | `Equipos` |
| `Permissions-RDP` | Agrega `GG_IT` y mi usuario al grupo local *Remote Desktop Users* | Equipo | `Equipos` |
| `Bloqueo-Pantalla` | Protector de pantalla con contraseña y tiempo de espera | Usuario | `Usuarios` |
| `Unidad-Red-Z` | Mapea la unidad de red `Z:` | Usuario | `Usuarios` |
| `Auditoria-Procesos` | Audita la creación de procesos (evento 4688) e incluye la línea de comandos | Equipo | `Equipos` |
| `Default Domain Policy` | Contraseñas: mínimo 7 caracteres, complejidad, historial de 24, caducidad de 30 días | Equipo | Dominio |

## Qué se rompió

Revisando qué configura cada GPO y dónde está vinculada encontré que **tres no se aplicaban**:

1. **`Bloqueo-USB` configura equipos pero estaba vinculada a `Usuarios`.** Una GPO solo aplica a
   los objetos de la OU donde está vinculada: la parte de equipo necesita equipos, y en `Usuarios`
   no hay ninguno.
2. **`Permissions-RDP` estaba del lado usuario y vinculada a `Equipos`.** Doble problema: en
   `Equipos` no hay usuarios, y agregar miembros a un grupo local es una configuración de la
   **máquina**.
3. **`passwords` nunca se aplicó.** En un dominio, la política de contraseñas sale de **una sola
   GPO** vinculada a la raíz, la de mayor prioridad. `Default Domain Policy` tenía orden 1 y ganaba.
   Además, `passwords` pedía un mínimo de 6 caracteres, menos que los 7 que ya había.

También había una GPO `Permisos-RDP` vacía y sin vincular, que era un duplicado.

Lo detecté leyendo el reporte de cada GPO (`Get-GPOReport -ReportType Xml`): qué parte configura
(equipo o usuario) y dónde está vinculada.

## Cómo lo resolví

Antes de tocar nada: `Backup-GPO -All`.

| GPO | Corrección |
|---|---|
| `Bloqueo-USB` | Vínculo movido de `Usuarios` a `Equipos` |
| `Permissions-RDP` | Preferencia movida al lado equipo, con los miembros como `LAB\...` y su SID |
| `passwords` | La caducidad de 30 días, que era lo que buscaba, pasó a `Default Domain Policy`. No apliqué el mínimo de 6 ni el historial de 5 porque eran más débiles. Después borré la GPO |
| `Permisos-RDP` | Borrada |

## Cómo lo verifiqué

| Prueba | Resultado |
|---|---|
| Política de contraseñas efectiva (`Get-ADDefaultDomainPasswordPolicy`) | Mínimo 7, complejidad, historial 24, caducidad 30 días ✅ |
| Reporte de `Bloqueo-USB` y `Permissions-RDP` | Lado equipo, vinculadas a `Equipos` ✅ |
| `gpresult /h` en `WS01` | ⏳ Pendiente: `WS01` está apagada |

## Qué aprendí

- **Una GPO configura equipos, usuarios o las dos cosas, y solo aplica a los objetos de la OU donde
  está vinculada.** Si no coinciden, la GPO existe pero no hace nada, y no tira ningún error.
- La política de contraseñas del dominio no se reparte entre varias GPOs: gana una.
- Antes de corregir: backup. `Restore-GPO` deshace cualquier cambio.

## Pendiente

- Verificar todo desde `WS01` con `gpresult /h`.
- Bloqueo de cuentas por intentos fallidos (hoy está desactivado).
- Auditoría de procesos también en `DC01`, que está en la OU `Domain Controllers` y no la recibe.
