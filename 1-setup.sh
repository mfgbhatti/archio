#!/usr/bin/env bash
G=$'\033[0;32m'
N=$'\033[0m'
echo -e "${G}Setting up language and locale${N}"
sed -i "s/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Europe/London
hwclock --systohc
localectl --no-ask-password set-locale LANG="en_GB.UTF-8" LC_TIME="en_GB.UTF-8"
localectl --no-ask-password set-keymap uk # Set keymaps uk
echo "Arch" > /etc/hostname
echo "127.0.0.1  localhost" > /etc/hosts
echo "::1        localhost" > /etc/hosts
echo -e "${G}Setting up language and locale ${N}OK"
echo -e "${G}Changing pacman conf and installing reflector${N}"
sed -i "s/^#Para/Para/" /etc/pacman.conf #Add parallel downloading
pacman -S --noconfirm reflector rsync --needed
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector -a 48 -c GB -f 5 -l 10 -n 12 --sort rate --save /etc/pacman.d/mirrorlist #update mirror list to uk
echo -e "${G}Changing pacman conf and installing reflector ${N}OK"
echo -e "${G}Counting processors and updating makepg.conf${N}"
nc=$(grep -c ^processor /proc/cpuinfo)
sed -i "s/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
echo -e "${G}Counting processors and updating makepg.conf ${N}OK"
echo -e "${G}GUI and packages installation${N}"
pacman -Sy --noconfirm
PKGS=(
'mesa' # Essential Xorg First
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'gnome-shell'
'gnome-autoar'
'gnome-backgrounds'
'gnome-bluetooth'
'gnome-calculator'
'gnome-control-center'
'gnome-desktop'
'gnome-disk-utility'
'gnome-firmware'
'gnome-font-viewer'
'gnome-keyring'
'gnome-layout-switcher'
'gnome-menus'
'gnome-screenshot'
'gnome-session'
'gnome-settings-daemon'
'gnome-shell-extensions'
'gnome-system-log'
'gnome-system-monitor'
'gnome-terminal'
'gnome-tweaks'
'gnome-wallpapers'
'pamac-gnome-integration'
'base-devel'
'bluez'
'bluez-libs'
'cups'
'curl'
'dhclient'
'dialog'
'dosfstools'
'dosfstools'
'efibootmgr' # EFI boot
'gdm'
'git'
'gparted' # partition management
'gptfdisk'
'linux-headers'
'mtools'
'nano'
'nautilus'
'nautilus-admin'
'neofetch'
'networkmanager'
'network-manager-applet'
'sudo'
'unrar'
'unzip'
'vim'
'wget'
'which'
'wpa_supplicant'
'xdg-dbus-proxy'
'xdg-desktop-portal'
'xdg-user-dirs'
'xdg-utils'
'zip'
'zsh'
'zsh-autosuggestions'
'zsh-completions'
'zsh-history-substring-search'
'zsh-syntax-highlighting'
)
for PKG in "${PKGS[@]}"; do
    echo -e "\033[0;32mINSTALLING: \033[0m${PKG}"
    pacman -S "$PKG" --noconfirm --needed
done
echo -e "${G}GUI and packages installation ${N}OK"
echo -e "${G}Enabling services${N}"
systemctl enable --now org.cups.cupsd.service
systemctl enable --now NetworkManager
systemctl enable --now gdm
systemctl enable --now bluetooth
echo -e "${G}Enabling services ${N}OK"
echo -e "${G}Creating mkinitcpio conf${N}"
sed -i "s/MODULES=()/MODULES=(btrfs)/" /etc/mkinitcpio.conf
mkinitcpio -p linux
echo -e "${G}Creating mkinitcpio conf ${N}OK"
echo -e "${G}Enter username${N}"
read USER
useradd -mG wheel "${USER}"
passwd "${USER}"
sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
echo -e "${G}created ${USER} and added to sudoers ${N}OK"
echo -e "${G}Setup finished ${N}OK"