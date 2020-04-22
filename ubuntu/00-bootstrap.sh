#!/usr/bin/env bash

. functions.sh
. ../shared/runtime.sh

setup_apt
update_apt
sudo reboot
