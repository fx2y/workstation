#!/usr/bin/env bash
set -euo pipefail

setup_lookup() {
	sudo dnf install -y wordnet
}

setup_pdf() {
	# https://github.com/politza/pdf-tools
	sudo dnf install -y make automake autoconf gcc gcc-c++ ImageMagick libpng-devel zlib-devel poppler-glib-devel
}
