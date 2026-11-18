# El dominio lab.interno

**Paso 5 del plan** · Revisado el 18/11/2026

---

## Qué problema resuelve

Un dominio de Active Directory centraliza usuarios, equipos y políticas. Es lo que usa casi
cualquier empresa, y es donde ocurre la mayoría de los ataques que después hay que detectar.

## Cómo lo abordé

| Propiedad | Valor |
|---|---|
| Dominio | `lab.interno` (NetBIOS `LAB`) |
| Nivel funcional | Windows Server 2025, de dominio y de bosque |
| Zonas DNS | `lab.interno` y `_msdcs.lab.interno`, integradas en AD |

Elegí `lab.interno` y no `lab.local`: `.local` está reservado para mDNS y trae conflictos con
equipos Apple y Linux.

## Qué se rompió: el DNS no resolvía nada de internet

`DC01` respondía los nombres del dominio, pero no los de internet. Los reenviadores DNS eran:

```
fec0:0:0:ffff::1, fec0:0:0:ffff::2, fec0:0:0:ffff::3
```

Son direcciones IPv6 *site-local*, un tipo que ya no se usa, y Windows las deja cuando el DNS queda
sin configurar al promover el controlador. Nadie respondía en esas direcciones, así que cada
consulta hacia afuera fallaba. Mirando el tráfico en `FW01` no aparecía ni un paquete de `DC01`
hacia internet.

## Cómo lo resolví

```powershell
Set-DnsServerForwarder -IPAddress 1.1.1.1,8.8.8.8
Clear-DnsServerCache -Force
```

Esas consultas salen por `FW01`, que solo le permite a `DC01` el puerto 53 hacia afuera y registra
cada consulta. Ningún otro equipo del lab puede usar un DNS externo: todos le preguntan a `DC01`.
El diseño completo está en [`00-diseno/03-router-firewall.md`](../00-diseno/03-router-firewall.md).

## Cómo lo verifiqué

| Prueba | Resultado |
|---|---|
| `DC01` resuelve `lab.interno` | ✅ |
| `DC01` resuelve nombres de internet | ✅ |
| `SRV01` resuelve nombres de internet preguntándole a `DC01` | ✅ |
| `DC01` → internet por cualquier puerto que no sea DNS | ✅ Bloqueado |
| `dcdiag /q` | Todas las pruebas pasan menos **SystemLog**, por dos errores del 17/11: el servicio de OpenSSH se cortó una vez al instalarlo, y un error del KDC con el nombre de cuenta vacío que coincide con las conexiones SSH |

## Qué aprendí

- "El DNS anda" hay que probarlo con nombres internos **y** externos: pueden fallar por separado.
- Si un servidor no genera tráfico hacia afuera, mirar el firewall no alcanza: hay que mirar la
  configuración del propio servidor.

## Pendiente

- Investigar el error del KDC que marca `dcdiag`.
