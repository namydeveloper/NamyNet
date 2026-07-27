#!/bin/bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   ███╗   ██╗ █████╗ ███╗   ███╗██╗   ██╗███╗   ██╗███████╗████████╗  ║"
echo "║   ████╗  ██║██╔══██╗████╗ ████║╚██╗ ██╔╝████╗  ██║██╔════╝╚══██╔══╝  ║"
echo "║   ██╔██╗ ██║███████║██╔████╔██║ ╚████╔╝ ██╔██╗ ██║█████╗     ██║     ║"
echo "║   ██║╚██╗██║██╔══██║██║╚██╔╝██║  ╚██╔╝  ██║╚██╗██║██╔══╝     ██║     ║"
echo "║   ██║ ╚████║██║  ██║██║ ╚═╝ ██║   ██║   ██║ ╚████║███████╗   ██║     ║"
echo "║   ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝   ╚═╝     ║"
echo "║                                                                      ║"
echo "║        SSH • VPN • WireGuard • WiFi Voucher Management               ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo
echo -e "${YELLOW}========================== MAIN MENU ===========================${NC}"
echo
echo -e " ${GREEN}[1]${NC} Install NamyNet"
echo -e " ${RED}[2]${NC} Uninstall NamyNet"
echo -e " ${WHITE}[3]${NC} Exit"
echo
echo -e "${YELLOW}===============================================================${NC}"
echo

read -p "Pilih Menu [1-3] : " MENU

case "$MENU" in

1)

    echo
    echo "Downloading Installer..."
    cd /tmp

    rm -f install.sh

    wget -q -O install.sh \
    https://raw.githubusercontent.com/namydeveloper/NamyNet/main/install.sh

    chmod +x install.sh

    ./install.sh

;;

2)

    echo
    echo "Downloading Uninstaller..."
    cd /tmp

    rm -f uninstall.sh

    wget -q -O uninstall.sh \
    https://raw.githubusercontent.com/namydeveloper/NamyNet/main/uninstall.sh

    chmod +x uninstall.sh

    ./uninstall.sh

;;

3)

    clear
    echo
    echo "Terima kasih telah menggunakan NamyNet."
    echo
    exit

;;

*)

    echo
    echo "Menu tidak tersedia."
    sleep 2
    exec "$0"

;;

esac
