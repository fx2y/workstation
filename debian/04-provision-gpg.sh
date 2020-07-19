#!/usr/bin/env bash

. util.sh

sudo apt-get update
sudo apt-get install -y \
	gnupg2 \
	gnupg-agent \
	openssh-client

echo "Disable your network connection."
read
gpg -K

cat <<EOF | tee ~/.gnupg/gpg.conf >/dev/null
personal-cipher-preferences AES256 AES192 AES
personal-digest-preferences SHA512 SHA384 SHA256
personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
cert-digest-algo SHA512
s2k-digest-algo SHA512
s2k-cipher-algo AES256
charset utf-8
fixed-list-mode
no-comments
no-emit-version
keyid-format 0xlong
list-options show-uid-validity
verify-options show-uid-validity
with-fingerprint
require-cross-certification
no-symkey-cache
throw-keyids
use-agent
EOF

echo "Insert your subkeys backup drive."
read
echo "Input the Device ID of your subkeys backup drive:"
read DEVICEID
sudo cryptsetup luksOpen ${DEVICEID}1 usb
sudo mkdir /mnt/encrypted-usb
sudo mount /dev/mapper/usb /mnt/encrypted-usb
gpg --import /mnt/encrypted-usb/sub.key
sudo umount /mnt/encrypted-usb
sudo cryptsetup luksClose usb
echo "Remove your subkeys backup drive."
read

echo "KEYID can be retrieved from 'rsa4096/xxx'. Please input your KEYID."
read LOCALKEYID
export KEYID=$LOCALKEYID

echo "gpg> trust"
echo "5 = I trust ultimately"
echo "gpg> passwd"
echo "gpg> quit"
gpg --expert --edit-key $KEYID

cat <<EOF | tee ~/.gnupg/gpg-agent.conf >/dev/null
enable-ssh-support
default-cache-ttl 60
max-cache-ttl 120
pinentry-program /usr/bin/pinentry-curses
EOF

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

echo 'export GPG_TTY="$(tty)"' >>~/.bashrc.local
echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >>~/.bashrc.local
echo 'gpgconf --launch gpg-agent' >>~/.bashrc.local

ssh-add -L

echo "Enable your network connection"
ssh git@github.com -vvv

echo "GPG Provision is completed"
