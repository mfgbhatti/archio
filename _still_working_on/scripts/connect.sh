#!/usr/bin/env bash
menu () {
echo -ne "
        .o.                          oooo         o8o            
       .888.                         '888         '''            
      .8'888.     oooo d8b  .ooooo.   888 .oo.   oooo   .ooooo.  
     .8' '888.    '888''8P d88' ''Y8  888P'Y88b  '888  d88' '88b 
    .88ooo8888.    888     888        888   888   888  888   888 
   .8'     '888.   888     888   .o8  888   888   888  888   888 
   88o     o8888o d888b    'Y8bod8P' o888o o888o o888o 'Y8bod8P' 
-----------------------------------------------------------------
    Please select you interface and connect to internet
-----------------------------------------------------------------
    1)      Wifi
    2)      Other

    0)      Main menu

Choose an option:
"
read interface
case $interface in
    1) 
    iwctl device list
    echo "Select interface for connecting:"
    read wlan
    iwctl station $wlan scan
    sleep 1
    echo "Getting network."
    sleep 1
    echo "Getting network.."
    sleep 1
    echo "Getting network..."
    station $wlan get-networks
    echo "Enter SSID to connect:"
    read SSID
    echo "Enter network passphrase:"
    read passphrase
    iwctl --passphrase '$passphrase' station '$wlan' connect '$SSID'
    echo "Checking connection"
    
    if ping -c 1 archlinux.org &>/dev/null; then
        echo "Hurray!! You are connected."
    else 
        echo "There is something this script cannot deal with!"
    fi
    timedatectl set-ntp true
    ;;
    2)
    if ping -c 1 archlinux.org &>/dev/null; then
        echo "Hurray!! You are connected."
    else 
        iwconfig
        echo "Select interface for connecting:"
        read ENP
        ip link set $ENP up
        systemctl enable dhcpcd@$ENP.service
    fi
    timedatectl set-ntp true
    ;;
    0) exit 0;;
    *) echo -e "Wrong option";;
esac
}
clear
menu