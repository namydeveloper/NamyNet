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

# ==========================================
# CHECKPOINT
# ==========================================

CHECKPOINT="/opt/.namynet_checkpoint"

step_done() {
    echo "$1" >> "$CHECKPOINT"
}

step_ok() {
    grep -Fxq "$1" "$CHECKPOINT" 2>/dev/null
}

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

read -p "Domain WireGuard [wg.namystore.com] : " WG_DOMAIN
WG_DOMAIN=${WG_DOMAIN:-wg.namystore.com}

echo
echo "===================================================="
echo "WireGuard Configuration"
echo "===================================================="

echo "1. Generate New Configuration"
echo "2. Restore Existing Configuration"

read -p "Pilih [1/2] : " WG_MODE

while [[ "$WG_MODE" != "1" && "$WG_MODE" != "2" ]]; do
    read -p "Pilih 1 atau 2 : " WG_MODE
done


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
echo "WireGuard   : $WG_DOMAIN"
echo "Database    : $DB_NAME"
echo "DB User     : $DB_USER"
echo "Install SSL : $INSTALL_SSL"

echo

read -p "Lanjutkan Instalasi ? (y/n) : " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
exit
fi

touch "$CHECKPOINT"

clear

if ! step_ok UPDATE; then

echo "[1/18] Update Repository..."

apt update

step_done UPDATE

else

echo "[1/18] Update Repository... SKIP"

fi

if ! step_ok UPGRADE; then

echo "[2/18] Upgrade System..."

apt -y upgrade

step_done UPGRADE

else

echo "[2/18] Upgrade System... SKIP"

fi

echo
if ! step_ok PACKAGE; then

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

step_done PACKAGE

else

echo "[3/18] Install Basic Package... SKIP"

fi

echo
if ! step_ok NODEJS; then

echo "[4/18] Install NodeJS..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
| gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
> /etc/apt/sources.list.d/nodesource.list

apt update

apt install -y nodejs

step_done NODEJS

else

echo "[4/18] Install NodeJS... SKIP"

fi

if ! step_ok PM2; then

echo "[5/18] Install PM2..."

npm install -g pm2

step_done PM2

else

echo "[5/18] Install PM2... SKIP"

fi

echo

if ! step_ok MARIADB; then

echo "[6/18] Install MariaDB..."

apt install -y mariadb-server mariadb-client

systemctl enable mariadb
systemctl restart mariadb

step_done MARIADB

else

echo "[6/18] Install MariaDB... SKIP"

fi

echo

if ! step_ok NGINX; then

echo "[7/18] Install Nginx..."

apt install -y nginx

systemctl enable nginx
systemctl restart nginx

step_done NGINX

else

echo "[7/18] Install Nginx... SKIP"

fi

echo

if ! step_ok WIREGUARD; then

echo "[8/18] Install WireGuard..."

apt install -y wireguard wireguard-tools

step_done WIREGUARD

else

echo "[8/18] Install WireGuard... SKIP"

fi

echo

if ! step_ok FIREWALL; then

echo "[9/18] Configure Firewall..."

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 51820/udp

ufw --force enable

systemctl enable fail2ban
systemctl restart fail2ban

step_done FIREWALL

else

echo "[9/18] Configure Firewall... SKIP"

fi

echo

if ! step_ok IPFORWARD; then

echo "[10/18] Enable IP Forward..."

grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || \
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sysctl -p

step_done IPFORWARD

else

echo "[10/18] Enable IP Forward... SKIP"

fi

echo

if ! step_ok TIMEZONE; then

echo "[11/18] Configure Timezone..."

timedatectl set-timezone Asia/Jakarta || true

step_done TIMEZONE

else

echo "[11/18] Configure Timezone... SKIP"

fi

echo

if ! step_ok WGCONFIG; then

echo "[12/18] Configure WireGuard..."

mkdir -p /etc/wireguard

chmod 700 /etc/wireguard

if [[ "$WG_MODE" == "2" ]]; then

    echo
    echo "Downloading WireGuard Backup..."

    wget -q -O /tmp/namynet-wg0.conf \
    https://raw.githubusercontent.com/namydeveloper/NamyNet/main/namynet-wg0.conf

    if [ $? -ne 0 ]; then
        echo "Download WireGuard Backup gagal!"
        exit 1
    fi

    if [ ! -s /tmp/namynet-wg0.conf ]; then
        echo "Backup WireGuard kosong!"
        exit 1
    fi

    if ! grep -q "^\[Interface\]" /tmp/namynet-wg0.conf; then
    echo "File backup WireGuard tidak valid!"
    exit 1
fi

    SERVER_PRIVATE=$(grep "^PrivateKey" /tmp/namynet-wg0.conf | cut -d'=' -f2- | tr -d '\r' | xargs)
	if [ -z "$SERVER_PRIVATE" ]; then
    echo "PrivateKey tidak ditemukan pada backup!"
    exit 1
fi
    SERVER_PUBLIC=$(echo "$SERVER_PRIVATE" | wg pubkey)

