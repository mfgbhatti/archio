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

#This is a very lazy script I have for auto-installing Arch.
#DO NOT RUN THIS YOURSELF as it is  because this will format partions without any prompt,
#which means you have to modify it for your needs.

# Function
installpkg(){ pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 ;}

timedatectl set-ntp true
sed -i "s/^#Para/Para/;s/^#Color$/Color/" /etc/pacman.conf
for x in archlinux-keyring reflector rsync; do
	installpkg "$x"
done
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back
reflector --age 48 --country GB --fastest 5 --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm
mkfs.vfat -F 32 -n "EFI" /dev/nvme0n1p1
mkfs.btrfs -L ROOT /dev/nvme0n1p2 -f
mount -L ROOT /mnt
btrfs subvolume create /mnt/@
umount /mnt
btrfs check --clear-space-cache v2 /dev/nvme0n1p2
mount -o noatime,commit=120,compress=zstd,ssd,subvol=@ -L ROOT /mnt
mkdir /mnt/{boot,home}
mount -t vfat -L EFI /mnt/boot
mount -t btrfs -L HOME /mnt/home
pacstrap /mnt base base-devel linux linux-firmware linux-headers intel-ucode neovim nano sudo archlinux-keyring wget --noconfirm --needed
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
cp /etc/pacman.conf /mnt/etc/pacman.conf
genfstab -U /mnt >> /mnt/etc/fstab
curl https://raw.githubusercontent.com/mfgbhatti/archio/main/chroot.sh > /mnt/chroot.sh && arch-chroot /mnt bash chroot.sh && rm /mnt/chroot.sh
