#!/usr/bin/env bash

. ../shared/lib/shell.sh

setup_tools() {
  sudo dnf install -y \
    vim-enhanced \
    podman-docker
  shared_setup_tools
  shared_setup_ssh
  shared_setup_gnupg
  shared_setup_git
  setup_nvidia_docker
}

setup_nvidia_docker() {
  curl -s -L https://nvidia.github.io/nvidia-docker/centos8/nvidia-docker.repo \
    | sudo tee /etc/yum.repos.d/nvidia-docker.repo
  sudo dnf install -y nvidia-container-toolkit
  cat <<EOF
[nvidia-container-cli]
no-cgroups = true
EOF
  read -r
  docker run -it --rm --security-opt=label=disable nvidia/cuda:10.2-base nvidia-smi
}