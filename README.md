# 🚀 NamyNet

**NamyNet** adalah platform manajemen **SSH, VPN, WireGuard, dan WiFi Voucher** berbasis **Node.js** yang dirancang untuk memudahkan deployment dan pengelolaan server pada **Ubuntu VPS**.

---

## ✨ Features

- ✅ One Click Installer
- ✅ Multi Server Support
- ✅ SSH Account Manager
- ✅ WireGuard Manager
- ✅ VPN Tunnel Manager
- ✅ WiFi Voucher Manager
- ✅ Dashboard Monitoring
- ✅ Real-Time WebSocket Engine
- ✅ PM2 Process Manager
- ✅ MariaDB Database
- ✅ Nginx Web Server
- ✅ Automatic Service Management

---

## 📋 Requirements

- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Root Access
- Minimal RAM 512 MB (Disarankan 1 GB+)
- Koneksi Internet Aktif

---

## 🔄 System Update (Recommended)

Sebelum menginstal **NamyNet**, sangat disarankan memperbarui sistem Ubuntu terlebih dahulu.

### Update Repository

```bash
apt update
```

### Upgrade System

```bash
apt -y upgrade
```

### Reboot VPS (Jika Diminta)

```bash
reboot
```

> **Catatan:** Untuk VPS yang baru dibuat, langkah ini sangat disarankan agar seluruh paket sistem mendapatkan pembaruan keamanan dan kompatibilitas terbaru.

---

## 📦 Installer Akan Menginstal

- Node.js 22 LTS
- NPM
- MariaDB
- PM2
- Nginx
- Git
- Curl
- Wget
- Nano
- Unzip
- WireGuard
- UFW Firewall
- Fail2Ban
- Certbot SSL

---

## ⚡ Installation

### Menggunakan Wget

```bash
wget -qO install.sh https://raw.githubusercontent.com/namydeveloper/NamyNet/main/install.sh
chmod +x install.sh
./install.sh
```

### Menggunakan Curl

```bash
curl -fsSL https://raw.githubusercontent.com/namydeveloper/NamyNet/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

---

## 📥 Download Source

**NamyNet V2**

https://raw.githubusercontent.com/namydeveloper/NamyNet/main/namynet-v2.zip

---

## 🖥️ Supported Operating System

- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS

---

## 📌 Default Ports

| Service | Port |
|----------|------|
| HTTP | 80 |
| HTTPS | 443 |
| SSH | 22 |
| Backend API | 3000 |
| WebSocket | 8899 |
| WireGuard | 51820/UDP |

---

## 🛠️ Tech Stack

- Node.js
- Express.js
- MariaDB
- PM2
- Nginx
- WireGuard
- WebSocket

---

## 📁 Repository

https://github.com/namydeveloper/NamyNet

---

## 👨‍💻 Author

**Namy Developer**

GitHub

https://github.com/namydeveloper

---

## 🤝 Contributing

Bug reports, feature requests, dan Pull Request sangat diterima.

Silakan buka **Issue** apabila menemukan bug atau ingin mengusulkan fitur baru.

---

## ⭐ Support

Apabila proyek ini bermanfaat, jangan lupa berikan **⭐ Star** pada repository GitHub.

Terima kasih atas dukungannya.

---

## ⚠️ Important

File **install.sh** harus menggunakan format **LF (Unix)**.

Apabila muncul error:

```text
cannot execute: required file not found
```

Jalankan perintah berikut:

```bash
sed -i 's/\r$//' install.sh
chmod +x install.sh
./install.sh
```

Atau ubah format file menjadi **LF (Unix)** menggunakan Visual Studio Code atau editor lainnya sebelum diunggah ke GitHub.

---

## 📄 License

Copyright © 2026 Namy Developer

All Rights Reserved.
