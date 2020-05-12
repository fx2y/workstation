#!/usr/bin/env bash

. ../shared/lib/devbox.sh

setup_devbox() {
  setup_conda
  shared_setup_rustup
  setup_asdf
  shared_setup_nodejs
  shared_setup_golang
  setup_elixir
  setup_jetbrains
}

# source: https://docs.conda.io/en/latest/miniconda.html
setup_conda() {
  shared_setup_conda
  conda install -y pytorch torchvision cudatoolkit=10.2 -c pytorch
}

setup_asdf() {
  sudo apt install -y \
    automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev \
    libxslt-dev libffi-dev libtool unixodbc-dev unzip curl
  shared_setup_asdf
}

# source: https://github.com/asdf-vm/asdf-erlang
# source: https://github.com/asdf-vm/asdf-elixir
setup_elixir() {
  sudo apt install -y \
    build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev \
    libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev \
    xsltproc fop
  export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
  shared_setup_elixir
}

setup_jetbrains() {
  JETBRAINS_VERSION=1.17.6856
  (cd /tmp && wget -qO jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-"$JETBRAINS_VERSION".tar.gz && tar -xvzf jetbrains-toolbox.tar.gz && rm jetbrains-toolbox.tar.gz)
  mkdir -p ~/opt/bin
  (cd /tmp && mv jetbrains-toolbox-"$JETBRAINS_VERSION"/jetbrain-toolbox ~/opt/bin && rm -rf jetbrains-toolbox-"$JETBRAINS_VERSION")
  echo "export PATH=\"\$HOME/opt/bin:\$PATH\"" >>~/.bash_profile.local
  export PATH="$HOME/opt/bin:$PATH"
  jetbrains-toolbox
  read -r
}
