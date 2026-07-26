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

## 🔄 System Update

Sebelum proses instalasi dimulai, installer akan:

- ✅ Menjalankan `apt update`
- ✅ Meminta konfirmasi sebelum menjalankan `apt upgrade`

Hal ini memberikan pilihan kepada pengguna untuk melakukan upgrade sistem, terutama jika VPS sudah digunakan sebelumnya.

Untuk VPS baru, sangat disarankan memilih **Yes** agar seluruh paket sistem mendapatkan pembaruan keamanan terbaru.

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

- File **install.sh** harus menggunakan format **LF (Unix)**.
- Jangan gunakan format **CRLF (Windows)** karena dapat menyebabkan error:

```text
cannot execute: required file not found
```

Apabila file sudah terlanjur menggunakan format CRLF, jalankan:

```bash
sed -i 's/\r$//' install.sh
chmod +x install.sh
./install.sh
```

---

## 📄 License

Copyright © 2026 Namy Developer

All Rights Reserved.
