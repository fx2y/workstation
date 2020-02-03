#!/usr/bin/env bash

. util.sh

function set_config() {
  sudo sed -i "s/^\($2\s*=\s*\).*\$/\1$3/" $1
}

sudo apt-get update
sudo apt-get install -y lz4

source /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=20 zswap.zpool=z3fold"
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off mitigations=off"
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT nowatchdog"
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT libahci.ignore_sss=1"
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3"
set_config /etc/default/grub GRUB_CMDLINE_LINUX_DEFAULT "\"${GRUB_CMDLINE_LINUX_DEFAULT}\""
set_config /etc/default/grub GRUB_TIMEOUT 0

cat <<EOF | sudo tee -a /etc/default/grub >/dev/null
GRUB_RECORDFAIL_TIMEOUT=${GRUB_TIMEOUT}
EOF

sudo update-grub

cat <<EOF | sudo tee /etc/sysctl.d/50-custom-workstation.conf >/dev/null
# Networking
## Improving performance
### Increasing the size of the receive queue
net.core.netdev_max_backlog = 100000
net.core.netdev_budget = 50000
net.core.netdev_budget_usecs = 5000

### Increase the maximum connections
net.core.somaxconn = 1024

### Increase the memory dedicated to the network interfaces
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

### Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

### Tweak the pending connection handling
net.ipv4.tcp_max_syn_backlog = 30000
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0

### Change TCP keepalive parameters
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

### Enable MTU probing
net.ipv4.tcp_mtu_probing = 1

### TCP Timestamps
net.ipv4.tcp_timestamps = 0

## TCP/IP stack hardening
### TCP SYN cookie protection
net.ipv4.tcp_syncookies = 1

### TCP rfc1337
net.ipv4.tcp_rfc1337 = 1

### Reverse path filtering
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

### Log martian packets
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.log_martians = 1

### Disable ICMP redirecting
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

### Enable Ignoring to ICMP Request
net.ipv4.icmp_echo_ignore_all = 1

## Other
### Allow unprivileged users to create IPPROTO_ICMP sockets
net.ipv4.ping_group_range = 100 100
net.ipv4.ping_group_range = 0 65535

# Virtual memory
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# MDADM
dev.raid.speed_limit_max = 10000
dev.raid.speed_limit_min = 1000
EOF

cat <<EOF | sudo tee -a /etc/sysctl.d/50-custom-workstation.conf >/dev/null

# Swap
## Swappiness
vm.swappiness=10
EOF

cat <<EOF | sudo tee /etc/udev/rules.d/10-network.rules >/dev/null
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", ATTR{mtu}="1500", ATTR{tx_queue_len}="2000"
EOF

cat <<EOF | sudo tee -a /etc/fstab >/dev/null
tmpfs   /tmp    tmpfs   noatime,rw,nodev,nosuid,size=2G 0   0
EOF

cat <<EOF | sudo tee -a /etc/sysctl.d/50-custom-workstation.conf >/dev/null

# Silent boot
kernel.printk = 3 3 3 3
EOF

sudo reboot
