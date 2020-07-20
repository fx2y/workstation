#!/usr/bin/env bash

setup_backup_disk() {
	echo "Input Device UUID: [/dev/disk/by-uuid/]"
	read -r DevID
	echo "Input Mount Path:"
	read -r MountPath
	cat <<EOF | sudo tee -a /etc/fstab >/dev/null
UUID=$DevID $MountPath btrfs nosuid,nodev,nofail,x-gvfs-show 0 0
EOF
}

setup_dnf_conf() {
	echo "Input Cache Dir: [/var/cache/dnf]"
	read -r CacheDir
	cat <<EOF | sudo tee /etc/dnf/dnf.conf >/dev/null
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
tsflags=nodocs
keepcache=True
fastestmirror=True
cachedir=$CacheDir
EOF
}

# https://rpmfusion.org/Configuration
setup_dnf() {
	sudo dnf install -y dnf-plugins-core
	sudo dnf install -y \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
	sudo dnf config-manager --set-enabled \
		rpmfusion-free-updates-testing \
		rpmfusion-nonfree-updates-testing \
		updates-testing \
		updates-testing-modular

	# https://brave-browser.readthedocs.io/en/latest/installing-brave.html
	sudo dnf config-manager --add-repo https://brave-browser-rpm-beta.s3.brave.com/x86_64/
	sudo rpm --import https://brave-browser-rpm-beta.s3.brave.com/brave-core-nightly.asc

	curl -s -L https://nvidia.github.io/nvidia-docker/centos8/nvidia-docker.repo |
		sudo tee /etc/yum.repos.d/nvidia-docker.repo
}

update_dnf() {
	sudo dnf update -y
	sudo dnf autoremove -y
}

setup_minimal_gui() {
	sudo dnf install -y @base-x \
		gnome-shell \
		gnome-terminal \
		bash-completion \
		gnome-tweaks \
		firefox \
		vim-enhanced
	sudo systemctl set-default graphical.target
}

# https://rpmfusion.org/Howto/NVIDIA
setup_nvidia() {
	sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
	sudo dnf autoremove -y
}

disable_intel_video() {
	sudo dnf remove -y xorg-x11-drv-intel
	sudo dnf autoremove -y
}
