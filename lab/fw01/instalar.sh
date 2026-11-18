#!/bin/bash
# FW01 · instala la configuración de red y firewall de esta carpeta.
# Se corre desde la carpeta donde están los archivos:  sudo bash instalar.sh
# Después hay que reiniciar: los nombres nuevos de las placas se aplican al arrancar.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Corré el script con sudo." >&2
	exit 1
fi

USUARIO=fw01
CLAVE_MAC='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiOsryBsQjyRwF538T0Fq1htDP+t6ywIFL0CpUwatEG macbook-joaquin'

# 1. Backup de lo que se va a pisar
BK=/root/backup-$(date +%F-%H%M)
mkdir -p "$BK"
cp -a /etc/network/interfaces /etc/nftables.conf "$BK"/
echo "Backup en $BK"

# 2. Revisar la sintaxis de nftables antes de instalar nada
nft -c -f nftables.conf
echo "nftables.conf: sintaxis OK"

# 3. SSH (antes de activar el firewall, que todavía hay salida a internet)
apt-get install -y openssh-server
install -m 644 sshd-lab.conf /etc/ssh/sshd_config.d/10-lab.conf
install -d -m 700 -o "$USUARIO" -g "$USUARIO" /home/$USUARIO/.ssh
grep -qxF "$CLAVE_MAC" /home/$USUARIO/.ssh/authorized_keys 2>/dev/null \
	|| echo "$CLAVE_MAC" >> /home/$USUARIO/.ssh/authorized_keys
chown "$USUARIO:$USUARIO" /home/$USUARIO/.ssh/authorized_keys
chmod 600 /home/$USUARIO/.ssh/authorized_keys
sshd -t
systemctl enable ssh

# 4. Nombres de las placas según la MAC
install -m 644 systemd/*.link /etc/systemd/network/
update-initramfs -u

# 5. Direcciones, reenvío y firewall
install -m 644 interfaces /etc/network/interfaces
install -m 644 99-router.conf /etc/sysctl.d/99-router.conf
install -m 755 nftables.conf /etc/nftables.conf
systemctl enable nftables

echo
echo "Listo. Reiniciá con:  sudo reboot"
echo "Si algo sale mal, lo anterior está en $BK"
