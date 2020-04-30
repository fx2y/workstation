#!/usr/bin/env bash

. functions.sh
. ../shared/runtime.sh
. lib/ignite.sh

setup_wakeonlan
setup_tools
setup_doom_emacs

setup_conda
shared_setup_rustup
setup_asdf
setup_microk8s

setup_jetbrains
setup_brave
setup_gnome
