#!/bin/bash

# ==========================================
# NAMYNET SERVER INSTALLER V2
# Ubuntu 22.04 / 24.04
# ==========================================

set -e

clear

echo "==========================================="
echo "      NAMYNET SERVER INSTALLER V2"
echo "==========================================="

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

echo
echo "[1/13] Updating System..."
apt update
apt -y upgrade

echo
echo "[2/13] Installing Basic Packages..."
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
lsb-release

echo
echo "[3/13] Installing NodeJS 22 LTS..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
| gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
> /etc/apt/sources.list.d/nodesource.list

apt update
apt install -y nodejs

echo
echo "[4/13] Installing PM2..."
npm install -g pm2

echo
echo "[5/13] Installing MariaDB..."
apt install -y mariadb-server mariadb-client

systemctl enable mariadb
systemctl restart mariadb

echo
echo "[6/13] Installing Nginx..."
apt install -y nginx

systemctl enable nginx
systemctl restart nginx

echo
echo "[7/13] Installing WireGuard..."
apt install -y wireguard wireguard-tools

echo
echo "[8/13] Installing Security Packages..."
apt install -y \
ufw \
fail2ban \
certbot \
python3-certbot-nginx

systemctl enable fail2ban
systemctl restart fail2ban

echo
echo "[9/13] Configuring Firewall..."

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 51820/udp

ufw --force enable

echo
echo "[10/13] Enable IP Forward..."

grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || \
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sysctl -p

echo
echo "[11/13] Configure Timezone..."

timedatectl set-timezone Asia/Jakarta || true

echo
echo "[12/13] Cleaning..."

apt autoremove -y
apt autoclean

echo
echo "[13/13] Installation Summary"

echo
echo "==========================================="
echo "           INSTALL SUCCESS"
echo "==========================================="

echo "OS          : $(lsb_release -ds)"
echo "Kernel      : $(uname -r)"
echo "NodeJS      : $(node -v)"
echo "NPM         : $(npm -v)"
echo "PM2         : $(pm2 -v | tail -1)"
echo "MariaDB     : $(mariadb --version)"
echo "Nginx       : $(nginx -v 2>&1)"
echo "Git         : $(git --version)"
echo "WireGuard   : $(wg --version | head -1)"
echo

systemctl is-active mariadb >/dev/null && echo "MariaDB     : Running"
systemctl is-active nginx >/dev/null && echo "Nginx       : Running"
systemctl is-active fail2ban >/dev/null && echo "Fail2Ban    : Running"

echo
echo "==========================================="
echo " Server Ready For NamyNet Deployment"
echo "==========================================="