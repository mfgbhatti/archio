#!/usr/bin/env bash



#"     .o.                          oooo         o8o            "
#"    .888.                         '888         '''            "
#"   .8'888.     oooo d8b  .ooooo.   888 .oo.   oooo   .ooooo.  "
#"  .8' '888.    '888''8P d88' ''Y8  888P'Y88b  '888  d88' '88b "
#" .88ooo8888.    888     888        888   888   888  888   888 "
#".8'     '888.   888     888   .o8  888   888   888  888   888 "
#"88o     o8888o d888b    'Y8bod8P' o888o o888o o888o 'Y8bod8P' "
#
#           https://gihub.com/mfgbhatti/archio.git
#This is second part of very lazy script I have for auto-installing Arch. the first part is https://raw.githubusercontent.com/mfgbhatti/archio/main/arch.sh
#DO NOT RUN THIS YOURSELF as it is  because this will format partions without any prompt,
#which means you have to modify it for your needs.
# Function
installpkg(){ pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 ;}
