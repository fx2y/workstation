#!/usr/bin/env bash

. lib/shell.sh
. lib/devbox.sh

set_config() {
  sudo sed -i "s/^\($2\s*=\s*\).*\$/\1$3/" "$1"
}
