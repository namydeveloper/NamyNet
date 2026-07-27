#!/bin/bash

clear

echo "========================================"
echo "         NAMYNET MANAGER V1"
echo "========================================"
echo
echo "1. Install NamyNet"
echo "2. Uninstall NamyNet"
echo "3. Exit"
echo

read -p "Pilih Menu [1-3] : " MENU

case $MENU in

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

    exit

;;

*)

    echo "Menu tidak tersedia."

;;

esac