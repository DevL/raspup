#!/usr/bin/env bash

echo "Welcome $(whoami) to the final setup step of RaspUp"
cd $HOME

echo "[01] Forcefully removing the default user"
sudo deluser --force --remove-home pi

echo "[02] Copying authorized_keys SSH keys"
mkdir -p $HOME/.ssh/
cp /boot/setup/home/authorized_keys $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys

echo "[03] Copying the Erlang magic cookie"
cp /boot/setup/home/.erlang.cookie $HOME/.erlang.cookie
chmod 400 $HOME/.erlang.cookie

echo "[04] Adding aliases"
cat << ALIASES >> $HOME/.bashrc

# Additional aliases
alias ll='ls -lAF'
ALIASES

echo "[05] Updating system"
sudo apt update && sudo apt upgrade --yes

echo "[06] Enabling unattended upgrades"
sudo apt-get install unattended-upgrades --yes
# To only update the package list daily, replace the above with the following
# cat << APT | sudo tee -a /etc/apt/apt.conf.d/02periodic
# APT::Periodic::Update-Package-Lists "1";
# APT::Periodic::Download-Upgradeable-Packages "0";
# APT::Periodic::AutocleanInterval "0";
# APT::Periodic::Unattended-Upgrade "0";
# APT

echo "[07] Installing additional software"
sudo apt install automake autoconf curl fzf git httpie libncurses5-dev libssl-dev mosh vim --yes

echo "[08] Installing the micro text editor"
# sudo apt install xclip --yes
curl https://getmic.ro | bash
sudo mv micro /usr/bin
mkdir -p $HOME/.config/micro
cp /boot/setup/home/.config/micro/settings.json $HOME/.config/micro/settings.json
micro -plugin install fzf

echo "[09] Configuring Vim"
cp /boot/setup/home/.vimrc.json $HOME/.vimrc

echo "[10] Start Erlang Port Mapper Daemon (epmd) at boot"
echo "@reboot $(whoami) /home/$(whoami)/.cron/start_epmd.sh" > epmd.cron
sudo mv epmd.cron /etc/cron.d/epmd
sudo chmod root:root /etc/cron.d/epmd

echo "[11] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
cat << ASDF >> $HOME/.bashrc

# asdf version manager
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
ASDF

echo "[12] Installing Erlang"
asdf plugin add erlang
asdf install erlang latest
asdf global erlang `asdf list erlang`

echo "[13] Installing Elixir"
asdf plugin add elixir
asdf install elixir latest
asdf global elixir `asdf list elixir`

echo "[14] Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf global ruby `asdf list ruby`

echo "[15] Cloning the RaspUp repository"
git clone https://github.com/DevL/raspup.git

echo "[16] Cleaning up boot volume"
sudo rm -rf /boot/setup

echo "[Done] Rebooting in 5 seconds"
sleep 5
sudo reboot
