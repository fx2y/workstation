#!/usr/bin/env bash

setup_lang_go() {
	sudo dnf install -y golang-bin golang-x-tools-guru golang-x-tools-goimports
	GO111MODULE=on go get github.com/motemen/gore/cmd/gore
	GO111MODULE=on go get github.com/cweill/gotests/...
	GO111MODULE=on go get github.com/fatih/gomodifytags
	GO111MODULE=on go get github.com/mdempsky/gocode

	GO111MODULE=on go get golang.org/x/lint/golint
	GO111MODULE=on go get github.com/kisielk/errcheck
	GO111MODULE=on go get github.com/mdempsky/unconvert
	GO111MODULE=on go get honnef.co/go/tools/cmd/staticcheck

	sudo dnf install -y nodejs golang-x-tools-gopls
	GO111MODULE=on go get github.com/go-delve/delve/cmd/dlv
	echo "export PATH=\"\$PATH:\$HOME/go/bin/\"" >>~/.bashrc
	export PATH="$PATH:$HOME/go/bin/"
}

setup_lang_javascript() {
	sudo dnf install -y npm
	mkdir -p ~/node
	(cd ~/node && npm init -y)
	echo "export PATH=\"\$PATH:\$HOME/node/node_modules/.bin\"" >>~/.bashrc
	(
		cd ~/node/
		npm install prettier \
			eslint jshint standard semistandard \
			javascript-typescript-langserver \
			typescript-language-server typescript
	)
}

setup_lang_json() {
	sudo dnf install -y jq
	(
		cd ~/node/
		npm install jsonlint prettier \
			vscode-json-languageserver
	)
}

setup_lang_markdown() {
	pip install -U --user grip
	sudo dnf install -y marked multimarkdown pandoc
	(
		cd ~/node/
		npm install markdownlint-cli prettier
	)
}

setup_lang_org() {
	sudo dnf install -y gnuplot \
		pandoc
}

setup_lang_plantuml() {
	sudo dnf install -y plantuml
}

setup_lang_python() {
	sudo dnf install -y \
		conda \
		pipenv \
		poetry \
		python3 \
		python3-devel
	sudo dnf install -y \
		python3-Cython \
		python3-ipython \
		python3-isort \
		python3-jupyter-core \
		python3-nose \
		python3-notebook \
		python3-pytest \
		python3-setuptools
	# conda
	conda init bash
	# pyenv
	curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
	{
		echo "export PATH=\"\$HOME/.pyenv/bin:\$PATH\""
		echo "eval \"\$(pyenv init -)\""
		echo "eval \"\$(pyenv virtualenv-init -)\""
	} >>~/.bashrc
	export PATH="$HOME/.pyenv/bin:$PATH"
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	# pip global
	pip install -U --user \
		'python-language-server[all]' pyls-mypy pyls-isort pyls-black \
		ptvsd
	sudo dnf install -y \
		python3-pyflakes \
		python3-flake8 \
		python3-mypy \
		pylint \
		black
}

setup_lang_ruby() {
	sudo dnf install -y jruby ruby ruby-devel rubygem-railties rubygems
	gem install debase \
		reek \
		rubocop \
		ruby-debug-ide \
		ruby-lint \
		rufo \
		solargraph
	# chruby
	(
		cd /tmp
		wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
		tar -xzvf chruby-0.3.9.tar.gz
		cd chruby-0.3.9/
		sudo make install
		cd /tmp
		rm -rf /tmp/chruby-0.3.9
		echo "source /usr/local/share/chruby/chruby.sh" >>~/.bashrc
		source /usr/local/share/chruby/chruby.sh
	)
	# rbenv
	(
		echo "export PATH=\"\$PATH:\$HOME/.rbenv/bin\"" >>~/.bashrc
		export PATH="$PATH:$HOME/.rbenv/bin"
		curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
		echo "eval \"\$(rbenv init -)\"" >>~/.bashrc
		eval "$(rbenv init -)"
		curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
	)
	# rvm
	(
		gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
		sudo dnf install -y bison libtool libyaml-devel readline-devel openssl-devel
		curl -sSL https://get.rvm.io | bash -s stable --rails
	)
}

setup_lang_rust() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain beta --quiet -y
	export PATH="$HOME/.cargo/bin:$PATH"
	# lsp rust-analyzer
	rustup component add rust-src
	mkdir -p ~/.local/bin
	curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.local/bin/rust-analyzer
	chmod +x ~/.local/bin/rust-analyzer
	# lldb-vscode
	sudo dnf install -y lldb lldb-devel
	mkdir -p ~/.vscode/extensions/llvm-org.lldb-vscode-0.1.0/bin
	cp package.json ~/.vscode/extensions/llvm-org.lldb-vscode-0.1.0
	(
		cd ~/.vscode/extensions/llvm-org.lldb-vscode-0.1.0/bin
		cp /usr/bin/lldb-vscode .
		cp /usr/lib64/liblldb.so .
	)
}

setup_lang_sh() {
	sudo dnf install -y ShellCheck
	(cd ~/node && npm install bash-language-server)
	GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt
}

setup_lang_web() {
	sudo dnf install -y tidy csslint jq
	(
		cd ~/node/
		npm install js-beautify \
			stylelint stylelint-config-standard \
			jsonlint prettier \
			vscode-css-languageserver-bin \
			vscode-html-languageserver-bin \
			vscode-json-languageserver
	)
}

setup_lang_yaml() {
	sudo dnf install -y nodejs-js-yaml yamllint
	(
		cd ~/node/
		nmp install prettier yaml-language-server
	)
}
