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

# Variables
MOUNTPOINT="/mnt"
BTRFS_SUBVOLUMES=(@ @opt @tmp @var @usr-local)
MOUNTOPTION="noatime,commit=120,compress=zstd,ssd"
BOOT_PARTITION="/dev/nvme0n1p1"
ROOT_PARTITION="/dev/nvme0n1p2"

# starting ...
timedatectl set-ntp true
loadkeys uk
sed -i "s/^#Para/Para/;s/^#Color$/Color/" /etc/pacman.conf
for x in archlinux-keyring reflector rsync; do
	installpkg "$x"
done
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back
reflector --age 48 --country GB --fastest 5 --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm
mkfs.vfat -F 32 -n "EFI" "$BOOT_PARTITION"
mkfs.btrfs -L ROOT "$ROOT_PARTITION" -f
mount "$ROOT_PARTITION" "$MOUNTPOINT"
echo "Creating subvolumes and directories"
for x in "${BTRFS_SUBVOLUMES[@]}"; do
	btrfs subvolume create "$MOUNTPOINT"/"${x}" >/dev/null 2>&1
done
umount "$MOUNTPOINT"
btrfs check --clear-space-cache v2 "$ROOT_PARTITION"
mount -o "$MOUNTOPTION",subvol=@ "$ROOT_PARTITION" "$MOUNTPOINT"
for VOL in "${BTRFS_SUBVOLUMES[@]:1}"; do
	DIR="${VOL//@/}"
	DIR=$(echo "$DIR" | sed 's/-/\//')
	mkdir -p "$MOUNTPOINT"/"$DIR"
	mount -o "$MOUNTOPTION",subvol="$VOL" "$ROOT_PARTITION" "$MOUNTPOINT"/"$DIR"
done
mkdir "$MOUNTPOINT"/{boot,home}
mount -t vfat -L EFI "$MOUNTPOINT"/boot
mount -t btrfs -L HOME "$MOUNTPOINT"/home
pacstrap "$MOUNTPOINT" base base-devel linux linux-firmware linux-headers intel-ucode neovim sudo archlinux-keyring wget --noconfirm --needed
cp /etc/pacman.d/mirrorlist "$MOUNTPOINT"/etc/pacman.d/mirrorlist
cp /etc/pacman.conf "$MOUNTPOINT"/etc/pacman.conf
genfstab -U "$MOUNTPOINT" >> "$MOUNTPOINT"/etc/fstab
curl https://raw.githubusercontent.com/mfgbhatti/archio/main/chroot.sh > "$MOUNTPOINT"/home/farhan/chroot.sh && arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u farhan -- /home/farhan/chroot.sh && rm "$MOUNTPOINT"/home/farhan/chroot.sh
