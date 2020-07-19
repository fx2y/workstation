#!/usr/bin/env bash

cache_dnf() {
	sudo dnf update -y --downloadonly
	sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda --downloadonly
	sudo dnf install -y gnome-tweaks --downloadonly
	sudo dnf install -y dnf-plugins-core --downloadonly
	sudo dnf install -y open-sans-fonts julietaula-montserrat-fonts lato-fonts adobe-source-sans-pro-fonts \
		vernnobile-nunito-fonts adobe-source-serif-pro-fonts paratype-pt-serif-fonts paratype-pt-sans-fonts \
		ibm-plex-mono-fonts ibm-plex-sans-fonts google-roboto-mono-fonts google-roboto-slab-fonts \
		google-roboto-fonts --downloadonly
	sudo dnf group install -y "Development Tools" --downloadonly
	sudo dnf builddep -y emacs --downloadonly
	sudo dnf install -y git ripgrep tar fd-find clang multimarkdown ShellCheck --downloadonly
	sudo dnf install -y vim-enhanced --downloadonly
	sudo dnf install -y java-latest-openjdk golang-bin nodejs --downloadonly
	sudo dnf install -y moby-engine docker-compose podman podman-compose --downloadonly
	sudo dnf install -y kubernetes-client --downloadonly
}
