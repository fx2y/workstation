#!/usr/bin/env bash

. util.sh

# Prerequisites
sudo apt-get update
sudo apt-get install -y \
  gnome-core \
  wget

# Firefox Beta
sudo apt-get install -y wget
FIREFOX_VERSION="70.0b4"
wget --quiet https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2 -O /tmp/firefox.tar.bz2
tar xjvf /tmp/firefox.tar.bz2 -C /tmp
sudo mv /tmp/firefox/ /opt/
rm /tmp/firefox.tar.bz2

cat <<EOF | sudo tee /usr/share/applications/firefox-beta.desktop >/dev/null
[Desktop Entry]
Name=Firefox Beta
Comment=Web Browser
GenericName=Web Browser
X-GNOME-FullName=Firefox Beta Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=Firefox
StartupNotify=true
EOF

sudo ln -s /opt/firefox/firefox /usr/local/bin/
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
sudo update-alternatives --set x-www-browser /opt/firefox/firefox
rsync -avr conf/opt/firefox/ /opt/firefox

# [CanvasBlocker](https://addons.mozilla.org/en-US/firefox/addon/canvasblocker/)
# [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)
# [Cookie AutoDelete](https://addons.mozilla.org/en-US/firefox/addon/cookie-autodelete/)
# [HTTPS EVERYWHERE](https://www.eff.org/files/https-everywhere-latest.xpi)
# [Decentraleyes](https://addons.mozilla.org/firefox/addon/decentraleyes/)
# [Terms of Service; Didn't Read](https://addons.mozilla.org/en-US/firefox/addon/terms-of-service-didnt-read/)
# [Privacy Badger](https://www.eff.org/privacybadger)
# [ClearURLs](https://addons.mozilla.org/en-US/firefox/addon/clearurls/)
# [Neat URL](https://addons.mozilla.org/en-US/firefox/addon/neat-url/)
# [Bitwarden](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/)
# [Org Capture](https://addons.mozilla.org/en-US/firefox/addon/org-capture/)
# [Invidition](https://addons.mozilla.org/en-US/android/addon/invidition/)
# [Bypass Paywalls](https://github.com/iamadamdev/bypass-paywalls-firefox)
# [Cookie Remover](https://addons.mozilla.org/en-US/firefox/addon/cookie-remover/)
# [Tree Style Tab](https://addons.mozilla.org/en-US/firefox/addon/tree-style-tab/)

# Visual Studio Code Insiders
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y code-insiders
