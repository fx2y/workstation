#!/usr/bin/env bash

set -euxo pipefail

# brew setup
! command -v brew >/dev/null && /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew analytics off

# brew
brew tap d12frosted/emacs-plus
brews=(
  asdf
  autoconf
  automake
  bash
  curl
  coreutils
  dnscrypt-proxy
  emacs-plus
  findutils
  git
  git-lfs
  gnu-sed
  gnupg
  grep
  icdiff
  libtool
  libxslt
  libyaml
  moreutils
  openssh
  openssl
  pinentry-mac
  privoxy
  readline
  ripgrep
  sqlite3
  unixodbc
  unzip
  vim
  wget
  xz
  zlib
)
brew info "${brews[@]}" | grep bash_profile
brew install "${brews[@]}"
brew cleanup

brew tap homebrew/cask-versions
brew tap homebrew/cask-fonts
casks=(
  appcleaner
  brave-browser-beta
  chromedriver-beta
  clion
  docker
  firefox-beta
  font-fira-code
  gfortran
  goland
  mendeley-desktop
  microsoft-office
  pycharm
  safari-technology-preview
  spectacle
  visual-studio-code
  webstorm
)
brew cask install "${casks[@]}"
brew cleanup

# bash
if ! grep -Fq /usr/local/bin/bash /etc/shells; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash
fi
