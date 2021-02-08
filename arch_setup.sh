#!/bin/bash

#=======================================================================================
# This is a setup file for an Arch VM on Unraid
# The point of this script is just to speed up creation of VMs for testing or whatever
# Maybe I'll neevr use it again, but at least I have the steps recorded...
#=======================================================================================

#------------------------
# Installation
#------------------------
timedatectl set-ntp true
echo "Creating partition table"
fdisk -l
echo "Enter main drive"
read var_partition
(
printf "g\n" # Create guid partition table
printf "n\n" # Create new parition
printf "1\n" # Parition 1
printf "\n" # Default block size
printf "+512M\n" # Partition size
printf "t\n" # Change partition file system
printf "1\n" # Change to EFI system
printf "n\n" # Add new partition
printf "2\n" # Partition 2
printf "\n" # Default size
printf "\n" # Default sizefd
printf "w\n" # Write changes to disk
) | fdisk $var_partition

fdisk -l | grep $var_partition

echo "Creating UEFI and root filesystem"
mkfs.fat -F32 ${var_partition}1
mkfs.ext4 ${var_partition}2
fsck -N ${var_partition}1
fsck -N ${var_partition}2

echo "Mount partitions"
mount ${var_partition}2 /mnt
mkdir -p /mnt/boot

echo "Sync pacman repo and use fast mirrors"
pacman -Syy --noconfirm
pacman -S --noconfirm reflector
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

echo "Installing with pacstrap"
pacstrap /mnt base linux linux-firmware dhcpcd vim nano

echo "Configuring system"
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

#------------------------
# Configuration
#------------------------
echo "Updating system clock"
echo "Enter timezone (ie. America/New_York)"
read var_timezone
timedatectl set-timezone $var_timezone
hwclock --systohc
timedatectl status 
read -p "If correct, press any key to continue..."

echo "Setting Locale"
236 
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

echo "Set hostname"
read var_hostname
hostnamectl set-hostname $var_hostname
echo $var_hostname > /etc/hostname
ip addr
echo "Enter static IP"
read var_staticip
touch /etc/hosts
echo "127.0.0.1          localhost" > /etc/hosts
echo "::1                localhost" >> /etc/hosts
echo "${var_staticip}       ${var_hostname}" >> /etc/hosts
less /etc/hosts

echo "Set root password"
passwd

#------------------------
# Bootloader - GRUB
#------------------------
echo "Install Grub bootloader"
mount -t auto ${var_partition}1 /boot
pacman -Syy
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg


#------------------------
# Desktiop - XFCE
#------------------------
echo "Install desktop environment"
pacman -S --noconfirm xorg
pacman -S --noconfirm xfce4 xfce4-goodies
pacman -S --noconfirm lxdm
systemctl enable lxdm.service
vim +%s/# session/session/g /etc/lxdm/lxdm.conf

#------------------------
# Packages
#------------------------
echo "Install essential tools"
pacman -S --noconfirm base
pacman -S --noconfirm base-devel
pacman -S --noconfirm git curl tmux python python-pip
pacman -S p7zip unrar tar rsync
pacman -S chromium

echo "Install ssh"
pacman -S --noconfirm openssh
systemctl enable sshd

#------------------------
# User creation
#------------------------
visudo /etc/sudoers
echo "Create user"
echo "Enter user name"
read var_user
useradd -m -G wheel $var_user
passwd $var_user

read -p "Press any key to reboot..."

exit
reboot

#------------------------
# Post install
#------------------------
# If no network do these steps
# dhcpcd ens4
# systemctl enable dhcpcd@ens4
