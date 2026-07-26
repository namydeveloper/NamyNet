#!/bin/bash

# ==========================================
# NAMYNET INSTALLER V3
# Ubuntu 22.04 / 24.04
# ==========================================

set -e

clear

echo "==========================================="
echo "         NAMYNET INSTALLER V3"
echo "==========================================="
echo

if [ "$EUID" -ne 0 ]; then
    echo "Silakan jalankan sebagai root."
    exit 1
fi

echo "Masukkan informasi server"
echo "-------------------------------------------"

read -p "IP atau Domain : " SERVER

while [[ -z "$SERVER" ]]; do
    read -p "IP atau Domain tidak boleh kosong : " SERVER
done

echo
read -p "Nama Database [wifi_voucher] : " DB_NAME
DB_NAME=${DB_NAME:-wifi_voucher}

read -p "User Database [root] : " DB_USER
DB_USER=${DB_USER:-root}

read -s -p "Password Database : " DB_PASS
echo

echo
read -p "Install WireGuard? (y/n) : " INSTALL_WG
read -p "Install SSL Certbot? (y/n) : " INSTALL_SSL
read -p "Restore Database? (y/n) : " RESTORE_DB

echo
echo "==========================================="
echo "Konfirmasi Instalasi"
echo "==========================================="
echo "Server            : $SERVER"
echo "Database          : $DB_NAME"
echo "DB User           : $DB_USER"
echo "WireGuard         : $INSTALL_WG"
echo "SSL               : $INSTALL_SSL"
echo "Restore Database  : $RESTORE_DB"
echo "==========================================="
echo

read -p "Lanjutkan instalasi? (y/n) : " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Instalasi dibatalkan."
    exit 0
fi

echo
echo "[1/12] Update System..."
apt update
apt upgrade -y

echo
echo "[2/12] Install Package..."
apt install -y \
curl \
wget \
git \
nano \
unzip \
zip \
htop \
build-essential \
software-properties-common \
ca-certificates \
gnupg \
mariadb-server \
mariadb-client \
nginx \
ufw \
fail2ban \
certbot \
python3-certbot-nginx

echo
echo "[3/12] Install NodeJS 22..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list

apt update
apt install -y nodejs

echo
echo "[4/12] Install PM2..."
npm install -g pm2

echo
echo "[5/12] Download NamyNet..."

cd /opt

wget -O namynet-v2.zip https://github.com/namydeveloper/NamyNet/raw/main/namynet-v2.zip

unzip -o namynet-v2.zip

echo
echo "[6/12] Install NPM..."

cd /opt/wifi-voucher/backend

npm install

echo
echo "[7/12] Configure Firewall..."

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp

if [[ "$INSTALL_WG" == "y" || "$INSTALL_WG" == "Y" ]]; then

    apt install -y wireguard wireguard-tools

    ufw allow 51820/udp

fi

ufw --force enable

echo
echo "[8/12] Configure Nginx..."

echo "Server : $SERVER"

# nanti otomatis membuat server_name = $SERVER

echo
echo "[9/12] Restore Database..."

if [[ "$RESTORE_DB" == "y" || "$RESTORE_DB" == "Y" ]]; then

    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /opt/wifi_voucher.sql

fi

echo
echo "[10/12] Install SSL..."

if [[ "$INSTALL_SSL" == "y" || "$INSTALL_SSL" == "Y" ]]; then

    certbot --nginx -d "$SERVER"

fi

echo
echo "[11/12] Restart Service..."

systemctl restart mariadb
systemctl restart nginx

pm2 restart all || true

echo
echo "[12/12] Finish"

echo
echo "==========================================="
echo "        NAMYNET INSTALLED"
echo "==========================================="
echo "Server     : $SERVER"
echo "Frontend   : http://$SERVER"
echo "API        : http://$SERVER/api"
echo "NodeJS     : $(node -v)"
echo "PM2        : $(pm2 -v | tail -1)"
echo "==========================================="