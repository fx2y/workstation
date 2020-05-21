#!/usr/bin/env bash

setup_desktop() {
  setup_brave
  setup_gnome
  setup_font

  sudo apt install -y fbreader
}

setup_sound_wire() {
  sudo apt install -y pavucontrol libportaudio2 libqt5widgets5
  (cd /tmp && wget -q http://georgielabs.altervista.org/SoundWire_Server_linux64.tar.gz && tar -xvzf SoundWire_Server_linux64.tar.gz && rm SoundWire_Server_linux64.tar.gz)
  mkdir -p ~/opt/bin && mkdir -p ~/.local/share/icons
  (cd /tmp/SoundWireServer && mv SoundWireServer ~/opt/bin && mv sw-icon.xpm ~/.local/share/icons && sudo mv SoundWire-Server.desktop /usr/share/applications && sudo chmod 644 /usr/share/applications/SoundWire-Server.desktop && cd /tmp && rm -rf SoundWireServer)
  SoundWireServer
  read -r
}

setup_brave() {
  sudo apt install -y apt-transport-https curl
  curl -s https://brave-browser-apt-beta.s3.brave.com/brave-core-nightly.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-prerelease.gpg add -
  echo "deb [arch=amd64] https://brave-browser-apt-beta.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-beta.list
  sudo apt update
  sudo apt install -y brave-browser-beta
  echo "alias chrome='brave-browser-beta --incognito --disable-font-subpixel-positioning'" >>~/.bash_profile.local
  cat <<EOF
  # sudo vi /usr/share/applications/brave-browser-beta.desktop
  # Exec=brave-browser-beta --incognito --disable-font-subpixel-positioning
EOF
  read -r
}

setup_gnome() {
  sudo apt install -y gnome-shell-extension-autohidetopbar
  gsettings set org.gnome.desktop.interface enable-animations false
}

setup_font() {
  sudo apt install -y fonts-noto
  echo "Read Windows Fonts Directory: [/media/$USER/EMPTIED/WindowsFonts]"
  read -r FONTS_BAK
  sudo mkdir -p /usr/share/fonts/WindowsFonts
  sudo cp "$FONTS_BAK"/* /usr/share/fonts/WindowsFonts/
  (cd /usr/share/fonts/WindowsFonts && sudo cp ./*.ttf ./*.TTF /usr/share/fonts/truetype/)
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
  fc-cache -f
  cat <<EOF
# Tweaks > Auto Hide Top Bar: True
#        > Font > Hinting: Slight
#               > Anti-aliasing: Subpixel
#               > Interface: Noto Sans Display Regular, 10
#               > Document: Noto Serif Regular, 11
#               > Monospace: Noto Mono Regular, 13
#               > Window: Noto Sans Display Regular, 11
# Jetbrains > Settings > Editor > Font > Jetbrains Mono, 18, Line spacing: 1.4
EOF
  read -r
}
