#!/usr/bin/env bash

set_config() {
	sudo sed -i "s/^\($2\s*=\s*\).*\$/\1$3/" "$1"
}
