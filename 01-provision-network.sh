#!/usr/bin/env bash

. util.sh

sudo apt-get update
sudo apt-get install -y curl

echo "=== Installing Hosts... ==="
curl https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts | sudo tee /etc/hosts >/dev/null
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts >/dev/null

echo "=== Installing DNSCrypt... ==="

echo "1. check what else is possibly already listening to port 53"
ss -lp 'sport = :domain'

echo "2. install and run dnscrypt-proxy"
sudo apt-get install -y dnscrypt-proxy

echo "3. mask (disable) systemd-resolve"
sudo systemctl stop systemd-resolved
sudo systemctl mask systemd-resolved
ss -lp 'sport = :domain'

echo "4. change the system DNS settings"
cat <<EOF | sudo tee /etc/resolv.conf
nameserver 127.0.2.1
options edns0 single-request-reopen
EOF

echo "5. lock system DNS settings. to unlock it run `sudo chattr -i /etc/resolv.conf`"
sudo chattr +i /etc/resolv.conf

echo "6. test"
sudo /usr/sbin/dnscrypt-proxy -resolve github.com

echo "=== Installing Privoxy... ==="
sudo apt-get update
sudo apt install -y privoxy

echo 'export http_proxy="http://localhost:8118"' >> ~/.bashrc.local
echo 'export https_proxy="$http_proxy"' >> ~/.bashrc.local

sudo reboot
