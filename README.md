# 🚀 NamyNet WiFi Voucher

Aplikasi manajemen Hotspot MikroTik berbasis **Node.js + React + MariaDB**.

---

# Fitur

- Login Admin
- Dashboard
- Manajemen Router MikroTik
- Manajemen Paket Hotspot
- Generate Voucher
- Hapus Voucher
- Sinkron dengan MikroTik
- Print Voucher
- Multi Router
- API Backend
- React Frontend

---

# Requirement

- Ubuntu 22.04 / 24.04
- NodeJS 22 LTS
- NPM
- MariaDB 10.6+
- PM2
- Nginx
- Git
- Unzip

---

# Install Dependency

Update Server

```bash
apt update && apt upgrade -y
```

Install Dependency

```bash
apt install -y git curl wget unzip nginx software-properties-common
```

---

# Install NodeJS 22

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
```

Cek

```bash
node -v
npm -v
```

---

# Install PM2

```bash
npm install -g pm2
```

---

# Install MariaDB

```bash
apt install mariadb-server mariadb-client -y
```

Enable

```bash
systemctl enable mariadb
systemctl start mariadb
```

Secure Installation

```bash
mysql_secure_installation
```

Login

```bash
mysql -u root -p
```

---

# Membuat Database

```sql
CREATE DATABASE wifi_voucher;
EXIT;
```

---

# Import Database

Masuk folder project

```bash
cd /opt/wifi-voucher/database
```

Import

```bash
mysql -u root -p wifi_voucher < wifi_voucher.sql
```

---

# Download Project

Masuk Folder

```bash
cd /opt
```

Download

```bash
wget -O wifi-voucher.zip https://github.com/namydeveloper/NamyNet/raw/main/wifi-voucher.zip
```

Jika wget belum tersedia

```bash
curl -L -o wifi-voucher.zip https://github.com/namydeveloper/NamyNet/raw/main/wifi-voucher.zip
```

Extract

```bash
unzip wifi-voucher.zip
```

Masuk Folder

```bash
cd /opt/wifi-voucher
```

---

# Install Backend

```bash
cd backend

npm install
```

---

# Install Frontend

```bash
cd ../frontend

npm install
```

Build

```bash
npm run build
```

---

# Konfigurasi Backend

Edit file

```
backend/.env
```

Contoh

```env
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password
DB_NAME=wifi_voucher

JWT_SECRET=namynet_secret_key
```

---

# Menjalankan Backend

```bash
cd /opt/wifi-voucher/backend

npm start
```

atau

```bash
pm2 start server.js --name namynet-backend
```

---

# PM2 Auto Start

```bash
pm2 save
pm2 startup
```

Ikuti perintah yang diberikan PM2 lalu jalankan kembali

```bash
pm2 save
```

---

# Konfigurasi Nginx

Contoh

```nginx
server {

    listen 80;

    server_name _;

    root /opt/wifi-voucher/frontend/dist;

    index index.html;

    location / {

        try_files $uri /index.html;

    }

    location /api {

        proxy_pass http://127.0.0.1:3000;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;

        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;

    }

}
```

Restart

```bash
systemctl restart nginx
```

---

# Firewall

```bash
ufw allow 22
ufw allow 80
ufw allow 443

ufw enable
```

---

# Struktur Folder

```
wifi-voucher/

├── backend/
├── frontend/
├── database/
├── docs/
├── nginx/
├── logs/
└── backup/
```

---

# Update Project

Download versi terbaru

```bash
cd /opt

rm -rf wifi-voucher

rm wifi-voucher.zip

wget -O wifi-voucher.zip https://github.com/namydeveloper/NamyNet/raw/main/wifi-voucher.zip

unzip wifi-voucher.zip
```

Install kembali

```bash
cd /opt/wifi-voucher/backend

npm install

cd ../frontend

npm install

npm run build
```

Restart

```bash
pm2 restart all

systemctl restart nginx
```

---

# Backup Database

```bash
mysqldump -u root -p wifi_voucher > backup.sql
```

Restore

```bash
mysql -u root -p wifi_voucher < backup.sql
```

---

# Cek Status

PM2

```bash
pm2 list
```

MariaDB

```bash
systemctl status mariadb
```

Nginx

```bash
systemctl status nginx
```

Backend

```bash
curl http://127.0.0.1:3000
```

---

# Default Login

```
Username : admin
Password : admin123
```

> Ubah password setelah instalasi pertama.

---

# MikroTik

- RouterOS v6
- RouterOS v7
- API Service Enabled
- Hotspot Active

---

# Developer

Namy Developer

---

# License

MIT License
