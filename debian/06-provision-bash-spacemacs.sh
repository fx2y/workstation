#!/usr/bin/env bash

. util.sh

sudo apt-get update
sudo apt-get install -y \
  emacs \
  fonts-firacode \
  git \
  rsync

git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash-it/install.sh --silent

touch ~/.hushlogin
touch ~/.bashrc.local
echo 'source "$HOME/.bashrc.local"' >>~/.bashrc

git clone -b develop --depth 1 https://github.com/syl20bnr/spacemacs ~/.emacs.d
rsync -avr conf/home/.spacemacs ~
emacs --insecure
