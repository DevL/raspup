#!/usr/bin/env bash

echo "Welcome to RaspUp"
read -p "Enter hostname: " hostname
read -p "Enter SSID: " ssid
read -p "Enter shared key: " psk

echo "[01] Adding hostname to /boot/hostname and /boot/hosts"
echo $hostname > /Volumes/boot/hostname
cat << HOSTS > /Volumes/boot/hosts
127.0.0.1       $hostname
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
HOSTS

echo "[02] Enable SSH on boot"
touch /Volumes/boot/ssh

echo "[03] Create /boot/wpa_supplicant.conf"
cat << WIFI > /Volumes/boot/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=SE
network={
  ssid="$ssid"
  psk="$psk"
}
WIFI

echo "[04] Modifying /boot/config.txt"
cat << CONFIG >> /Volumes/boot/config.txt

# Added by RaspUp
gpu_mem=16
sdtv_mode=2
hdmi_safe=1
CONFIG

echo "[05] Copy setup scripts to /boot/setup/"
cp -R boot/setup /Volumes/boot/

echo "[Done] Unmounting the SD card"
diskutil unmount /Volumes/boot
