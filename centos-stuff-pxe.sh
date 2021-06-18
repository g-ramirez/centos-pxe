#!/bin/bash

yum install epel-release -y
yum install -y wget

wget https://releases.ubuntu.com/18.04.5/ubuntu-18.04.5-live-server-amd64.iso
wget https://releases.ubuntu.com/18.04/ubuntu-18.04.5-desktop-amd64.iso
wget http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz

yum install httpd -y
yum install nfs-utils -y
yum install dnsmasq -y

mkdir /tftp
mkdir /tftp/boot
mkdir /tftp/bios
mkdir /tftp/grub

mkdir /var/www/html/bionic
mkdir /var/www/html/bionic/server
mkdir /var/www/html/bionic/desktop

yum install p7zip p7zip-plugins -y

7z x ubuntu-18.04.5-live-server-amd64.iso -o/var/www/html/bionic/server
7z x ubuntu-18.04.5-desktop-amd64.iso -o/var/www/html/bionic/desktop
tar xf netboot.tar.gz

#  disable selinux
setenforce 0
systemctl stop firewalld

wget https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/syslinux-6.04-pre1.tar.gz
tar xf syslinux-6.04-pre1.tar.gz
cp syslinux-6.04-pre1/bios/com32/elflink/ldlinux/ldlinux.c32  /tftp/bios/ldlinux.c32
cp syslinux-6.04-pre1/bios/com32/libutil/libutil.c32 /tftp/bios/libutil.c32  
cp syslinux-6.04-pre1/bios/com32/menu/menu.c32  /tftp/bios/menu.c32
cp syslinux-6.04-pre1/bios/com32/menu/vesamenu.c32  /tftp/bios/vesamenu.c32 
cp syslinux-6.04-pre1/bios/core/pxelinux.0  /tftp/bios/pxelinux.0
cp syslinux-6.04-pre1/bios/core/lpxelinux.0  /tftp/bios/lpxelinux.0
ln -s /tftp/boot  /tftp/bios/boot
mkdir /tftp/bios/pxelinux.cfg
mkdir /tftp/boot/server
mkdir /tftp/boot/casper
cp /var/www/html/bionic/desktop/casper/vmlinuz /tftp/boot/casper
cp /var/www/html/bionic/desktop/casper/initrd /tftp/boot/casper
cp /root/ubuntu-installer/amd64/linux /tftp/boot/server
cp /root/ubuntu-installer/amd64/initrd.gz /tftp/boot/server
cp /var/www/html/bionic/server/boot/grub/grub.cfg  /tftp/grub/
cp /var/www/html/bionic/server/boot/grub/font.pf2 /tftp/grub/
echo "/var/www/html/bionic/desktop             192.168.122.0/255.255.255.0(rw,sync,no_root_squash)" > /etc/exports

cp /home/gabe/shimx64.efi.signed /tftp/grub/bootx64.efi
cp /home/gabe/grubnetx64.efi.signed /tftp/grubx64.efi
cp /home/gabe/dnsmasq.conf /etc/dnsmasq.conf
cp /home/gabe/grub.cfg /tftp/grub/grub.cfg

systemctl restart nfs-server
systemctl restart dnsmasq
systemctl restart httpd

# missing 
# populate /etc/exports with ALLOWED SUBNETS
# populate /tftp/bios/pxelinux.cfg/default
# populate /tftp/bios/pxelinux.cfg/default
# populate dns masq config as per article: https://c-nergy.be/blog/?p=13771
# bootx64 = shim signed
# grubx = grubnetx.signed'
# default goes into /tftp/bios/pxelinux.cfg
# grub.cfg goes into /tftp/grub/