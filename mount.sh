mount -t btrfs /dev/nvme0n1p2 /mnt
btrfs su cr /mnt/@
umount /mnt
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@ /dev/nvme0n1p2 /mnt
mkdir /mnt/{boot,boot/efi,home} 2>/dev/null
#mount -t vfat -L EFIBOOT /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot
mount -t btrfs -L HOME /mnt/home #mount third partition as home
