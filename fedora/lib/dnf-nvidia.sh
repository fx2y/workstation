#!/usr/bin/env bash

# https://rpmfusion.org/Configuration
setup_dnf() {
	sudo dnf install -y \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
	sudo dnf config-manager --set-enabled \
		rpmfusion-free-updates-testing \
		rpmfusion-nonfree-updates-testing \
		updates-testing \
		updates-testing-modular
	sudo dnf update -y
	sudo dnf autoremove -y
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
