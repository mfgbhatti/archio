#!/usr/bin/bash
#"     .o.                          oooo         o8o            "
#"    .888.                         '888         '''            "
#"   .8'888.     oooo d8b  .ooooo.   888 .oo.   oooo   .ooooo.  "
#"  .8' '888.    '888''8P d88' ''Y8  888P'Y88b  '888  d88' '88b "
#" .88ooo8888.    888     888        888   888   888  888   888 "
#".8'     '888.   888     888   .o8  888   888   888  888   888 "
#"88o     o8888o d888b    'Y8bod8P' o888o o888o o888o 'Y8bod8P' "
#
#           https://gihub.com/mfgbhatti/archio.git

# Declaring scripts directory
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
clear
# bash dialog to choose between basic and advance scheme

menu () {
op=$(dialog --title "Select one option" \
--clear --colors \
--backtitle "Archio" \
--menu "Please select option for configuration from this menu     
    and make sure all selected options are in order given.    
    You can skip an option depending thats is already done.  " 20 60 10 \
1 "Connect to internet" \
2 "Select disk drive" \
3 "Pacstrap packages" \
4 "Locale generation" \
5 "Configure pacman" \
6 "Install packages" \
7 "Enable services" \
8 "Add user" \
9 "Install bootloader" \
0 "Exit" 3>&1 1>&2 2>&3 3>&-)

case $op in
    1) bash scripts/connect.sh; menu;;
    2) bash scripts/format.sh; menu;;
    3) bash scripts/pacstrap.sh; menu;;
    0) exit 0;;
    *) echo -e "Wrong option";;
esac
}
menu