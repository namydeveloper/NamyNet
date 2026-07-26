#!/bin/bash

# =====================================================
# NAMYNET INSTALLER V4
# Ubuntu 22.04 / 24.04
# NodeJS 22 LTS
# MariaDB
# Nginx
# PM2
# WireGuard
# =====================================================

set -e

clear

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[36m"
RESET="\e[0m"

echo -e "${BLUE}"
echo "===================================================="
echo "              NAMYNET INSTALLER V4"
echo "===================================================="
echo -e "${RESET}"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
fi

OS=$(lsb_release -rs)

if [[ "$OS" != "22.04" && "$OS" != "24.04" ]]; then
    echo "Ubuntu $OS tidak didukung."
    exit
fi

echo
echo "===================================================="
echo "Server Configuration"
echo "===================================================="

read -p "Masukkan Domain / IP : " SERVER

while [[ -z "$SERVER" ]]; do
read -p "Domain / IP tidak boleh kosong : " SERVER
done

echo

read -p "Nama Database [wifi_voucher] : " DB_NAME
DB_NAME=${DB_NAME:-wifi_voucher}

read -p "User Database [root] : " DB_USER
DB_USER=${DB_USER:-root}

read -s -p "Password Database : " DB_PASS
echo

echo
read -p "Install SSL (y/n) : " INSTALL_SSL

echo
echo "===================================================="
echo "Konfirmasi"
echo "===================================================="

echo "Server      : $SERVER"
echo "Database    : $DB_NAME"
echo "DB User     : $DB_USER"
echo "Install SSL : $INSTALL_SSL"

echo

read -p "Lanjutkan Instalasi ? (y/n) : " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
exit
fi

clear

echo
echo "[1/18] Update Repository..."

apt update

echo
echo "[2/18] Upgrade System..."

apt -y upgrade

echo
echo "[3/18] Install Basic Package..."

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
apt-transport-https \
lsb-release \
net-tools \
iptables \
ufw \
fail2ban \
certbot \
python3-certbot-nginx

echo
echo "[4/18] Install NodeJS 22..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
| gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
> /etc/apt/sources.list.d/nodesource.list

apt update

apt install -y nodejs

echo
echo "[5/18] Install PM2..."

npm install -g pm2

echo
echo "[6/18] Install MariaDB..."

apt install -y mariadb-server mariadb-client

systemctl enable mariadb
systemctl restart mariadb

echo
echo "[7/18] Install Nginx..."

apt install -y nginx

systemctl enable nginx
systemctl restart nginx

echo
echo "[8/18] Install WireGuard..."

apt install -y wireguard wireguard-tools

echo
echo "[9/18] Configure Firewall..."

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 51820/udp

ufw --force enable

systemctl enable fail2ban
systemctl restart fail2ban

echo
echo "[10/18] Enable IP Forward..."

grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || \
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sysctl -p

echo
echo "[11/18] Configure Timezone..."

timedatectl set-timezone Asia/Jakarta || true
echo
echo "[12/18] Configure WireGuard..."

mkdir -p /etc/wireguard

chmod 700 /etc/wireguard

SERVER_PRIVATE=$(wg genkey)

SERVER_PUBLIC=$(echo "$SERVER_PRIVATE" | wg pubkey)

NIC=$(ip route | awk '/default/ {print $5}' | head -n1)

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.100.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIVATE

PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o $NIC -j MASQUERADE

PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o $NIC -j MASQUERADE
EOF

chmod 600 /etc/wireguard/wg0.conf

systemctl enable wg-quick@wg0

systemctl restart wg-quick@wg0

echo
echo "[13/18] Download NamyNet..."

cd /opt

rm -f namynet-v2.zip

wget -O namynet-v2.zip https://github.com/namydeveloper/NamyNet/raw/main/namynet-v2.zip

echo
echo "[14/18] Extract Package..."

unzip -o namynet-v2.zip

echo
echo "[15/18] Install Backend..."

cd /opt/wifi-voucher/backend

npm install

echo
echo "[16/18] Restore Database..."

if [ -f "/opt/wifi_voucher.sql" ]; then

mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /opt/wifi_voucher.sql

echo "Database Restored."

else

echo "wifi_voucher.sql not found. Skip."

fi
echo
echo "[17/18] Configure Nginx..."

cat > /etc/nginx/sites-available/namynet <<EOF
server {

    listen 80;

    server_name $SERVER;

    root /opt/wifi-voucher/frontend;
    index index.html index.htm;

    location / {

        try_files \$uri \$uri/ /index.html;

    }

    location /api/ {

        proxy_pass http://127.0.0.1:3000/api/;

        proxy_http_version 1.1;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

    }

    location /ws/ {

        proxy_pass http://127.0.0.1:8880;

        proxy_http_version 1.1;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

    }

}
EOF

rm -f /etc/nginx/sites-enabled/default

ln -sf /etc/nginx/sites-available/namynet /etc/nginx/sites-enabled/namynet

nginx -t

systemctl restart nginx

echo
echo "[18/18] Start Services..."

cd /opt/wifi-voucher/backend

pm2 delete all >/dev/null 2>&1 || true

pm2 start app.js --name namynet

pm2 save

pm2 startup systemd -u root --hp /root >/tmp/pm2_startup.txt

bash <(grep "sudo" /tmp/pm2_startup.txt | sed 's/sudo //') || true

systemctl restart mariadb
systemctl restart nginx
systemctl restart wg-quick@wg0 || true

if [[ "$INSTALL_SSL" == "y" || "$INSTALL_SSL" == "Y" ]]; then

echo
echo "Installing SSL..."

certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email -d $SERVER || true

fi

echo
echo "Cleaning..."

apt autoremove -y

apt autoclean

clear

echo "======================================================="
echo "            NAMYNET INSTALL SUCCESS"
echo "======================================================="
echo
echo "Server        : $SERVER"
echo
echo "Frontend      : http://$SERVER"
echo "Backend API   : http://$SERVER/api"
echo "WebSocket     : ws://$SERVER/ws"
echo
echo "======================================================="
echo "Versions"
echo "======================================================="
echo "Ubuntu        : $(lsb_release -ds)"
echo "Kernel        : $(uname -r)"
echo "NodeJS        : $(node -v)"
echo "NPM           : $(npm -v)"
echo "PM2           : $(pm2 -v | tail -1)"
echo "MariaDB       : $(mariadb --version)"
echo "Nginx         : $(nginx -v 2>&1)"
echo "WireGuard     : $(wg --version | head -1)"
echo
echo "======================================================="
echo "Service Status"
echo "======================================================="
echo "MariaDB       : $(systemctl is-active mariadb)"
echo "Nginx         : $(systemctl is-active nginx)"
echo "PM2           : Online"
echo "WireGuard     : $(systemctl is-active wg-quick@wg0)"
echo
echo "======================================================="
echo "WireGuard"
echo "======================================================="
echo "Port          : 51820"
echo "VPN Network   : 10.100.0.0/24"
echo
echo "======================================================="
echo "NamyNet Server Ready"
echo "======================================================="
echo
echo "Default Folder"
echo "/opt/wifi-voucher"
echo
echo "Backend"
echo "/opt/wifi-voucher/backend"
echo
echo "Frontend"
echo "/opt/wifi-voucher/frontend"
echo
echo "WebSocket"
echo "/opt/wifi-voucher/backend/websocket"
echo
echo "WireGuard"
echo "/etc/wireguard/wg0.conf"
echo
echo "======================================================="
echo "Installation Finished"
echo "======================================================="
