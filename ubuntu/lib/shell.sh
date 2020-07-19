#!/usr/bin/env bash

. ../shared/lib/shell.sh

setup_shell() {
	shared_setup_etc_hosts
	setup_tools
	setup_doom_emacs
	setup_syncthing
}

setup_wakeonlan() {
	ip link
	nmcli c show
	sudo nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic
}

setup_tools() {
	sudo apt install -y \
		bash \
		curl \
		tmux \
		vim \
		ssh \
		dnscrypt-proxy \
		gnupg \
		git
	shared_setup_tools
	shared_setup_bashit
	shared_setup_ssh
	shared_setup_sshd
	setup_dnscrypt_proxy
	shared_setup_gnupg
	shared_setup_git
}

setup_doom_emacs() {
	sudo add-apt-repository ppa:ubuntu-elisp/ppa
	sudo apt update
	sudo apt install -y git \
		ripgrep \
		tar \
		fd-find \
		clang \
		emacs-snapshot
	shared_setup_doom_emacs
}

setup_syncthing() {
	sudo apt install -y syncthing
}

setup_dnscrypt_proxy() {
	sudo systemctl stop systemd-resolved
	sudo systemctl disable systemd-resolved
	sudo apt remove --purge -y resolvconf
	sudo rm -rf /etc/resolv.conf
	cat <<EOF | sudo tee /etc/resolv.conf
nameserver 127.0.2.1
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
