#!/usr/bin/env bash

source ../shared/util.sh

UBUNTU_NAME=focal

setup_apt() {
	cat <<EOF | sudo tee /etc/apt/sources.list >/dev/null
deb http://id.archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME} main restricted universe multiverse
deb http://id.archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-updates main restricted universe multiverse
deb http://id.archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu/ ${UBUNTU_NAME} partner
deb http://security.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-security main restricted universe multiverse
deb http://id.archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-proposed main restricted universe multiverse
EOF
}

update_apt() {
	sudo apt update
	sudo apt upgrade --purge -y
	sudo apt autoremove --purge -y
	sudo apt full-upgrade --purge -y
	sudo apt-get dist-upgrade --purge -y
	sudo apt autoremove --purge -y
}

setup_mainline_kernel() {
	wget -P /tmp https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
	sudo install /tmp/ubuntu-mainline-kernel.sh /usr/local/bin/
	rm /tmp/ubuntu-mainline-kernel.sh
}

update_mainline_kernel() {
	ubuntu-mainline-kernel.sh -c
	read -r UNUSED_KERNEL
	ubuntu-mainline-kernel.sh -i --yes
	ubuntu-mainline-kernel.sh -u $UNUSED_KERNEL
}

delete_unused_kernel() {
	ubuntu-mainline-kernel.sh -l
	read -r UNUSED_KERNEL
	ubuntu-mainline-kernel.sh -u $UNUSED_KERNEL
}

set_config() {
	sudo sed -i "s/^\($2\s*=\s*\).*\$/\1$3/" $1
}

optim_kernel() {
	sudo apt install -y lz4

	GRUB_CMDLINE_LINUX_DEFAULT="zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=20 zswap.zpool=z3fold"
	GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT mitigations=off"
	GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT nowatchdog"
	GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT libahci.ignore_sss=1"
	GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3"

	set_config /etc/default/grub GRUB_CMDLINE_LINUX_DEFAULT "\"${GRUB_CMDLINE_LINUX_DEFAULT}\""
	set_config /etc/default/grub GRUB_TIMEOUT 0
	set_config /etc/default/grub GRUB_RECORDFAIL_TIMEOUT 0

	sudo update-grub
}

# https://wiki.archlinux.org/index.php/Sysctl#Improving_performance
optim_net_kernel() {
	cat <<EOF | sudo tee /etc/sysctl.d/99-optim-net.conf >/dev/null
# Increasing the size of the receive queue.
net.core.netdev_max_backlog = 16384

# (WARN) Increase the maximum connections
#net.core.somaxconn = 8192

# Increase the memory dedicated to the network interfaces
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

# Tweak the pending connection handling
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0

# Change TCP keepalive parameters
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# Enable MTU probing
net.ipv4.tcp_mtu_probing = 1

# (WARN) TCP timestamps
#net.ipv4.tcp_timestamps = 0

# Enable BBR
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr

# TCP SYN cookie protection
#net.ipv4.tcp_syncookies = 1

# TCP rfc1337
#net.ipv4.tcp_rfc1337 = 1

# Reverse path filtering
#net.ipv4.conf.default.rp_filter = 1
#net.ipv4.conf.all.rp_filter = 1

# (WARN) Log martian packets
#net.ipv4.conf.default.log_martians = 1
#net.ipv4.conf.all.log_martians = 1

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# (WARN) Ignore ICMP echo requests
#net.ipv4.icmp_echo_ignore_all = 1
#net.ipv6.icmp.echo_ignore_all = 1

# Allow unprivileged users to create IPPROTO_ICMP sockets
#net.ipv4.ping_group_range = 0 65535
EOF

	cat <<EOF | sudo tee /etc/udev/rules.d/10-network.rules >/dev/null
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", ATTR{mtu}="1500", ATTR{tx_queue_len}="2000"
EOF

	sudo mkdir -p /etc/modules-load.d
	cat <<EOF | sudo tee /etc/modules-load.d/99-optim-net.conf >/dev/null
br_netfilter
tcp_bbr
EOF
}

# https://wiki.archlinux.org/index.php/Sysctl#Virtual_memory
optim_vm_kernel() {
	cat <<EOF | sudo tee /etc/sysctl.d/99-optim-vm.conf >/dev/null
# (WARN) Virtual memory
#vm.dirty_ratio = 10
#vm.dirty_background_ratio = 5

# VFS cache
vm.vfs_cache_pressure = 50

# Fix small periodic system freezes
vm.dirty_background_bytes = 4194304
vm.dirty_bytes = 4194304

vm.swappiness = 10
EOF
}

optim_dev_kernel() {
	cat <<EOF | sudo tee /etc/sysctl.d/99-optim-dev.conf >/dev/null
dev.raid.speed_limit_max = 10000
dev.raid.speed_limit_min = 1000
EOF

	cat <<EOF | sudo tee /etc/modules-load.d/99-optim-dev.conf >/dev/null
md_mod
EOF

	cat <<EOF | sudo tee -a /etc/fstab >/dev/null
tmpfs   /tmp         tmpfs  noatime,rw,nodev,nosuid,size=16G    0   0
tmpfs   /var/lock    tmpfs  noatime,rw,nodev,nosuid,size=16G    0   0
tmpfs   /var/run     tmpfs  noatime,rw,nodev,nosuid,size=16G    0   0
EOF
}

optim_misc_kernel() {
	cat <<EOF | sudo tee /etc/sysctl.d/99-optim-misc.conf >/dev/null
kernel.printk = 3 3 3 3
EOF
}

setup_nvidia_driver() {
	sudo add-apt-repository ppa:graphics-drivers/ppa
	sudo ubuntu-drivers autoinstall
	sudo apt install -y nvidia-dkms-440
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
	shared_setup_gnupg
	shared_setup_git
}

setup_wakeonlan() {
	ip link
	nmcli c show
	sudo nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic
}

setup_microk8s() {
	sudo snap install microk8s --classic
	sudo usermod -a -G microk8s $USER
	sudo chown -f -R $USER ~/.kube
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

setup_asdf() {
	sudo apt install -y \
		automake autoconf libreadline-dev \
		libncurses-dev libssl-dev libyaml-dev \
		libxslt-dev libffi-dev libtool unixodbc-dev \
		unzip curl
	shared_setup_asdf
}

setup_dnscrypt_proxy() {
	sudo systemctl stop systemd-resolved
	sudo systemctl disable systemd-resolved
	sudo apt remove --purge -u resolvconf
	cat <<EOF | sudo tee /etc/resolv.conf
nameserver 127.0.2.1
options edns0
EOF
}

setup_brave() {
	sudo apt install -y apt-transport-https curl
	curl -s https://brave-browser-apt-beta.s3.brave.com/brave-core-nightly.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-prerelease.gpg add -
	echo "deb [arch=amd64] https://brave-browser-apt-beta.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-beta.list
	sudo apt update
	sudo apt install -y brave-browser-beta
}
