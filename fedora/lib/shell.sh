#!/usr/bin/env bash

. ../shared/lib/shell.sh

setup_shell() {
  shared_setup_etc_hosts
  setup_tools
  setup_doom_emacs
}