else

    SERVER_PRIVATE=$(wg genkey)
    SERVER_PUBLIC=$(echo "$SERVER_PRIVATE" | wg pubkey)

fi

NIC=$(ip route | awk '/default/ {print $5}' | head -n1)

if [[ "$WG_MODE" == "2" ]]; then

    cp /tmp/namynet-wg0.conf /etc/wireguard/wg0.conf

    sed -i "s/-o eth0 /-o $NIC /g" /etc/wireguard/wg0.conf

else

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 172.31.100.1/24
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

fi

chmod 600 /etc/wireguard/wg0.conf

systemctl enable wg-quick@wg0

systemctl restart wg-quick@wg0

step_done WGCONFIG

else

echo "[12/18] Configure WireGuard... SKIP"

fi

echo

if ! step_ok DOWNLOAD; then

echo "[13/18] Download NamyNet..."

cd /opt

rm -f namynet-v2.zip

wget -O namynet-v2.zip https://github.com/namydeveloper/NamyNet/raw/main/namynet-v2.zip

step_done DOWNLOAD

else

echo "[13/18] Download NamyNet... SKIP"

fi

echo

if ! step_ok UNZIP; then

echo "[14/18] Extract Package..."

unzip -o namynet-v2.zip

step_done UNZIP

else

echo "[14/18] Extract Package... SKIP"

fi

echo

if ! step_ok BACKEND; then

echo "[15/18] Install Backend..."

cd /opt/wifi-voucher/backend

npm install

step_done BACKEND

else

echo "[15/18] Install Backend... SKIP"

fi

echo

if ! step_ok DATABASE; then

echo "[16/18] Restore Database..."

if [ -f "/opt/wifi_voucher.sql" ]; then

echo "Creating Database..."

if [ -z "$DB_PASS" ]; then

mysql -u "$DB_USER" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
EOF

else

mysql -u "$DB_USER" -p"$DB_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
EOF

fi

echo "Restoring Database..."

if [ -z "$DB_PASS" ]; then

mysql -u "$DB_USER" "$DB_NAME" < /opt/wifi_voucher.sql

else

mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /opt/wifi_voucher.sql

fi

echo "Database Restored."

echo "Creating Database User..."

if [ "$DB_USER" != "root" ]; then

mysql -u root <<EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost'
IDENTIFIED BY '$DB_PASS';

GRANT ALL PRIVILEGES
ON \`$DB_NAME\`.*
TO '$DB_USER'@'localhost';

FLUSH PRIVILEGES;
EOF

fi

if [ -z "$DB_PASS" ]; then

    TABLE_COUNT=$(mysql -N -B -u "$DB_USER" "$DB_NAME" -e "SHOW TABLES;" | wc -l)

else

    TABLE_COUNT=$(mysql -N -B -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;" | wc -l)

fi

echo "Tables : $TABLE_COUNT"

if [ "$TABLE_COUNT" -eq 0 ]; then
    echo "Restore Database Failed!"
    exit 1
fi

else

echo "wifi_voucher.sql not found."

fi

step_done DATABASE

else

echo "[16/18] Restore Database... SKIP"

fi

echo

if ! step_ok NGINXCONFIG; then

echo "[17/18] Configure Nginx..."

cat > /etc/nginx/sites-available/namynet <<EOF
server {

    listen 80;

    server_name $SERVER;

    root /opt/wifi-voucher/frontend;
    index login.html login.htm;

    location / {

        try_files \$uri \$uri/ /login.html;

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

        proxy_pass http://127.0.0.1:8899;

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

step_done NGINXCONFIG

else

echo "[17/18] Configure Nginx... SKIP"

fi

echo

if ! step_ok SERVICES; then

echo "[18/18] Start Services..."

cd /opt/wifi-voucher/backend

pm2 delete namynet >/dev/null 2>&1 || true

pm2 start app.js --name namynet

sleep 3

curl http://127.0.0.1:3000 >/dev/null 2>&1 || {

    echo
    echo "Backend Failed!"
    exit 1

}

pm2 save

pm2 startup systemd -u root --hp /root >/tmp/pm2_startup.txt

bash <(grep "sudo" /tmp/pm2_startup.txt | sed 's/sudo //') || true

systemctl restart mariadb
systemctl restart nginx
nginx -t || exit 1
systemctl restart wg-quick@wg0 || true

if [[ "$INSTALL_SSL" == "y" || "$INSTALL_SSL" == "Y" ]]; then

echo
echo "Installing SSL..."

certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email -d $SERVER || true

fi

step_done SERVICES

else

echo "[18/18] Start Services... SKIP"

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
echo "Endpoint      : $WG_DOMAIN:51820"
echo "Port          : 51820"
echo "VPN Network   : 172.31.100.0/24"
echo "Server VPN    : 172.31.100.1"
echo "Router VPN    : 172.31.100.2"
echo
echo "Public Key"
echo "$SERVER_PUBLIC"
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
rm -f "$CHECKPOINT"
echo "======================================================="
echo "Installation Finished"
echo "======================================================="
