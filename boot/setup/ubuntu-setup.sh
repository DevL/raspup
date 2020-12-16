#!/usr/bin/env bash

BOOTPATH="/boot/firmware"
BOOTHOME="$BOOTPATH/setup/home"
HOSTNAME=$(cat $BOOTPATH/etc/hostname)
USERNAME=$(whoami)
USERHOME=$HOME

echo "Welcome $USERNAME to the setup of RaspUp (Ubuntu Edition)"
cd $USERHOME

echo "[01] Setting the timezone"
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

echo "[02] Setting hostname to '$HOSTNAME'"
sudo cp $BOOTPATH/etc/hostname /etc/hostname
sudo cp $BOOTPATH/etc/hosts /etc/hosts

echo "[03] Copying authorized_keys SSH keys"
sudo mkdir -p $USERHOME/.ssh/
sudo cp $BOOTHOME/authorized_keys $USERHOME/.ssh/authorized_keys
sudo chmod 600 $USERHOME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME $USERHOME/.ssh

echo "[04] Copying the Erlang magic cookie"
cp $BOOTHOME/.erlang.cookie $USERHOME/.erlang.cookie
chmod 400 $USERHOME/.erlang.cookie

echo "[05] Adding aliases"
cat << ALIASES >> $USERHOME/.bashrc

# Additional aliases
alias ll='ls -lAF'
alias volumes='sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL'
ALIASES

echo "[06] Installing the micro text editor"
# sudo apt install xclip --yes
curl https://getmic.ro | bash
sudo mv micro /usr/bin
mkdir -p $USERHOME/.config/micro
cp $BOOTHOME/.config/micro/settings.json $USERHOME/.config/micro/settings.json
micro -plugin install fzf

echo "[07] Configuring Vim"
cp $BOOTHOME/.vimrc.json $USERHOME/.vimrc

echo "[08] Start Erlang Port Mapper Daemon (epmd) at boot"
echo "@reboot $USERNAME $USERHOME/.cron/start_epmd.sh" > epmd.cron
sudo mv epmd.cron /etc/cron.d/epmd
sudo chmod root:root /etc/cron.d/epmd

echo "[09] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $USERHOME/.asdf/asdf.sh
. $USERHOME/.asdf/completions/asdf.bash
cat << ASDF >> $USERHOME/.bashrc

# asdf version manager
. $USERHOME/.asdf/asdf.sh
. $USERHOME/.asdf/completions/asdf.bash
ASDF

echo "[10] Installing Erlang"
asdf plugin add erlang
asdf install erlang latest
asdf global erlang `asdf list erlang`

echo "[11] Installing Elixir"
asdf plugin add elixir
asdf install elixir latest
asdf global elixir `asdf list elixir`
mix local.hex --force

echo "[12] Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf global ruby `asdf list ruby`

echo "[13] Cloning the RaspUp repository"
git clone https://github.com/DevL/raspup.git

echo "[14] Cleaning up boot volume"
sudo rm -rf $BOOTPATH/setup

echo "[Done] Rebooting in 5 seconds"
echo "Hostname will be change after reboot. Use the following to log in."
echo "    ssh $USERNAME@$HOSTNAME.local"
sleep 5
sudo reboot
