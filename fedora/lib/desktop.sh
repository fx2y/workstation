#!/usr/bin/env bash

setup_desktop() {
	sudo dnf install -y gnome-tweaks
}

setup_firefox() {
	echo "Read Firefox Profile Directory (about:profiles):"
	read -r FF_DIR
	(
		cd "$FF_DIR" || exit
		curl -sSLo updater.sh https://raw.githubusercontent.com/ghacksuserjs/ghacks-user.js/master/updater.sh
		touch user-overrides.js
		bash updater.sh
	)
	echo "Further Hardening: https://github.com/ghacksuserjs/ghacks-user.js/wiki#small_orange_diamond-further-hardening"
	echo "Install Bitwarden: https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
	echo "Install Hide Top Bar: https://extensions.gnome.org/extension/545/hide-top-bar/"
	read -r
}

setup_gsettings() {
	# Night Light
	gsettings set get org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 23.99
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
}
