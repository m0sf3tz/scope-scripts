#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

lsblk 
echo ""
echo "Place this file in the /poky/build/tmp/deploy/images/raspberrypi3 direcroy of your yocto build"
echo ""
echo ""
echo "Type the device on /dev/ that belongs to the SD card, followed by [ENTER]:"
echo "don't type /dev/ before it, ie, just sde"
echo ""

read device

DEVICE_PATH="/dev/$device"

echo ""
echo "you typed $DEVICE_PATH - is this correct? - be carefull - this will wipe the FS..."
echo "type \"yes\" if the correct device was selecetd"
echo ""

read proceed 

if [ "$proceed" != "yes" ];
   then
   echo "User said wrong device was selected, quitting!!!!"
fi


#erase the FS on the SD card
dd if=/dev/zero of=DEVICE_PATH bs=1M count=20
sync

(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo +32M  # Last sector (Accept default: varies)
echo a #make it bootable
echo n #new partition
echo p #primary
echo 2 #partition 2
echo   #default starting sector
echo +250M #size of this partition
echo t #change type
echo 1 #select pirary
echo c #select it as a w95 FAT23(lba)
echo
echo w # Write changes
) |  fdisk $DEVICE_PATH

sync

echo  ""
echo "formating..."

(
echo #incase it prompts us the old FS is still sticking around in memory
) | mkfs.vfat "${DEVICE_PATH}1"

(
echo #incase it prompts us the old FS is still sticking around in memory
) | mkfs.ext3 "${DEVICE_PATH}2"


echo "finished formatting"


echo starting to copy into boot partition
sleep 1

mkdir boot
mkdir rootfs


#incase device is auto mounted
umount "${DEVICE_PATH}1"
umount "${DEVICE_PATH}2"

mount "${DEVICE_PATH}1" boot
mount "${DEVICE_PATH}2" rootfs

cp MLO boot
cp am335x-boneblack.dtb boot
cp u-boot.img boot
cp zImage boot

sync
umount "${DEVICE_PATH}1"


rm -r boot

echo "Finished copying root directory"

echo "starting to extract root directy..."
tar x -C rootfs -f rootfs.tar.bz2
sync
umount "${DEVICE_PATH}2"

rm -r rootfs

echo "done extracting rootfs!"
