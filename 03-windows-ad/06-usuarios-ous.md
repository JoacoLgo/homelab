# OUs, grupos y usuarios

**Paso 6 del plan** · Revisado el 18/11/2026

---

## Qué problema resuelve

Un dominio con tres usuarios sueltos no se parece a una empresa. Con estructura departamental se
pueden aplicar políticas por área, dar permisos por grupo y, más adelante, ver ataques que se
mueven entre cuentas con distintos privilegios.

## Cómo lo abordé

| OU | Contenido |
|---|---|
| `Usuarios` | Las cuentas de los empleados |
| `Equipos` | Las estaciones de trabajo (`WS01`) |
| `Grupos`, `Grupos_Seguridad` | Grupos por área |
| `Servicios` | Cuentas de servicio |

- **20 usuarios ficticios** repartidos en 6 departamentos: IT, Recursos Humanos, Ventas, Finanzas,
  Marketing y Operaciones.
- **Un grupo global por departamento** (`GG_IT`, `GG_Ventas`, etc.). Los permisos se dan a los
  grupos, nunca a usuarios sueltos.

## Cómo lo verifiqué

```powershell
Get-ADUser -Filter * -Properties Department | group Department
```

## Pendiente

- Subir el script de importación por CSV a `04-scripting/powershell/` y un CSV de ejemplo a `lab/data/`.
- Revisar la OU `usersGUI`, que tiene un usuario de prueba, y el objeto de equipo `WS02`, que no
  tiene VM.
