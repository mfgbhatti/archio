#!/usr/bin/env bash
G=$'\033[0;32m'
N=$'\033[0m'
echo -e "${G}Is system connected to internet?${N}"
read -p "continue (Y|n):" connected
case $connected in
y|Y|yes|Yes|YES)
echo -e "${G}Setting up ntp and pacman${N}"
timedatectl set-ntp true
sed -i "s/^#Para/Para/" /etc/pacman.conf #multi download
echo -e "${G}Setting up ntp and pacman${N} OK"
echo -e "${G}updating mirrorlist${N}"
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector -a 48 -c GB -f 5 -l 10 -n 12 --sort rate --save /etc/pacman.d/mirrorlist #update mirror list to uk
echo -e "${G}updating mirrorlist${N} OK"
echo -e "${G}Partitioning hard disk${N}"
pacman -S --noconfirm gptfdisk btrfs-progs
lsblk
echo -e "${G}Please enter disk to work on: (example /dev/sda)${N}"
read DISK
read -p "are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in
y|Y|yes|Yes|YES)
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment
#echo "create partitions"
sgdisk -n 1:0:+512M ${DISK} # partition 1 (UEFI)
sgdisk -n 2:0:+150G ${DISK} # partition 2 (ROOT)
sgdisk -n 3:0:0 ${DISK} # partition 3 (HOME)
#echo "set partition types"
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8300 ${DISK}
sgdisk -t 3:8300 ${DISK}
#echo  "label partitions"
sgdisk -c 1:"UEFI" ${DISK}
sgdisk -c 2:"ROOT" ${DISK}
sgdisk -c 3:"HOME" ${DISK}
echo -e "${G}Partitioning hard disk${N} OK"
echo -e "${G}Making filesystems and mounting them${N}"
mkfs.vfat -F32 -n "UEFI" "${DISK}p1"
mkfs.btrfs -L "ROOT" "${DISK}p2" -f
mkfs.btrfs -L "HOME" "${DISK}p3" -f
mount -t btrfs "${DISK}p2" /mnt
echo -e "${G}Creating subvolumes"
btrfs su cr /mnt/@
#btrfs su cr /mnt/@.snapshots #if want to add .snapshots as subvolume
umount /mnt
#echo "mounting subvolumes and creating folders"
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@ "${DISK}p2" /mnt
mkdir /mnt/{boot,boot/efi,home} # add .snapshots if uncomment below line
#mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@.snapshots "${DISK}p2" /mnt/.snapshots
mount -t btrfs "${DISK}p3" /mnt/home #mount third partition as home
echo -e "${G}Mounting the boot partition at /boot folder${N}"
mount -t vfat -L UEFI /mnt/boot/
;;
*)
exit
;;
esac
echo -e "${G}Executing pacstrap on /mnt${N}"
pacstrap /mnt base linux linux-firmware nano intel-ucode btrfs-progs vim --noconfirm --needed
echo -e "${G}Generating fstab${N}"
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "${G}Installing /boot${N}"
bootctl install --esp-path=/mnt/boot
# [ ! -d "/mnt/boot/loader/entries" ] && mkdir -p /mnt/boot/loader/entries
cat <<EOF > /mnt/boot/loader/entries/arch.conf
title Arch Linux  
linux /vmlinuz-linux  
initrd  /initramfs-linux.img  
options root=LABEL=ROOT rw rootflags=subvol=@
EOF
;;
*)
exit
;;
esac