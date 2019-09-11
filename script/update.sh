#!/usr/bin/env bash

. ../util.sh

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt autoremove -y

git -C ~/.emacs.d pull --rebase

bash-it update
