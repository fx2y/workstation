#!/usr/bin/env bash

. util.sh

ERLANG_VERSION=22.1.6
ELIXIR_VERSION=1.9.4-otp-22
PYTHON_VERSION=3.8.0
MINICONDA_VERSION="miniconda3-latest"
NODEJS_VERSION=13.1.0
GOLANG_VERSION=1.13.4
JAVA_ZULU_VERSION=8.0.232-zulu

sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
sh -c 'cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)"'
echo -e '\n. $HOME/.asdf/asdf.sh' >>~/.bashrc.local
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >>~/.bashrc.local

# Erlang
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop
asdf plugin-add erlang
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
asdf install erlang ${ERLANG_VERSION}
asdf global erlang ${ERLANG_VERSION}

# Elixir
sudo apt-get install unzip
asdf plugin-add elixir
asdf install elixir ${ELIXIR_VERSION}
asdf global elixir ${ELIXIR_VERSION}

# Python
asdf plugin-add python
asdf install python ${PYTHON_VERSION}
asdf global python ${PYTHON_VERSION}
asdf install python ${MINICONDA_VERSION}

# NodeJS
sudo apt-get -y install dirmngr gpg
asdf plugin-add nodejs
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs ${NODEJS_VERSION}
asdf global nodejs ${NODEJS_VERSION}

# Golang
sudo apt-get -y install curl
asdf plugin-add golang
asdf install golang ${GOLANG_VERSION}
asdf global golang ${GOLANG_VERSION}

# SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java ${JAVA_ZULU_VERSION}

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile complete --default-toolchain nightly
