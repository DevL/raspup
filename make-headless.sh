#!/usr/bin/env bash

# Enable SSH
touch /Volumes/boot/ssh

# Copy setup scripts to /boot/setup/
cp -R boot/setup /Volumes/boot/

# Create /boot/wpa_supplicant.conf
read -p "Enter SSID: " ssid
read -p "Enter shared key: " psk

cat << WIFI > /Volumes/boot/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=SE
network={
  ssid="$ssid"
  psk="$psk"
}
WIFI

# Unmount the SD card
diskutil unmount /Volumes/boot
