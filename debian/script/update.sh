#!/usr/bin/env bash

. ../util.sh

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt autoremove -y

git -C ~/.emacs.d pull --rebase

asdf update
asdf plugin-update --all

rustup self update
rustup self upgrade-data
rustup update

#sdk selfupdate
#sdk upgrade

#bash-it update
