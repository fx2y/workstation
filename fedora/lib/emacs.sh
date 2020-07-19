#!/usr/bin/env bash

# https://dreameh.dev/blog/emacs-fedora-31
setup_emacs() {
	mkdir -p ~/git
	sudo dnf group install -y "Development Tools"
	sudo dnf builddep -y emacs
	(cd ~/git && git clone --depth 1 -b emacs-27 https://github.com/emacs-mirror/emacs.git --single-branch)
}

update_emacs() {
	(cd ~/git/emacs && git pull --rebase && ./autogen.sh && ./configure && make && sudo make install)
}

# https://github.com/hlissner/doom-emacs/blob/develop/docs/getting_started.org#fedora
setup_doom_emacs() {
	setup_emacs
	update_emacs
	sudo dnf install -y git ripgrep tar fd-find clang multimarkdown ShellCheck
	git clone --depth 1 -b develop https://github.com/hlissner/doom-emacs ~/.emacs.d --single-branch
	~/.emacs.d/bin/doom install
}

update_doom_emacs() {
	~/.emacs.d/bin/doom upgrade
}
