#!/usr/bin/env bash

setup_cloud_native() {
  ignite_sysctl_net
  ignite_modprobe
  disable_swap
  setup_containerd
  setup_docker
  setup_cni
  ignite_setup_other_bin
  setup_ignite
  setup_footloose
  setup_wksctl
  setup_k8s
}

ignite_sysctl_net() {
  sudo mkdir -p /etc/sysctl.d/
  cat <<EOT | sudo bash -c "cat > /etc/sysctl.d/60-ignite.conf"
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=0
EOT
  sudo systemctl restart systemd-sysctl
}

ignite_modprobe() {
  sudo mkdir -p /etc/modules-load.d/
  cat <<EOT | sudo bash -c "cat > /etc/modules-load.d/ignite.conf"
loop
EOT
  modprobe -v loop
}

disable_swap() {
  swapcount=$(sudo grep '^/dev/\([0-9a-z]*\).*' /proc/swaps | wc -l)
  if [ "$swapcount" != "0" ]; then
    sudo systemctl mask "$(sed -n -e 's#^/dev/\([0-9a-z]*\).*#dev-\1.swap#p' /proc/swaps)" 2>/dev/null
  else
    echo "Swap not enabled"
  fi
}

setup_containerd() {
  sudo apt install -y containerd
  sudo systemctl enable --now containerd
}

setup_docker() {
  sudo apt install -y docker.io
  sudo systemctl enable --now docker

  distribution=$(
    . /etc/os-release
    echo "$ID$VERSION_ID"
  )
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  curl -s -L "https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list" | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  sudo apt update
  sudo apt install -y nvidia-container-runtime

  sudo docker info | grep nvidia
  cat <<EOT | sudo bash -c "cat > /etc/docker/daemon.json"
{
  "default-runtime": "nvidia",
  "runtimes": {
      "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
          }
    }
}
EOT
  sudo systemctl restart docker
  sudo docker run nvidia/cuda:10.2-base nvidia-smi
}

setup_cni() {
  CNI_VERSION=v0.8.5
  ARCH=$([ "$(uname -m)" = "x86_64" ] && echo amd64 || echo arm64)
  sudo mkdir -p /opt/cni/bin
  curl -sSL "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -xz -C /opt/cni/bin
  echo "export PATH=\"/opt/cni/bin:\$PATH\"" >>~/.bash_profile.local
}

ignite_setup_other_bin() {
  sudo apt install -y \
    mount \
    tar \
    e2fsprogs \
    binutils \
    dmsetup \
    openssh-client \
    git
}

setup_ignite() {
  VERSION=v0.6.3
  GOARCH=$(go env GOARCH 2>/dev/null || echo "amd64")
  BINARIES=(ignite ignited)
  mkdir -p /tmp/ignite
  for binary in "${BINARIES[@]}"; do
    curl -sfLo "/tmp/ignite/$binary" "https://github.com/weaveworks/ignite/releases/download/${VERSION}/${binary}-${GOARCH}"
    (cd /tmp/ignite && chmod +x "$binary" && sudo mv "$binary" /usr/local/bin)
  done
  ignite version
}

setup_footloose() {
  VERSION=0.6.3
  mkdir -p /tmp/footloose
  curl -sfLo /tmp/footloose/footloose https://github.com/weaveworks/footloose/releases/download/$VERSION/footloose-$VERSION-linux-x86_64
  (cd /tmp/footloose && chmod +x footloose && sudo mv footloose /usr/local/bin/)
  footloose version
}

setup_wksctl() {
  VERSION=0.8.2-beta.5
  mkdir -p /tmp/wksctl
  curl -sfLo /tmp/wksctl/wksctl.tar.gz https://github.com/weaveworks/wksctl/releases/download/v$VERSION/wksctl-$VERSION-linux-x86_64.tar.gz
  sudo mkdir -p /usr/local/etc/wksctl
  (cd /tmp/wksctl && tar xfz wksctl.tar.gz && chmod +x wksctl && sudo mv wksctl /usr/local/bin/ && sudo rm -rf /usr/local/etc/wksctl/examples && sudo mv -f examples/ /usr/local/etc/wksctl/)
  wksctl version
}

remove_ignite() {
  ignite rm -f "$(ignite ps -aq)"
  sudo rm -r /var/lib/firecracker
  sudo rm /usr/local/bin/ignite{,d}
}

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
