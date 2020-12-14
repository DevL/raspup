#!/usr/bin/env bash

SDCARD=/Volumes/system-boot

echo "Welcome to RaspUp (Ubuntu Edition)"
if [ ! -d "$SDCARD" ]; then
  echo "Insert the SD card and retry."
  exit 1
fi

echo "[User]"
read -p "Enter the username: " username
read -sp "Enter the password: " password
echo
echo "[Network]"
read -p "Enter hostname: " hostname
read -p "Enter SSID: " ssid
read -sp "Enter shared key (hidden): " psk
echo
echo "[Erlang/Elixir Cluster]"
read -sp "Enter Erlang cookie (hidden): " erlangcookie

echo "[01] Enable SSH on boot"
touch $SDCARD/ssh

echo "[02] Update /boot/network_config"
cat << WIFI >> $SDCARD/network_config
wifis:
  wlan0:
    dhcp4: true
    optional: true
    access-points:
      "$ssid":
         password: "$psk"
WIFI

echo "[03] Create /boot/user-data"
cat << USERDATA > $SDCARD/user-data
chpasswd:
  expire: true
  list:
  - ubuntu:ubuntu

ssh_pwauth: true

power_state:
  mode: reboot
USERDATA

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
192.168.10.150  raspup.local
192.168.10.151  red.local
192.168.10.152  green.local
192.168.10.153  blue.local
192.168.10.160  neo.local
127.0.0.1       $hostname
HOSTS

echo "[06] Removing raspberry.local and $hostname.local as known SSH hosts"
sed -i -e '/raspberrypi/d' ~/.ssh/known_hosts
sed -i -e "/$hostname/d" ~/.ssh/known_hosts

echo "[07] Copying public SSH keys to /boot/setup/home/authorized_keys"
test -e ~/.ssh/id_rsa.pub && cat ~/.ssh/id_rsa.pub >> $SDCARD/setup/home/authorized_keys
test -e ~/.ssh/id_ecdsa.pub && cat ~/.ssh/id_ecdsa.pub >> $SDCARD/setup/home/authorized_keys
test -e ~/.ssh/id_ed25519.pub && cat ~/.ssh/id_ed25519.pub >> $SDCARD/setup/home/authorized_keys

echo "[08] Storing Erlang cookie"
echo -n $erlangcookie > $SDCARD/setup/home/.erlang.cookie

echo "[09] Storing user information"
echo -n $username > $SDCARD/setup/username
echo -n $password > $SDCARD/setup/password

echo "[Done] Unmounting the SD card"
diskutil unmount $SDCARD

echo "[What now?]"
echo "First, log in to the Pi and run the '/boot/setup/init.sh' script."
echo "    ssh ubuntu@ubuntu.local"
echo "Secondly, log in as the new user and run the '/boot/setup/setup.sh' script."
echo "    ssh devl@$hostname.local"


