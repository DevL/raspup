#!/usr/bin/env bash

SDCARD=/Volumes/boot

echo "Welcome to RaspUp"
if [ ! -d "$SDCARD" ]; then
  echo "Insert the SD card and retry."
  exit 1
fi

read -p "Enter hostname: " hostname
read -p "Enter SSID: " ssid
read -p "Enter shared key: " psk

echo "[01] Enable SSH on boot"
touch $SDCARD/ssh

echo "[02] Create /boot/wpa_supplicant.conf"
cat << WIFI > $SDCARD/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=SE
network={
  ssid="$ssid"
  psk="$psk"
}
WIFI

echo "[03] Modifying /boot/config.txt"
cat << CONFIG >> $SDCARD/config.txt

# Added by RaspUp
gpu_mem=16
sdtv_mode=2
hdmi_safe=1
CONFIG

echo "[04] Copy setup scripts to /boot/setup/"
cp -R boot/setup $SDCARD/

echo "[05] Generating hostname and hosts files"
mkdir $SDCARD/etc
echo $hostname > $SDCARD/etc/hostname
cat << HOSTS > $SDCARD/etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
127.0.0.1       $hostname
HOSTS

echo "[06] Removing raspberry.local and $hostname.local as known SSH hosts"
sed -i -e '/raspberrypi/d' ~/.ssh/known_hosts
sed -i -e "/$hostname/d" ~/.ssh/known_hosts

echo "[07] Copying public SSH keys to /boot/setup/home/authorized_keys"
cat ~/.ssh/id_rsa.pub >> $SDCARD/setup/home/authorized_keys

echo "[Done] Unmounting the SD card"
diskutil unmount $SDCARD
