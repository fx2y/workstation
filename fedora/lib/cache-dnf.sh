#!/usr/bin/env bash

setup_cache_dnf_conf() {
	cat <<EOF | sudo tee /etc/dnf/dnf.conf >/dev/null
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
tsflags=nodocs,test
keepcache=True
fastestmirror=True
EOF
}

container_runtime() {
	podman run -it --rm -v $(pwd):/home:Z -v $HOME/archive/cache:/var/cache:Z -w /home docker.io/fedora bash
}

cache_dnf() {
	sudo dnf install -y \
		@base-x \
		gnome-shell \
		gnome-terminal \
		bash-completion \
		gnome-tweaks \
		firefox \
		vim-enhanced \
		akmod-nvidia xorg-x11-drv-nvidia-cuda \
		chrome-gnome-shell brave-browser-beta \
		open-sans-fonts julietaula-montserrat-fonts lato-fonts adobe-source-sans-pro-fonts \
		vernnobile-nunito-fonts adobe-source-serif-pro-fonts paratype-pt-serif-fonts paratype-pt-sans-fonts \
		ibm-plex-mono-fonts ibm-plex-sans-fonts google-roboto-mono-fonts google-roboto-slab-fonts \
		google-roboto-fonts \
		git ripgrep tar fd-find clang multimarkdown ShellCheck \
		dnscrypt-proxy \
		java-latest-openjdk golang nodejs \
		moby-engine docker-compose podman podman-compose slirp4netns \
		bcc sysstat \
		nvidia-container-toolkit \
		kubernetes-client
	sudo dnf group install -y "Development Tools"
	sudo dnf builddep -y emacs
}
