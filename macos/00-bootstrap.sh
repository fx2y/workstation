#!/usr/bin/env bash

set -euxo pipefail

sudo scutil --set ComputerName macOS
sudo scutil --set LocalHostName macOS

sudo pmset -a destroyfvkeyonstandby 1
sudo pmset -a hibernatemode 25
sudo pmset -a powernap 0
sudo pmset -a standby 0
sudo pmset -a standbydelay 0
sudo pmset -a autopoweroff 0

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
sudo pkill -HUP socketfilterfw

sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

TMP1b="$(
  defaults read com.apple.Spotlight.plist orderedItems |
    awk '/^ {8}/{printf$0}!/^ {8}/{print}'
)"
TMP2b="$(
  echo "$TMP1b" |
    sed '
         s|\(.*\)= 1\(.*MENU_SPOTLIGHT_SUGGESTIONS.*\)|\1= 0\2|;
         s|\(.*\)= 1\(.*MENU_DEFINITION.*\)|\1= 0\2|;
         s|\(.*\)= 1\(.*MENU_CONVERSION.*\)|\1= 0\2|;
    '
)"
defaults delete com.apple.Spotlight orderedItems
defaults write com.apple.Spotlight orderedItems "$TMP2b"

defaults write com.apple.Safari UniversalSearchEnabled -bool NO
defaults write com.apple.Safari SuppressSearchSuggestions -bool YES
defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool NO

defaults write com.apple.SafariTechnologyPreview UniversalSearchEnabled -bool NO
defaults write com.apple.SafariTechnologyPreview SuppressSearchSuggestions -bool YES
defaults write com.apple.SafariTechnologyPreview WebsiteSpecificSearchEnabled -bool NO

defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US"
