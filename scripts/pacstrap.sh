pacstrap /mnt base base-devel linux linux-firmware vim nano archlinux-keyring git --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
cp -R ${SCRIPT_DIR} /mnt/root/archio
exit 0