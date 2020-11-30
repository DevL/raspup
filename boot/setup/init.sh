#!/usr/bin/env bash
echo "Running init script"

echo "[01] Setting the timezone"
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

echo "[02] Creating a new user"
sudo adduser devl
groups | sed 's/pi //g' | sed -e "s/ /,/g" | xargs -I{} sudo usermod -a -G {} devl

echo "[03] Adding setup script to the new user's home directory"
sudo cp /boot/setup/setup.sh /home/devl/setup.sh
sudo chown /home/devl/setup.sh devl
sudo chmod +x /home/devl/setup.sh

echo "[04] Forcefully removing the default user"
sudo deluser --force --remove-home pi

echo "[05] Rebooting in 5 seconds. Please log in again as the new user and run the setup script"
sleep 5
sudo reboot
