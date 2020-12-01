#!/usr/bin/env bash
echo "Running init script"

echo "[01] Setting the timezone"
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

echo "[02] Linking /etc/hostname to /boot/hostname"
sudo rm -f /etc/hostname
sudo ln -sf /boot/hostname /etc/hostname

echo "[03] Linking /etc/hosts to /boot/hosts"
sudo rm -f /etc/hosts
sudo ln -sf /boot/hosts /etc/hosts

echo "[04] Creating a new user"
sudo adduser devl
groups | sed 's/pi //g' | sed -e "s/ /,/g" | xargs -I{} sudo usermod -a -G {} devl

echo "[05] Forcefully removing the default user"
sudo deluser --force --remove-home pi

echo "[Done] Rebooting in 5 seconds. Please log in again as the new user and run the setup script"
sleep 5
sudo reboot
