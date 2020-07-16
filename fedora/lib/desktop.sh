#!/usr/bin/env bash

setup_desktop() {
	sudo dnf install -y gnome-tweaks
	setup_gsettings
	setup_firefox
	setup_brave
}

setup_firefox() {
	echo "Read Firefox Profile Directory (about:profiles):"
	read -r FF_DIR
	(
		cd "$FF_DIR" || exit
		curl -sSLo updater.sh https://raw.githubusercontent.com/ghacksuserjs/ghacks-user.js/master/updater.sh
		touch user-overrides.js
		bash updater.sh -ub
	)
	echo "Further Hardening: https://github.com/ghacksuserjs/ghacks-user.js/wiki#small_orange_diamond-further-hardening"
	echo "Install Bitwarden: https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
	echo "Install Hide Top Bar: https://extensions.gnome.org/extension/545/hide-top-bar/"
	echo "Install Hide Top Panel: https://extensions.gnome.org/extension/740/hide-top-panel/"
	read -r
}

# https://brave-browser.readthedocs.io/en/latest/installing-brave.html
setup_brave() {
  sudo dnf install -y dnf-plugins-core
  sudo dnf config-manager --add-repo https://brave-browser-rpm-beta.s3.brave.com/x86_64/
  sudo rpm --import https://brave-browser-rpm-beta.s3.brave.com/brave-core-nightly.asc
  sudo dnf install -y brave-browser-beta
}

setup_gsettings() {
  # Disable Animation
  gsettings set org.gnome.desktop.interface enable-animations false
	# Night Light
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 23.99
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
}
