#!/usr/bin/env bash

echo "Running setup script"
cd $HOME

echo "[01] Adding aliases"
echo "ll='ls -lAF' >> $HOME/.bashrc"

echo "[02] Installing the micro text editor"
#sudo apt install xclip --yes
curl https://getmic.ro | bash
sudo mv micro /usr/bin
sudo cp /boot/setup/.config/micro/settings.json $HOME/.config/micro/settings.json

echo "[03] Updating system"
sudo apt update && sudo apt upgrade --yes

echo "[04] Installing additional software"
sudo apt install automake autoconf curl git httpie libncurses5-dev libssl-dev --yes

echo "[05] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
echo "# asdf version manager" >> $HOME/.bashrc
echo ". $HOME/.asdf/asdf.sh" >> $HOME/.bashrc
echo ". $HOME/.asdf/completions/asdf.bash" >> $HOME/.bashrc
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

echo "[06] Installing Erlang"
asdf plugin add erlang
asdf install erlang latest
asdf global erlang `asdf list erlang`

echo "[07] Installing Elixir"
asdf plugin add elixir
asdf install elixir latest
asdf global elixir `asdf list elixir`

echo "[08] Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf global ruby `asdf list ruby`

echo "[Done]"
