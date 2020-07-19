#!/usr/bin/env bash

# source: https://docs.conda.io/en/latest/miniconda.html
shared_setup_conda() {
	CONDA_OS=${1:-"Linux"} # Or, MacOSX
	wget -qO /tmp/conda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-"$CONDA_OS"-x86_64.sh
	(cd /tmp && bash conda.sh -b && rm conda.sh && ~/miniconda3/bin/conda init)
	export PATH="$HOME/miniconda3/bin:$PATH"
	cat <<EOF >>~/.condarc
channels:
  - pytorch
  - defaults
  - conda-forge
EOF
}

# source: https://rustup.rs
shared_setup_rustup() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path --default-toolchain beta --quiet -y
	echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>~/.bash_profile.local
	export PATH="$HOME/.cargo/bin:$PATH"
}

# source: https://asdf-vm.com/#/core-manage-asdf-vm
shared_setup_asdf() {
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
	echo '. "$HOME/.asdf/asdf.sh"' >>~/.bash_profile.local
	echo '. "$HOME/.asdf/completions/asdf.bash"' >>~/.bash_profile.local
	# shellcheck source=$HOME/.asdf/asdf.sh
	. "$HOME/.asdf/asdf.sh"
}

shared_setup_nodejs() {
	util_setup_asdf nodejs "bash $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring"
}

shared_setup_golang() {
	util_setup_asdf golang
}

shared_setup_elixir() {
	util_setup_asdf erlang
	util_setup_asdf elixir
}

util_setup_asdf() {
	asdf plugin add "$1"
	${2}
	util_update_asdf "$1"
}

util_update_asdf() {
	asdf list all "$1"
	echo "Read New $1 Version:"
	read -r ASDF_VERSION
	asdf install "$1" "$ASDF_VERSION"
	asdf global "$1" "$ASDF_VERSION"
}

util_delete_asdf() {
	asdf list "$1"
	echo "Read Old $1 Version:"
	read -r ASDF_VERSION
	asdf uninstall "$1" "$ASDF_VERSION"
}

shared_setup_lsp() {
	lsp_python
	lsp_rust
}

lsp_python() {
	pip install -U setuptools
	pip install 'python-language-server[all]'
	pip install pyls-mypy pyls-isort pyls-black
	pip install ptvsd
}

lsp_rust() {
	mkdir -p ~/.local/bin
	curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.local/bin/rust-analyzer
	chmod +x ~/.local/bin/rust-analyzer
	sudo apt install -y lldb-10 liblldb-10 liblldb-10-dev
	mkdir -p ~/.vscode/extensions/llvm-org.lldb-vscode-0.1.0/bin
	cp package.json ~/.vscode/extensions/llvm-org.lldb-vscode-0.1.0
	(cd ~/.vscode/extensions/llvm-org.lldb-vscode-0.1.0/bin && cp /usr/lib/llvm-10/lib/liblldb.so . && cp /usr/lib/llvm-10/bin/lldb-vscode .)
}
