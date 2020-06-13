#!/usr/bin/env bash

. ./lib/desktop.sh

# https://rpmfusion.org/Configuration
setup_dnf() {
	sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf config-manager --set-enabled rpmfusion-free-updates-testing rpmfusion-nonfree-updates-testing updates-testing updates-testing-modular
	sudo dnf update -y
}

# https://rpmfusion.org/Howto/NVIDIA
setup_nvidia() {
	sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
}

# SHELL

# https://dreameh.dev/blog/emacs-fedora-31
setup_emacs() {
	mkdir -p ~/git
	sudo dnf builddep -y emacs &
	(cd ~/git && git clone https://github.com/emacs-mirror/emacs.git --branch emacs-27) &
	wait
}

update_emacs() {
	(cd ~/git/emacs && git pull --rebase && ./autogen.sh && ./configure && make && sudo make install)
}

# https://github.com/hlissner/doom-emacs/blob/develop/docs/getting_started.org#fedora
setup_doom_emacs() {
	setup_emacs
	update_emacs &
	sudo dnf install -y git ripgrep tar fd-find clang multimarkdown ShellCheck &
	git clone https://github.com/hlissner/doom-emacs ~/.emacs.d --branch develop &
	wait
	~/.emacs.d/bin/doom install
}

update_doom_emacs() {
	~/.emacs.d/bin/doom upgrade
}
