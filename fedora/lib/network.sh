#!/usr/bin/env bash

. ../shared/lib/shell.sh

setup_network() {
  shared_setup_etc_hosts
  setup_dnscrypt_proxy
}

setup_dnscrypt_proxy() {
  sudo dnf install -y dnscrypt-proxy
  systemctl stop systemd-resolved
  systemctl disable systemd-resolved
  sudo cp /etc/resolv.conf /etc/resolv.conf.backup
  sudo rm -f /etc/resolv.conf
  cat <<EOF | sudo tee /etc/resolv.conf
nameserver 127.0.0.1
options edns0
EOF
  sudo chattr +i /etc/resolv.conf
  cat <<EOF
block_ipv6 = true
ipv6_servers = false
cache = true
cache_size = 4096
cache_min_ttl = 2400
cache_max_ttl = 86400
cache_neg_min_ttl = 60
cache_neg_max_ttl = 600
EOF
  read -r
  sudo vi /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  sudo systemctl restart NetworkManager
  sudo systemctl restart dnscrypt-proxy
  dnscrypt-proxy -resolve reddit.com
  dig dnscrypt.info | grep SERVER
}