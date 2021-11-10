mkfs.vfat -F32 -n EFIBOOT /dev/nvme0n1p1
mkfs.btrfs -L ARCH /dev/nvme0n1p2 -f
mkfs.btrfs -L HOME /dev/nvme0n1p4 -f
