#!/usr/bin/env bash

SDCARD="/Volumes/boot"
BOOTHOME="$SDCARD/setup/home"

echo "Welcome to RaspUp"
if [ ! -d "$SDCARD" ]; then
  echo "Insert the SD card and retry."
  exit 1
fi

echo "[User]"
read -p "Enter the username: " USERNAME
read -sp "Enter the password: " PASSWORD
echo
echo "[Network]"
read -p "Enter hostname: " HOSTNAME
read -p "Enter SSID: " SSID
read -sp "Enter shared key (hidden): " PSK
echo
echo "[Erlang/Elixir Cluster]"
read -sp "Enter Erlang cookie (hidden): " ERLANGCOOKIE

echo "[01] Enable SSH on boot"
touch $SDCARD/ssh

echo "[02] Create /boot/wpa_supplicant.conf"
cat << WIFI > $SDCARD/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=SE
network={
  ssid="$SSID"
  psk="$PSK"
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
echo $HOSTNAME > $SDCARD/etc/hostname
cat << HOSTS > $SDCARD/etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
192.168.10.150  raspup.local
192.168.10.151  red.local
192.168.10.152  green.local
192.168.10.153  blue.local
192.168.10.160  neo.local
127.0.0.1       $HOSTNAME
HOSTS

echo "[06] Removing raspberrypi.local and $HOSTNAME.local as known SSH hosts"
sed -i -e '/raspberrypi/d' ~/.ssh/known_hosts
sed -i -e "/$HOSTNAME/d" ~/.ssh/known_hosts

echo "[07] Copying public SSH keys to /boot/setup/home/authorized_keys"
test -e ~/.ssh/id_rsa.pub && cat ~/.ssh/id_rsa.pub >> $BOOTHOME/authorized_keys
test -e ~/.ssh/id_ecdsa.pub && cat ~/.ssh/id_ecdsa.pub >> $BOOTHOME/authorized_keys
test -e ~/.ssh/id_ed25519.pub && cat ~/.ssh/id_ed25519.pub >> $BOOTHOME/authorized_keys

echo "[08] Storing Erlang cookie"
echo -n $ERLANGCOOKIE > $BOOTHOME/.erlang.cookie

echo "[09] Storing user information"
echo -n $USERNAME > $SDCARD/setup/username
echo -n $PASSWORD > $SDCARD/setup/password

echo "[Done] Unmounting the SD card"
diskutil unmount $SDCARD

echo "[What now?]"
echo "First, log in to the Pi and run the '/boot/setup/init.sh' script."
echo "    ssh pi@raspberrypi.local"
echo "Secondly, log in as the new user and run the '/boot/setup/setup.sh' script."
echo "    ssh $USERNAME@$HOSTNAME.local"


