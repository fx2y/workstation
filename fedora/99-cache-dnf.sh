#!/usr/bin/env bash

. ../shared/runtime.sh
. functions.sh

setup_dnf_conf
setup_dnf
update_dnf
setup_cache_dnf_conf
cache_dnf
