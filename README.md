# 🚀 NamyNet

<div align="center">

# NamyNet

**All-in-One SSH, VPN, WireGuard & WiFi Voucher Management Platform**

Node.js • MariaDB • Nginx • PM2 • WireGuard • Ubuntu

</div>

---

## ✨ Overview

**NamyNet** adalah platform manajemen **SSH Account, VPN Tunnel, WireGuard, dan WiFi Voucher** berbasis **Node.js** yang dirancang untuk memudahkan deployment, monitoring, dan pengelolaan server pada VPS Ubuntu.

NamyNet menyediakan **One Click Installer** yang akan menginstal seluruh komponen yang dibutuhkan secara otomatis sehingga server siap digunakan hanya dalam beberapa menit.

---

# ✨ Features

* ✅ One Click Installer
* ✅ Ubuntu 22.04 & 24.04 Support
* ✅ Multi Server Management
* ✅ SSH Account Manager
* ✅ WireGuard Manager
* ✅ VPN Tunnel Manager
* ✅ WiFi Voucher Manager
* ✅ Dashboard Monitoring
* ✅ Real-Time WebSocket Engine
* ✅ PM2 Process Manager
* ✅ MariaDB Database
* ✅ Nginx Web Server
* ✅ Automatic Service Management
* ✅ Firewall Configuration (UFW)
* ✅ Fail2Ban Protection
* ✅ Automatic SSL (Let's Encrypt)
* ✅ WireGuard Backup & Restore
* ✅ VPS Migration Ready

---

# 📋 Requirements

* Ubuntu 22.04 LTS
* Ubuntu 24.04 LTS
* Root Access
* Internet Connection
* Minimum RAM 512 MB
* Recommended RAM 1 GB+

---

# 🔄 Recommended System Update

Sebelum menjalankan installer, lakukan update sistem terlebih dahulu.

```bash
apt update && apt upgrade -y
```

Apabila kernel diperbarui, lakukan reboot.

```bash
reboot
```

---

# 📦 Installer Will Automatically Install

* Node.js 22 LTS
* NPM
* MariaDB
* PM2
* Nginx
* Git
* Curl
* Wget
* Nano
* Zip
* Unzip
* WireGuard
* UFW Firewall
* Fail2Ban
* Certbot SSL
* Build Essential
* Network Utilities

# ⚡ Installation

Install NamyNet hanya dengan satu perintah.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/namydeveloper/NamyNet/main/namynet.sh)
```

Installer akan menampilkan menu:

```text
==========================================
          NAMYNET MANAGER
==========================================

1. Install NamyNet
2. Uninstall NamyNet
3. Exit
```

Pilih menu yang diinginkan, kemudian ikuti proses instalasi.

---

# 🗄️ Default Database

Saat installer meminta konfigurasi database, gunakan contoh berikut.

| Item     | Value        |
| -------- | ------------ |
| Database | wifi_voucher |
| Username | namynet      |
| Password | namynet123   |

---

# 🔧 Database Recovery

Apabila muncul pesan:

```text
Access denied for user 'namynet'@'localhost'
```

jalankan:

```bash
sudo mariadb <<'EOF'
CREATE DATABASE IF NOT EXISTS wifi_voucher;

CREATE USER IF NOT EXISTS 'namynet'@'localhost'
IDENTIFIED BY 'namynet123';

ALTER USER 'namynet'@'localhost'
IDENTIFIED BY 'namynet123';

GRANT ALL PRIVILEGES
ON wifi_voucher.*
TO 'namynet'@'localhost';

FLUSH PRIVILEGES;
EOF
```

---

# 🌐 WireGuard

Installer akan menanyakan:

```text
Domain WireGuard [wg.namystore.com]:
```

Jika menggunakan domain default:

```
wg.namystore.com
```

cukup tekan **Enter**.

---

# 📥 Download Source

```
https://raw.githubusercontent.com/namydeveloper/NamyNet/main/namynet-v2.zip
```

---

# 🖥️ Supported Operating System

* Ubuntu 22.04 LTS
* Ubuntu 24.04 LTS

---

# 🌐 Default Ports

| Service     | Port      |
| ----------- | --------- |
| HTTP        | 80        |
| HTTPS       | 443       |
| SSH         | 22        |
| Backend API | 3000      |
| WebSocket   | 8899      |
| WireGuard   | 51820/UDP |
| MariaDB     | 3306      |

---

# 🛠️ Tech Stack

* Node.js
* Express.js
* MariaDB
* PM2
* Nginx
* WireGuard
* WebSocket
* HTML5
* CSS3
* JavaScript

---

# 📁 Project Structure

```
/opt/wifi-voucher
├── backend
├── frontend
├── websocket
├── database
└── logs
```

---

# 🔐 Security

* UFW Firewall
* Fail2Ban
* SSL Let's Encrypt
* WireGuard VPN
* PM2 Auto Restart

---

# 🚀 VPS Migration

NamyNet mendukung migrasi VPS menggunakan fitur **WireGuard Backup & Restore**, sehingga proses perpindahan server menjadi lebih mudah tanpa perlu membuat konfigurasi WireGuard dari awal.

---

# ⚠️ Important

Apabila file installer menggunakan format **CRLF (Windows)** dan muncul pesan:

```text
cannot execute: required file not found
```

jalankan:

```bash
sed -i 's/\r$//' install.sh
chmod +x install.sh
./install.sh
```

---

# 🤝 Contributing

Bug Report, Feature Request, dan Pull Request sangat diterima.

Silakan buat **Issue** apabila menemukan bug atau ingin mengusulkan fitur baru.

---

# ⭐ Support

Apabila proyek ini bermanfaat, jangan lupa memberikan **⭐ Star** pada repository GitHub.

Terima kasih atas dukungannya.

---

# 👨‍💻 Author

**Namy Developer**

GitHub

https://github.com/namydeveloper

---

# 📄 License

Copyright © 2026 Namy Developer

All Rights Reserved.
