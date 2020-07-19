#!/usr/bin/env bash

. util.sh

sudo apt-get update
sudo apt-get install -y \
	nvidia-driver \
	libcuda1
sudo apt autoremove -y
sudo reboot
