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
    Select partion scheme and format partitions only btrfs
-----------------------------------------------------------------
    1)      Basic scheme (efi and root partition)
    2)      Advance scheme 

    0)      Main menu

Choose an option:
"
    read partition
    case $partition in
        1)
        lsblk
        echo "Choose your disk e.g. /dev/sda:"
        read DISK
        sgdisk -Z ${DISK} &>/dev/null # zap all on disk
        sgdisk -a 2048 -o ${DISK} &>/dev/null # new gpt disk 2048 alignment
        sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
        sgdisk -n 2::+100M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
        sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), default start, remaining
        ;;
        2)
        echo "advance option"
        #need logic here 
        ;;
        0) exit 0;;
        *) echo "Wrong option";;
    esac
}

clear
menu
