#!/usr/bin/env bash

. functions.sh
. lib/ignite.sh

setup_wakeonlan
setup_tools
setup_doom_emacs

setup_conda
shared_setup_rust
setup_asdf
setup_ignite

setup_jetbrains
setup_brave
