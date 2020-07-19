#!/usr/bin/env bash

. util.sh

echo "Input Repository Mirror:"
read Mirror
Mirror=${Mirror:-"deb.debian.org"}

echo "Input OS Version Codename:"
read CodeName
CodeName=${CodeName:-$(
	. /etc/os-release
	echo $VERSION_CODENAME
)}

cat <<EOF | sudo tee /etc/apt/sources.list >/dev/null
deb [arch=amd64] http://${Mirror}/debian/ ${CodeName} main non-free contrib
deb [arch=amd64] http://security.debian.org/debian-security ${CodeName}/updates main contrib non-free
deb [arch=amd64] http://${Mirror}/debian/ ${CodeName}-updates main contrib non-free
deb [arch=amd64] http://${Mirror}/debian/ ${CodeName}-backports main contrib non-free
deb [arch=amd64] http://${Mirror}/debian/ ${CodeName}-proposed-updates main contrib non-free
EOF

sudo apt-get update
sudo apt-get upgrade -y
sudo apt autoremove -y
sudo reboot
