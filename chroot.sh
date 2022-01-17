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

hwclock --systohc
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_GB.UTF-8" LC_TIME="en_GB.UTF-8"
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j8\"/;s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 8 -z -)/" /etc/makepkg.conf
sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
echo "KEYMAP=uk" > /etc/vconsole.conf
echo "Arch" > /etc/hostname
PKGS = (
'mesa'
'xorg'
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
'pfetch'
'zsh'
'zsh-autosuggestions'
'zsh-completions'
'zsh-history-substring-search'
'zsh-syntax-highlighting'
)
for PKG in "${PKGS[@]}"; do
	installpkg "${PKG}"
done
systemctl enable NetworkManager
sed -i 's/MODULES()/MODULES(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -P linux
groupadd libvirt
useradd -G wheel,libvirt -s /bin/bash farhan
echo "farhan:1234" | chpasswd
cd /home/farhan/
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay
makepkg -si --noconfirm
cd ~
AURS=(
'arc-gtk-theme'
'brave-bin'
'papirus-icon-theme'
'timeshift'
'timeshift-autosnap'
'visual-studio-code-bin'
'zsh-theme-powerlevel10k-git'
)
for AUR in "${AURS[@]}"; do
	aurinstall "${AUR}"
done
