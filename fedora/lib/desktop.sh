#!/usr/bin/env bash

setup_desktop() {
	setup_gsettings
	setup_firefox
	setup_brave
	setup_font
	setup_droidcam
}

setup_firefox() {
	echo "Read Firefox Profile Directory (about:profiles):"
	read -r FF_DIR
	(
		cd "$FF_DIR" || exit
		curl -sSLo updater.sh https://raw.githubusercontent.com/ghacksuserjs/ghacks-user.js/master/updater.sh
		touch user-overrides.js
		bash updater.sh -s -u -b
		wget https://12bytes.org/wp-content/downloads/search.json.mozlz4.zip
		mv search.json.mozlz4 search.json.mozlz4.backup
		unzip search.json.mozlz4.zip
		rm search.json.mozlz4.zip
	)
	echo "Further Hardening: https://github.com/ghacksuserjs/ghacks-user.js/wiki#small_orange_diamond-further-hardening"
	echo "Install Bitwarden: https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
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
	sudo dnf install -y gnome-tweaks
	# Disable Animation
	gsettings set org.gnome.desktop.interface enable-animations false
	# Night Light
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
	gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 23.99
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
	# Fonts
	gsettings set org.gnome.settings-daemon.plugins.xsettings hinting 'slight'
	gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'
	gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
	gsettings set org.gnome.desktop.interface font-name 'Open Sans 10'
	gsettings set org.gnome.desktop.interface document-font-name 'Source Serif Pro 11'
	gsettings set org.gnome.desktop.interface monospace-font-name 'IBM Plex Mono 13'
	gsettings get org.gnome.desktop.wm.preferences titlebar-font 'Open Sans 11'
}

setup_jetbrains() {
	JETBRAINS_VERSION=1.17.7234
	(
		cd /tmp || exit
		wget -qO jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-"$JETBRAINS_VERSION".tar.gz
		tar -xvzf jetbrains-toolbox.tar.gz
		rm jetbrains-toolbox.tar.gz
		mkdir -p ~/.local/bin
		cd jetbrains-toolbox-"$JETBRAINS_VERSION" || exit
		mv jetbrains-toolbox ~/.local/bin
		cd ..
		rm -rf jetbrains-toolbox-"$JETBRAINS_VERSION"
	)
	jetbrains-toolbox
	read -r
}

setup_font() {
	sudo dnf install -y open-sans-fonts julietaula-montserrat-fonts lato-fonts adobe-source-sans-pro-fonts \
		vernnobile-nunito-fonts adobe-source-serif-pro-fonts paratype-pt-serif-fonts paratype-pt-sans-fonts \
		ibm-plex-mono-fonts ibm-plex-sans-fonts google-roboto-mono-fonts google-roboto-slab-fonts \
		google-roboto-fonts
	echo "Read Windows Fonts Directory: [/media/$USER/EMPTIED/WindowsFonts]"
	read -r FONTS_BAK
	sudo mkdir -p /usr/share/fonts/WindowsFonts
	sudo cp "$FONTS_BAK"/* /usr/share/fonts/WindowsFonts/
	sudo chmod 644 /usr/share/fonts/WindowsFonts/*
	cat <<EOF | sudo tee -a /etc/fonts/conf.d/30-metric-aliases-free.conf >/dev/null
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
       <alias binding="same">
         <family>Helvetica</family>
         <accept>
         <family>Arial</family>
         </accept>
       </alias>
       <alias binding="same">
         <family>Times</family>
         <accept>
         <family>Times New Roman</family>
         </accept>
       </alias>
       <alias binding="same">
         <family>Courier</family>
         <accept>
         <family>Courier New</family>
         </accept>
       </alias>
</fontconfig>
EOF
	sudo fc-cache -f
}

# https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux#h_825b50ac-ad15-44a8-9959-28c97e4803ef
setup_zoom() {
	(
		cd /tmp/
		wget -q https://d11yldzmag5yn.cloudfront.net/prod/5.1.422789.0705/zoom_x86_64.rpm
		wget -qO package-signing-key.pub https://zoom.us/linux/download/pubkey
		sudo rpm --import package-signing-key.pub
		sudo dnf localinstall -y zoom_x86_64.rpm
		rm zoom_x86_64.rpm package-signing-key.pub
	)
}

# https://www.dev47apps.com/droidcam/linux/
setup_droidcam() {
	(
		cd /tmp/
		wget https://files.dev47apps.net/linux/droidcam_latest.zip
		echo "73db3a4c0f52a285b6ac1f8c43d5b4c7 droidcam_latest.zip" | md5sum -c --
		unzip droidcam_latest.zip -d droidcam && cd droidcam
		sudo ./install
		lsmod | grep v4l2loopback_dc
		cd /tmp
		rm -rf droidcamp_latest.zip droidcam
	)
}
