#!/usr/bin/env bash
# Function
installpkg(){ pacman --noconfirm --needed -S "$1";}
# Variables
MOUNTPOINT="/mnt"
BOOT_PARTITION="/dev/sda1"
ROOT_PARTITION="/dev/sda2"
USERNAME="farhan"
ISO="GB"
DISK="/dev/sda"
PARTITION_PARTUUID=$(blkid -s PARTUUID -o value "$ROOT_PARTITION")

password() {
    read -rs -p "Please enter password: " PASSWORD1
    echo -ne "\n"
    read -rs -p "Please re-enter password: " PASSWORD2
    echo -ne "\n"
    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
        PASSWORD="$PASSWORD1"
    else
        echo "password does not match"
        password
    fi
}
password
timedatectl set-ntp true
loadkeys uk
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back
sed -i "s/^#Para/Para/;s/^#Color$/Color/" /etc/pacman.conf
for x in archlinux-keyring reflector rsync; do
	installpkg "$x"
done
reflector --age 48 --country "$ISO" -f 5 --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo -ne "Preparing disk\n"
wipefs -a -f "$DISK" >/dev/null 2>&1
sgdisk -Z "$DISK"
sgdisk -a 2048 -o "$DISK"

sgdisk -n 1::+300M --typecode=1:ef00 --change-name=1:"EFI" "$DISK"
sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:"ROOT" "$DISK"
mkfs.vfat -F 32 -n "EFI" "$BOOT_PARTITION"
mkfs.ext4 -L ROOT "$ROOT_PARTITION"

mount "$ROOT_PARTITION" "$MOUNTPOINT"
mkdir "$MOUNTPOINT"/boot
mount -t vfat -L EFI "$MOUNTPOINT"/boot
pacstrap "$MOUNTPOINT" base linux linux-firmware intel-ucode neovim sudo neovim efibootmgr wget git dhclient networkmanager --noconfirm --needed
cp /etc/pacman.d/mirrorlist "$MOUNTPOINT"/etc/pacman.d/mirrorlist
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' "$MOUNTPOINT"/etc/sudoers
sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' "$MOUNTPOINT"/etc/locale.gen
echo "KEYMAP=uk" >"$MOUNTPOINT"/etc/vconsole.conf
echo "Arch" >"$MOUNTPOINT"/etc/hostname
echo "LANG=en_GB.UTF-8" >"$MOUNTPOINT"/etc/locale.conf
echo "127.0.0.1 localhost Arch" >>"$MOUNTPOINT"/etc/hosts
echo "::1 localhost Arch" >>"$MOUNTPOINT"/etc/hosts
arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u root -- hwclock --systohc
arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u root -- ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u root -- locale-gen
arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u root -- systemctl enable NetworkManager
arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u root -- useradd -m -g wheel -s /bin/bash $USERNAME
arch-chroot "$MOUNTPOINT" /usr/bin/runuser -u root -- echo "$USERNAME:$PASSWORD" | chpasswd
genfstab -U "$MOUNTPOINT" >>"$MOUNTPOINT"/etc/fstab
umount "$MOUNTPOINT"/boot
umount "$MOUNTPOINT"
efibootmgr --disk "$DISK" --part 1 --create --label "Arch" --loader "/vmlinuz-linux" --unicode "root=PARTUUID=$PARTITION_PARTUUID rw initrd=\intel-ucode.img initrd=\initramfs-linux.img"
echo "-=Done=-"
