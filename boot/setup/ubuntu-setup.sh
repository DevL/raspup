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

echo "[06] Configuring the micro text editor"
# sudo apt install xclip --yes
# curl https://getmic.ro | bash
# sudo mv micro /usr/bin
mkdir -p $USERHOME/.config/micro
cp $BOOTHOME/.config/micro/settings.json $USERHOME/.config/micro/settings.json
micro -plugin install fzf

echo "[07] Configuring Vim"
cp $BOOTHOME/.vimrc.json $USERHOME/.vimrc

echo "[08] Start Erlang Port Mapper Daemon (epmd) at boot"
mkdir $USERHOME/.cron
cp /boot/setup/home/.cron/start_epmd.sh $USERHOME/.cron/start_epmd.sh
echo "@reboot $USERNAME $USERHOME/.cron/start_epmd.sh" > epmd.cron
sudo mv epmd.cron /etc/cron.d/epmd
sudo chown root:root /etc/cron.d/epmd
sudo chmod 600 /etc/cron.d/epmd

echo "[09] Enabling remote desktop"
#sudo apt install xrdp
#sudo systemctl enable xrdp
echo " => Starting desktop on boot"
systemctl set-default graphical.target
# echo " => Installing VNC server"
# sudo apt install tigervnc-standalone-server --yes
echo " => Configuring VNC session"
vncpasswd
mkdir $USERHOME/.vnc
mv $USERHOME/.vnc/xstartup $USERHOME/.vnc/xstartup.bak
cat << VNC > $USERHOME/.vnc/xstartup
#!/bin/sh
exec /etc/vnc/xstartup
xrdb $HOME/.Xresources
vncconfig -iconic &
dbus-launch --exit-with-session gnome-session &
VNC
chmod u+x $USERHOME/.vnc/xstartup
echo " => Configuring VNC service"
cat << VNCSERVICE | sudo tee /etc/systemd/system/vncserver@.service
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=simple
User=$USERNAME
PAMName=login
PIDFile=/home/%u/.vnc/%H%i.pid
ExecStartPre=/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || :
ExecStart=/usr/bin/vncserver :%i -localhost no -geometry 1280x768
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
VNCSERVICE
systemctl daemon-reload
systemctl enable vncserver@1.service
systemctl start vncserver@1.service

echo "[10] Installing the asdf version manager"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $USERHOME/.asdf/asdf.sh
. $USERHOME/.asdf/completions/asdf.bash
cat << ASDF >> $USERHOME/.bashrc

# asdf version manager
. $USERHOME/.asdf/asdf.sh
. $USERHOME/.asdf/completions/asdf.bash
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
sudo rm -rf $BOOTPATH/setup

echo "[Done] Rebooting in 5 seconds"
echo "Hostname will be change after reboot. Use the following to log in."
echo "    ssh $USERNAME@$HOSTNAME.local"
sleep 5
sudo reboot
