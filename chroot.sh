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
installpkg(){ pacman --noconfirm --needed -S "$1" > /dev/null 2>&1 ;}
aurinstall(){ yay --noconfirm --needed -S "$1" > /dev/null 2>&1 ;}
# Varibales
USERNAME="farhan"
PACMAN_PACKAGES="/home/$USERNAME/pacman.txt"
YAY_PACKAGES="/home/$USERNAME/yay.txt"
#Ask password
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
# Starting ...
hwclock --systohc
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j8\"/;s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 8 -z -)/" /etc/makepkg.conf

echo "KEYMAP=uk" >/etc/vconsole.conf
echo "arch" >/etc/hostname
echo "LANG=en_GB.UTF-8" >/etc/locale.conf
echo "127.0.0.1 localhost arch" >>/etc/hosts
echo "::1 localhost arch" >>/etc/hosts

password
locale-gen

if [[ -f "$PACMAN_PACKAGES" ]]; then
	while IFS=' ' read -r LINE; do
		printf "Now Installing %10s\n" "$LINE"
		installpkg "$LINE"
	done<"$PACMAN_PACKAGES"
else 
PKGS=(
'mesa'
'xorg'
'alacritty'
'cups'
'gnome-autoar'
'gnome-backgrounds'
'gnome-bluetooth'
'gnome-characters'
'gnome-color-manager'
'gnome-control-center'
'gnome-desktop'
'gnome-disk-utility'
'gnome-font-viewer'
'gnome-keyring'
'gnome-online-accounts'
'gnome-power-manager'
'gnome-session'
'gnome-settings-daemon'
'gnome-shell'
'gnome-shell-extensions'
'gnome-terminal'
'gnome-themes-extra'
'gnome-tweaks'
'btrfs-progs'
'nvidia'
'nautilus'
'xsel'
'htop'
'efibootmgr'
'gdm'
'dhclient'
'fuse2'
'fuse3'
'kitty'
'neofetch'
'networkmanager'
'dhclient'
'zsh'
'zsh-autosuggestions'
'zsh-completions'
'zsh-history-substring-search'
'zsh-syntax-highlighting'
)
	for PKG in "${PKGS[@]}"; do
		printf "Now Installing %10s\n" "${PKG}"
		installpkg "${PKG}"
	done
fi
systemctl enable NetworkManager
systemctl enable gdm.service
systemctl enable cups.service

sed -i 's/MODULES()/MODULES(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -P linux
groupadd $USERNAME
useradd -G wheel,$USERNAME -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

cd /home/$USERNAME/ || exit 0
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay || exit 0
makepkg -si --noconfirm
cd "$HOME" || exit 0
if [[ -f "$YAY_PACKAGES" ]]; then
	while IFS=' ' read -r LINE; do
		printf "Now Installing %10s\n" "$LINE"
		installpkg "$LINE"
	done<"$YAY_PACKAGES"
else 
AURS=(
'arc-gtk-theme'
'brave-bin'
'pfetch'
'timeshift'
'timeshift-autosnap'
'visual-studio-code-bin'
'zsh-theme-powerlevel10k-git'
)
	for AUR in "${AURS[@]}"; do
		printf "Now Installing %10s\n" "${AUR}"
		aurinstall "${AUR}"
	done
fi

# Ending ...
echo "-=User Section is Done=-"
exit