#!/usr/bin/env bash

. functions.sh
. ../shared/runtime.sh

setup_mainline_kernel
update_mainline_kernel
sudo reboot
