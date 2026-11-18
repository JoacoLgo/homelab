# FW01 · configuración

Lo que corre en `FW01`, el router y firewall del laboratorio (Debian 13). El porqué de cada decisión
y las pruebas están en [`00-diseno/03-router-firewall.md`](../../00-diseno/03-router-firewall.md).

| Archivo | Destino en FW01 | Qué hace |
|---|---|---|
| [`systemd/*.link`](systemd/) | `/etc/systemd/network/` | Nombra cada placa según su MAC: `wan`, `srv`, `cli`, `seg`, `ais` |
| [`interfaces`](interfaces) | `/etc/network/interfaces` | Direcciones de cada placa. Aislada sin IP |
| [`99-router.conf`](99-router.conf) | `/etc/sysctl.d/` | Habilita el reenvío de paquetes |
| [`nftables.conf`](nftables.conf) | `/etc/nftables.conf` | Matriz de tráfico, NAT y acceso de administración por Tailscale |
| [`sshd-lab.conf`](sshd-lab.conf) | `/etc/ssh/sshd_config.d/10-lab.conf` | SSH solo con clave, sin root |
| [`instalar.sh`](instalar.sh) | — | Backup, validación con `nft -c` e instalación de todo lo anterior |

## Cómo se aplica

Desde la consola de Hyper-V (no por SSH: si algo falla, la consola no se corta):

```bash
sudo bash instalar.sh
sudo reboot
```

Después del reinicio:

```bash
ip -br a                          # wan, srv, cli, seg, ais con sus IPs
cat /proc/sys/net/ipv4/ip_forward # 1
sudo nft list table inet lab      # las reglas cargadas
```

## Si las MAC cambian

Los `.link` dependen de las MAC fijadas en Hyper-V. Si se recrea la VM, hay que volver a fijarlas
(`Set-VMNetworkAdapter -StaticMacAddress`) o actualizar los cinco archivos.
