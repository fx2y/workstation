#!/usr/bin/env bash

. ../util.sh

sudo apt-get update
sudo apt-get install -y \
     gnupg2 \
     secure-delete

export GNUPGHOME=$(mktemp -d)

cat <<EOF | tee $GNUPGHOME/gpg.conf >/dev/null
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

echo "Please Disable networking for the remainder of the setup..."; read

echo "Please select what kind of key you want: (8) RSA (set your own capabilities)"
echo "(E) Toggle the encrypt capability"
echo "(S) Toggle the sign capability"
echo "(Q) Finished"
echo "RSA keys may be between 1024 and 4096 bits long. What keysize do you want? (2048) 4096"
echo "Please specify how long the key should be valid. Key is valid for? 0 = key does not expire"
gpg --expert --full-generate-key

echo "KEYID can be retrieved from 'rsa4096/xxx'. Please input your KEYID."; read LOCALKEYID
export KEYID=$LOCALKEYID

echo "gpg> addkey"
echo "Please select what kind of key you want: (4) RSA (sign only)"
echo "What keysize do you want? (2048) 4096"
echo "Key is valid for? (0) 1y"
echo "gpg> addkey"
echo "Please select what kind of key you want: (6) RSA (encrypt only)"
echo "What keysize do you want? (2048) 4096"
echo "Key is valid for? (0) 1y"
echo "gpg> addkey"
echo "Please select what kind of key you want: (8) RSA (set your own capabilities)"
echo "(S) Toggle the sign capability"
echo "(E) Toggle the encrypt capability"
echo "(A) Toggle the authenticate capability"
echo "Current allowed actions: Authenticate"
echo "What keysize do you want? (2048) 4096"
echo "Key is valid for? (0) 1y"
echo "gpg> save"
gpg --expert --edit-key $KEYID

gpg -K

gpg --armor --export-secret-keys $KEYID > $GNUPGHOME/mastersub.key
gpg --armor --export-secret-subkeys $KEYID > $GNUPGHOME/sub.key

# === Create an encrypted backup of the keyring ===

# Attach another external storage device and check its label:
sudo dmesg | tail
echo "Input Device ID: (/dev/sdb)"; read DEVICEID

# Write it with random data to prepare for encryption:
sudo dd if=/dev/urandom of=$DEVICEID bs=4M status=progress

# Erase and create a new partition table:
echo "Command (m for help): o"
echo "Command (m for help): w"
sudo fdisk $DEVICEID

# Create a new partition with a 10 Megabyte size:
echo "Command (m for help): n"
echo "Last sector, +sectors or +size{K,M,G,T,P} (2048-62980095, default 62980095): +10M"
echo "Command (m for help): w"
sudo fdisk $DEVICEID

# Use LUKS to encrypt the new partition:
sudo cryptsetup luksFormat ${DEVICEID}1

# Mount the partition:
sudo cryptsetup luksOpen ${DEVICEID}1 usb

# Create a filesystem:
sudo mkfs.ext2 /dev/mapper/usb -L usb

# Mount the filesystem and copy the temporary directory with the keyring:
sudo mkdir /mnt/encrypted-usb
sudo mount /dev/mapper/usb /mnt/encrypted-usb
sudo cp -avi $GNUPGHOME /mnt/encrypted-usb

# Unmount and disconnected the encrypted volume:
sudo umount /mnt/encrypted-usb
sudo cryptsetup luksClose usb

# Create another partition to store the public key
echo "Command (m for help): n"
echo "Last sector, +sectors or +size{K,M,G,T,P} (22528-31116287, default 31116287): +10M"
echo "Command (m for help): w"
sudo fdisk $DEVICEID
sudo mkfs.ext2 ${DEVICEID}2
sudo mkdir /mnt/public
sudo mount ${DEVICEID}2 /mnt/public/
gpg --armor --export $KEYID | sudo tee /mnt/public/$KEYID-$(date +%F).txt

# Reboot or securely delete $GNUPGHOME and remove the secret keys from the GPG keyring:
sudo srm -r $GNUPGHOME || sudo rm -rf $GNUPGHOME
gpg --delete-secret-key $KEYID

echo "Creating GPG Keys Completed"
sudo reboot
