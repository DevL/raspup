#!/usr/bin/env bash

echo "Welcome $(whoami) to the final setup step of RaspUp"
cd $HOME

echo "[01] Forcefully removing the default user"
sudo deluser --force --remove-home pi

echo "[02] Copying the Erlang magic cookie"
cp /boot/setup/home/.erlang.cookie $HOME/.erlang.cookie
chmod 400 $HOME/.erlang.cookie

echo "[03] Adding aliases"
cat << ALIASES >> $HOME/.bashrc

# Additional aliases
alias ll='ls -lAF'
alias volumes='sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL'
ALIASES

echo "[04] Updating system"
sudo apt update && sudo apt upgrade --yes

echo "[05] Enabling unattended upgrades"
sudo apt-get install unattended-upgrades --yes
# To only update the package list daily, replace the above with the following
# cat << APT | sudo tee -a /etc/apt/apt.conf.d/02periodic
# APT::Periodic::Update-Package-Lists "1";
# APT::Periodic::Download-Upgradeable-Packages "0";
# APT::Periodic::AutocleanInterval "0";
# APT::Periodic::Unattended-Upgrade "0";
# APT

echo "[06] Installing additional software"
sudo apt install automake autoconf curl fzf git httpie libncurses5-dev libssl-dev mosh vim --yes

echo "[07] Installing the micro text editor"
# sudo apt install xclip --yes
curl https://getmic.ro | bash
sudo mv micro /usr/bin
mkdir -p $HOME/.config/micro
cp /boot/setup/home/.config/micro/settings.json $HOME/.config/micro/settings.json
micro -plugin install fzf

echo "[08] Configuring Vim"
cp /boot/setup/home/.vimrc.json $HOME/.vimrc

echo "[09] Start Erlang Port Mapper Daemon (epmd) at boot"
mkdir $HOME/.cron
cp /boot/setup/home/.cron/start_epmd.sh $HOME/.cron/start_epmd.sh
echo "@reboot $(whoami) $HOME/.cron/start_epmd.sh" > epmd.cron
sudo mv epmd.cron /etc/cron.d/epmd
sudo chown root:root /etc/cron.d/epmd
sudo chmod 600 /etc/cron.d/epmd

echo "[10] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
cat << ASDF >> $HOME/.bashrc

# asdf version manager
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
ASDF

echo "[11] Installing Erlang"
asdf plugin add erlang
asdf install erlang latest
asdf global erlang `asdf list erlang`

echo "[12] Installing Elixir"
asdf plugin add elixir
asdf install elixir latest
asdf global elixir `asdf list elixir`
mix local.hex --force

echo "[13] Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf global ruby `asdf list ruby`

echo "[14] Cloning the RaspUp repository"
git config --global pull.rebase true
git clone https://github.com/DevL/raspup.git

echo "[15] Cleaning up boot volume"
sudo rm -rf /boot/setup

echo "[Done] Rebooting in 5 seconds"
sleep 5
sudo reboot
