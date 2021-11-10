#bootctl install --esp-path=/mnt/boot/efi
bootctl install --esp-path=/mnt/boot
#cat <<EOF > /mnt/boot/efi/loader/entries/arch.conf
cat <<EOF > /mnt/boot/loader/entries/arch.conf
title Arch Linux  
linux /vmlinuz-linux  
initrd  /initramfs-linux.img  
options root=LABEL=ARCH rw rootflags=subvol=@
EOF
