#!/usr/bin/env bash

echo "Running setup script"
cd $HOME

echo "[01] Forcefully removing the default user"
sudo deluser --force --remove-home pi

echo "[02] Adding aliases"
cat << ALIASES >> $HOME/.bashrc

# Additional aliases
alias ll='ls -lAF'
ALIASES

echo "[03] Updating system"
sudo apt update && sudo apt upgrade --yes

echo "[04] Enabling unattended upgrades"
sudo apt-get install unattended-upgrades
# To only update the package list daily, replace the above with the following
# cat << APT | sudo tee -a /etc/apt/apt.conf.d/02periodic
# APT::Periodic::Update-Package-Lists "1";
# APT::Periodic::Download-Upgradeable-Packages "0";
# APT::Periodic::AutocleanInterval "0";
# APT::Periodic::Unattended-Upgrade "0";
# APT

echo "[05] Installing additional software"
sudo apt install automake autoconf curl fzf git httpie libncurses5-dev libssl-dev vim --yes

echo "[06] Installing the micro text editor"
# sudo apt install xclip --yes
curl https://getmic.ro | bash
sudo mv micro /usr/bin
mkdir -p $HOME/.config/micro
cp /boot/setup/home/.config/micro/settings.json $HOME/.config/micro/settings.json
micro -plugin install fzf

echo "[07] Configuring Vim"
cp /boot/setup/home/.vimrc.json $HOME/.vimrc

echo "[08] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
cat << ASDF >> $HOME/.bashrc
# asdf version manager
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
ASDF

echo "[09] Installing Erlang"
asdf plugin add erlang
asdf install erlang latest
asdf global erlang `asdf list erlang`

echo "[10] Installing Elixir"
asdf plugin add elixir
asdf install elixir latest
asdf global elixir `asdf list elixir`

echo "[11] Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf global ruby `asdf list ruby`

echo "[12] Start Erlang Port Mapper Daemon (epmd) at boot"
echo "@reboot $(whoami) /home/$(whoami)/.cron/start_epmd.sh" > epmd.cron
sudo mv epmd.cron /etc/cron.d/epmd
sudo chmod root:root /etc/cron.d/epmd

echo "[Done] Rebooting in 5 seconds"
sleep 5
sudo reboot
