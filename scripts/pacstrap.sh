#!/usr/bin/env bash
echo -ne "
        .o.                          oooo         o8o            
       .888.                         '888         '''            
      .8'888.     oooo d8b  .ooooo.   888 .oo.   oooo   .ooooo.  
     .8' '888.    '888''8P d88' ''Y8  888P'Y88b  '888  d88' '88b 
    .88ooo8888.    888     888        888   888   888  888   888 
   .8'     '888.   888     888   .o8  888   888   888  888   888 
   88o     o8888o d888b    'Y8bod8P' o888o o888o o888o 'Y8bod8P' 
-----------------------------------------------------------------
    Installing base, linux, linux firmware and many more
    Generating fstab for new system
-----------------------------------------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware vim nano archlinux-keyring git --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
cp -R ${SCRIPT_DIR} /mnt/root/archio
exit 0