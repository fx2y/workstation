#!/usr/bin/env bash

. functions.sh
. ../shared/runtime.sh

optim_kernel
optim_net_kernel
optim_vm_kernel
optim_dev_kernel
optim_misc_kernel
sudo reboot
