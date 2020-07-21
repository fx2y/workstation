#!/usr/bin/env bash

. ../shared/lib/shell.sh

setup_tools() {
	shared_setup_etc_hosts
	shared_setup_tools
	shared_setup_bashit
	shared_setup_ssh
	shared_setup_gnupg
	shared_setup_git
	setup_observability
	setup_devbox
}

setup_devbox() {
	sudo dnf install -y java-latest-openjdk-devel java-latest-openjdk golang nodejs
	echo 'export GOPATH="$HOME/go"' >>~/.bash_profile.local
	echo 'export PATH="$PATH:$GOPATH/bin/"' >>~/.bash_profile.local
}

setup_kind() {
	curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
	chmod +x /tmp/kind
	sudo mv /tmp/kind /usr/local/bin

	kind create cluster
	#sudo KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name kind-podman

	sudo dnf install -y kubernetes-client
	kubectl cluster-info --context kind-kind
	#kubectl cluster-info --context kind-kind-podman
}

presetup_docker() {
	sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
	sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
	sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
}

setup_docker() {
	sudo dnf install -y moby-engine docker-compose podman podman-compose
	sudo systemctl enable --now docker
	sudo usermod -aG docker $USER
}

setup_nvidia_docker() {
	docker run -it --rm hello-world
	podman run -it --rm docker.io/hello-world

	sudo dnf install -y nvidia-container-toolkit
	cat <<EOF
# /etc/nvidia-container-runtime/config.toml
[nvidia-container-cli]
no-cgroups = true
EOF
	read -r

	podman system migrate
	podman run -it --rm --security-opt=label=disable docker.io/nvidia/cuda:10.2-base nvidia-smi
}

setup_observability() {
	sudo dnf install -y bcc sysstat
}
