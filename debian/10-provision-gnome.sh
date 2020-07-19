#!/usr/bin/env bash

. util.sh

sudo apt-get update
sudo apt-get install -y \
	gnome-shell-extension-autohidetopbar \
	rsync

gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.sessionmanager logout-prompt false

rsync -avr conf/home/.config/ ~/.config

# use gnome-shell-extension-autohidetopbar in gnome tweaks
