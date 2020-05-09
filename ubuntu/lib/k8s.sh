#!/usr/bin/env bash

setup_k8s() {
  sudo apt update
  sudo apt install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
  sudo apt update
  sudo apt install -y kubelet kubeadm kubectl
}

setup_open_ebs() {
  sudo apt install -y open-iscsi
  sudo systemctl enable iscsid && sudo systemctl start iscsid
  kubectl config set-context admin-ctx --cluster=$HOSTNAME --user=cluster-admin
  kubectl config use-context admin-ctx
}
