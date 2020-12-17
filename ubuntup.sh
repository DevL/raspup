#!/usr/bin/env bash

SDCARD="/Volumes/system-boot"

echo "Welcome to RaspUp (Ubuntu Edition)"
if [ ! -d "$SDCARD" ]; then
  echo "Insert the SD card and retry."
  exit 1
fi

echo "[User]"
read -p "Enter the username: " USERNAME
# read -sp "Enter the password: " password
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

echo "[02] Replace /system-boot/network-config"
cat << NETWORK > $SDCARD/network-config
version: 2
ethernets:
  eth0:
    # Rename the built-in ethernet device to "eth0"
    match:
      driver: bcmgenet smsc95xx lan78xx
    set-name: eth0
    dhcp4: true
    optional: true
wifis:
  wlan0:
    dhcp4: true
    optional: true
    access-points:
      "$SSID":
        password: "$PSK"
NETWORK

echo "[03] Replace /boot/user-data"
cat << USERDATA > $SDCARD/user-data
#cloud-config

system_info:
  default_user:
    name: $USERNAME
chpasswd:
  expire: true
  list:
  - $USERNAME:raspup
ssh_pwauth: true
package_update: true
package_upgrade: true
packages:
- openssh-server
- avahi-daemon
- unattended-upgrades
- autoconf
- automake
- curl
- fzf
- gcc
- git
- httpie
- libncurses5-dev
- libssl-dev
- make
- mosh
- unzip
- vim

runcmd:
- 'locale-gen en_GB.UTF-8'
- 'update-locale'

power_state:
  mode: reboot
USERDATA

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

echo "[06] Removing ubunut.local and $hostname.local as known SSH hosts"
sed -i -e '/ubuntu/d' ~/.ssh/known_hosts
sed -i -e "/$HOSTNAME/d" ~/.ssh/known_hosts

echo "[07] Copying public SSH keys to /boot/setup/home/authorized_keys"
test -e ~/.ssh/id_rsa.pub && cat ~/.ssh/id_rsa.pub >> $SDCARD/setup/home/authorized_keys
test -e ~/.ssh/id_ecdsa.pub && cat ~/.ssh/id_ecdsa.pub >> $SDCARD/setup/home/authorized_keys
test -e ~/.ssh/id_ed25519.pub && cat ~/.ssh/id_ed25519.pub >> $SDCARD/setup/home/authorized_keys

echo "[08] Storing Erlang cookie"
echo -n $ERLANGCOOKIE > $SDCARD/setup/home/.erlang.cookie

echo "[09] Storing user information"
echo -n $USERNAME > $SDCARD/setup/username
# echo -n $password > $SDCARD/setup/password

echo "[Done] Unmounting the SD card"
diskutil unmount $SDCARD

echo "[What now?]"
echo "Log in as the new user and run the '/boot/firmware/setup/ubuntu-setup.sh' script."
echo "    ssh $USERNAME@ubuntu.local"
