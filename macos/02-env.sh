#!/usr/bin/env bash

set -euxo pipefail

# bash-it
if [ ! -d ~/.bash_it ]; then
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  ~/.bash_it/install.sh --silent
  touch ~/.bash_profile.local
  echo '. ~/.bash_profile.local' >>~/.bash_profile
fi

/usr/local/opt/openssl@1.1/bin/c_rehash
{
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"'
  # shellcheck disable=SC2016
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/curl/bin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"'
  # shellcheck disable=SC2016
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/libxslt/bin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/sqlite/bin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/unzip/bin:$PATH"'
  echo -e "\n. $(brew --prefix asdf)/asdf.sh"
  echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
} >>~/.bash_profile.local

# dnscrypt-proxy
## /usr/local/etc/dnscrypt-proxy.toml
## block_ipv6 = true
## ipv6_servers = false
## cache_size = 4096
## cache_min_ttl = 2400
## cache_max_ttl = 86400
## cache_neg_min_ttl = 60
## cache_neg_max_ttl = 600
vi /usr/local/etc/dnscrypt-proxy.toml
sudo brew services start dnscrypt-proxy
sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1

# privoxy
brew services start privoxy
sudo networksetup -setwebproxy "Wi-Fi" 127.0.0.1 8118
sudo networksetup -setsecurewebproxy "Wi-Fi" 127.0.0.1 8118

# emacs-plus
ln -s /usr/local/opt/emacs-plus/Emacs.app /Applications
