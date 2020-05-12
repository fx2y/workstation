#!/usr/bin/env bash

UBUNTU_NAME=focal

disable_snap() {
  # Remove existing Snaps
  snap list
  sudo snap remove snap-store
  sudo snap remove gtk-common-themes
  sudo snap remove gnome-3-34-1804
  sudo snap remove core18
  # Unmount the snap core service
  df
  echo "Snap ID:"
  read -r SNAP_ID
  sudo unmount "/snap/core/$SNAP_ID"
  # Remove and purge the snapd package
  sudo apt purge -y snapd
  # Remove any lingering snap directories
  rm -rf ~/snap
  sudo rm -rf /snap
  sudo rm -rf /var/snap
  sudo rm -rf /var/lib/snapd
}

setup_apt() {
  wget -qO - mirrors.ubuntu.com/mirrors.txt
  echo "Ubuntu Mirror:"
  read -r UBUNTU_MIRROR
  cat <<EOF | sudo tee /etc/apt/sources.list >/dev/null
deb ${UBUNTU_MIRROR} ${UBUNTU_NAME} main restricted universe multiverse
deb ${UBUNTU_MIRROR} ${UBUNTU_NAME}-updates main restricted universe multiverse
deb ${UBUNTU_MIRROR} ${UBUNTU_NAME}-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu/ ${UBUNTU_NAME} partner
deb http://security.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-security main restricted universe multiverse
deb ${UBUNTU_MIRROR} ${UBUNTU_NAME}-proposed main restricted universe multiverse
EOF
  update_apt
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
  sudo ubuntu-mainline-kernel.sh -i --yes
}

update_mainline_kernel() {
  ubuntu-mainline-kernel.sh -c
  read -r NEW_KERNEL
  sudo ubuntu-mainline-kernel.sh -i "$NEW_KERNEL" --yes
}

delete_old_kernel() {
  apt list --installed | grep linux-image
  echo "Linux Kernel: [5.4.0-26]"
  read -r OLD_KERNEL
  sudo apt remove --purge -y linux-headers-"$OLD_KERNEL" linux-modules-"$OLD_KERNEL"-generic
}

setup_nvidia_driver() {
  sudo add-apt-repository ppa:graphics-drivers/ppa
  sudo ubuntu-drivers autoinstall
}
