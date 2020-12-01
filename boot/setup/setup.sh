#!/usr/bin/env bash

echo "Running setup script"
cd $HOME

echo "[01] Forcefully removing the default user"
sudo deluser --force --remove-home pi

echo "[02] Adding aliases"
cat << ALIASES >> $HOME/.bashrc
ll='ls -lAF'
ALIASES

echo "[03] Installing the micro text editor"
#sudo apt install xclip --yes
curl https://getmic.ro | bash
sudo mv micro /usr/bin
sudo cp /boot/setup/.config/micro/settings.json $HOME/.config/micro/settings.json
echo -e "\tTODO: Install and configure Micro plugins such as fzf."

echo "[04] Updating system"
sudo apt update && sudo apt upgrade --yes

echo "[05] Installing additional software"
sudo apt install automake autoconf curl git httpie libncurses5-dev libssl-dev --yes

echo "[06] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
cat << ASDF >> $HOME/.bashrc
# asdf version manager
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
ASDF

echo "[07] Installing Erlang"
asdf plugin add erlang
asdf install erlang latest
asdf global erlang `asdf list erlang`

echo "[08] Installing Elixir"
asdf plugin add elixir
asdf install elixir latest
asdf global elixir `asdf list elixir`

echo "[09] Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf global ruby `asdf list ruby`

echo "[Done]"
