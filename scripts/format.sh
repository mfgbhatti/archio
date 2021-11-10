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

pacman -S --noconfirm gptfdisk &>/dev/null
lsblk
echo "Choose your disk e.g. /dev/sda:"
read DISK
sgdisk -Z ${DISK} &>/dev/null # zap all on disk
sgdisk -a 2048 -o ${DISK} &>/dev/null # new gpt disk 2048 alignment
case $DISK in
    1)
    sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
    sgdisk -n 2::+100M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
    sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), default start, remaining
    ;;
    2)
    echo "This will create partitions in addition to efi and root partitions"
    echo "Choose boot partition size in megabytes:"
    read BOOT
    sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
    sgdisk -n 2::+'$BOOT'M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
    echo "Choose root partition size in gigabytes:"
    read ROOT
    sgdisk -n 3::+'$ROOT'G --typecode=3:8300 --change-name=3:'ROOT' ${DISK}
    echo "Do you want to create more partitions (Y/n):"
    read selection
        case $selection in
        y|Y|yes|Yes|YES)
            echo "Choose partition size in gigabytes:"
            read NEW
            sgdisk -n 4::+'$NEW'G --typecode=4:8300 --change-name=4:'OTHER' ${DISK}
            echo "Do you want to create more partitions (Y/n):"
            read more
            case $more in
            y|Y|yes|Yes|YES)
                echo "Choose partition size in gigabytes:"
                read NEW1
                sgdisk -n 5::+'$NEW1'G --typecode=4:8300 --change-name=5:'EXTRA' ${DISK}
            ;;
            n|N|no|No|NO) echo "Exiting partioning mode";;
            *) echo "Wrong option";;
            ;;
            esac
        n|N|no|No|NO) echo "Exiting partioning mode";;
        *) echo "Wrong option";;
        esac
    0) exit 0;;
    *) echo "Wrong option";;
esac

echo -e "\nCreating Filesystems...\n$HR"
if [[ ${DISK} =~ "nvme" ]]; then
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}p2"
mkfs.btrfs -L "ROOT" "${DISK}p3" -f
mount -t btrfs "${DISK}p3" /mnt
else
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}2"
mkfs.btrfs -L "ROOT" "${DISK}3" -f
mount -t btrfs "${DISK}3" /mnt
fi
ls /mnt | xargs btrfs subvolume delete
btrfs subvolume create /mnt/@
umount /mnt
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@ -L ROOT /mnt
mkdir /mnt/{boot,boot/efi} &>/dev/null
# installing systemd boot
mount -t vfat -L EFIBOOT /mnt/boot
}
clear
menu
