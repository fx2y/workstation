#!/usr/bin/env bash

set -euxo pipefail
sudo -s

# Prerequisites
sudo swupd bundle-add openssh-server

# Change default port
sudo systemctl edit sshd.socket

#[Socket]
#ListenStream=
#ListenStream=4200

cat /etc/systemd/system/sshd.socket.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart sshd.socket
sudo systemctl status sshd.socket
