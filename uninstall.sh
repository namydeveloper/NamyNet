#!/bin/bash

set -e

echo "======================================="
echo "     NAMYNET UNINSTALLER V1"
echo "======================================="

if [ "$EUID" -ne 0 ]; then
    echo "Jalankan sebagai root."
    exit 1
fi

read -p "Yakin ingin menghapus NamyNet? (y/N): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    exit
fi

echo "[1/12] Stop PM2..."
pm2 delete namynet >/dev/null 2>&1 || true
pm2 save --force >/dev/null 2>&1 || true

echo "[2/12] Remove Database..."

if command -v mysql >/dev/null 2>&1; then

    systemctl start mariadb >/dev/null 2>&1 || true

    mysql -uroot <<EOF || true
DROP DATABASE IF EXISTS wifi_voucher;
DROP USER IF EXISTS 'wifi_voucher'@'localhost';
FLUSH PRIVILEGES;
EOF

fi

echo "[3/12] Stop Services..."

systemctl stop nginx >/dev/null 2>&1 || true
systemctl stop mariadb >/dev/null 2>&1 || true
systemctl stop wg-quick@wg0 >/dev/null 2>&1 || true

echo "[4/12] Disable WireGuard..."

systemctl disable wg-quick@wg0 >/dev/null 2>&1 || true

echo "[5/12] Remove Project..."

rm -rf /opt/wifi-voucher
rm -f /opt/wifi_voucher.sql
rm -f /opt/namynet-v2.zip
rm -f /opt/.namynet_checkpoint

echo "[6/12] Remove Nginx Config..."

rm -f /etc/nginx/sites-enabled/namynet
rm -f /etc/nginx/sites-available/namynet

echo "[7/12] Remove SSL..."

rm -rf /etc/letsencrypt/live/namystore.com
rm -rf /etc/letsencrypt/archive/namystore.com
rm -f /etc/letsencrypt/renewal/namystore.com.conf

echo "[8/12] Remove WireGuard..."

rm -rf /etc/wireguard

echo "[9/12] Remove Packages..."

apt purge -y \
wireguard \
wireguard-tools \
mariadb-server \
mariadb-client \
nginx \
certbot \
python3-certbot-nginx \
fail2ban || true

echo "[10/12] Remove PM2 & NodeJS..."

npm uninstall -g pm2 >/dev/null 2>&1 || true

rm -rf /root/.pm2
rm -f /etc/systemd/system/pm2-root.service

systemctl daemon-reload >/dev/null 2>&1 || true

echo "Removing NodeJS..."

apt purge -y nodejs npm >/dev/null 2>&1 || true

rm -rf /usr/lib/node_modules
rm -rf /usr/local/lib/node_modules
rm -rf /root/.npm
rm -rf ~/.npm

echo "Removing NodeSource Repository..."

rm -f /etc/apt/keyrings/nodesource.gpg
rm -f /etc/apt/sources.list.d/nodesource.list

echo "[11/12] Cleanup..."

apt autoremove -y
apt autoclean

echo "[12/12] Done"

echo
echo "======================================="
echo " NAMYNET BERHASIL DIHAPUS"
echo "======================================="