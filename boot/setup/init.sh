#!/usr/bin/env bash

USERNAME=$(cat /boot/setup/username)
PASSWORD=$(cat /boot/setup/password)
HOSTNAME=$(cat /boot/etc/hostname)

echo "Running init script"

echo "[01] Setting the timezone"
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

echo "[02] Setting hostname to '$HOSTNAME'"
sudo cp /boot/etc/hostname /etc/hostname
sudo cp /boot/etc/hosts /etc/hosts

echo "[03] Creating a new user called '${USERNAME}'"
sudo useradd --create-home $USERNAME
echo "$USERNAME:$PASSWORD" | sudo chpasswd
groups | sed 's/pi //g' | sed -e "s/ /,/g" | xargs -I{} sudo usermod -a -G {} $USERNAME
groups $USERNAME
sudo rm /boot/setup/username
sudo rm /boot/setup/password

echo "[04] Copying authorized_keys SSH keys"
sudo mkdir -p /home/$USERNAME/.ssh/
sudo cp /boot/setup/home/authorized_keys /home/$USERNAME/.ssh/authorized_keys
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

echo "[05] Expanding the root file system to use the entire SD card"
sudo raspi-config nonint do_expand_rootfs

echo "[Done] Rebooting in 5 seconds, log in again as the new user and run the setup script"
echo "    ssh $USERNAME@$HOSTNAME.local"
sleep 5
sudo reboot
