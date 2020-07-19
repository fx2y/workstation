#!/usr/bin/env bash

shared_setup_etc_hosts() {
	sudo mv /etc/hosts /etc/hosts.backup
	wget -qO - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts | sudo tee /etc/hosts >/dev/null
	cat </etc/hosts.backup | sudo tee -a /etc/hosts >/dev/null
}

shared_setup_tools() {
	wget -qO ~/.curlrc https://raw.githubusercontent.com/drduh/config/master/curlrc
	wget -qO ~/.tmux.conf https://raw.githubusercontent.com/drduh/config/master/tmux.conf
	wget -qO ~/.vimrc https://raw.githubusercontent.com/drduh/config/master/vimrc
}

shared_setup_ssh() {
	chmod go-w ~
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	wget -qO ~/.ssh/config https://raw.githubusercontent.com/drduh/config/master/ssh_config
	chmod 600 ~/.ssh/*
	chown -R "$USER" ~/.ssh
}

shared_setup_ssh_access() {
	ssh-keygen -t ed25519 -C "$WS_USER" -f "$HOME/.ssh/$WS_HOSTNAME"
	ssh-copy-id -i "$HOME/.ssh/$WS_HOSTNAME" -p "$WS_PORT" "$WS_USER@$WS_IP"
}

shared_setup_sshd() {
	ssh-keygen -t ed25519 -f /tmp/ssh_host_key -C '' -N ''
	sudo mv /tmp/ssh_host_key /tmp/ssh_host_key.pub /etc/ssh/
	sudo chown root:root /etc/ssh/ssh_host_key /etc/ssh/ssh_host_key.pub
	sudo chmod 0600 /etc/ssh/ssh_host_key
	wget -qO - https://raw.githubusercontent.com/drduh/config/master/sshd_config | sudo tee /etc/ssh/sshd_config >/dev/null
	sudo systemctl restart ssh
}

# source: https://github.com/Bash-it/bash-it
shared_setup_bashit() {
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
	~/.bash_it/install.sh --silent
	BASH_DIR="$HOME/.bash_profile"
	if [ -f ~/.bashrc ]; then
		BASH_DIR="$HOME/.bashrc"
	fi
	cat <"$BASH_DIR" | tee -a "$BASH_DIR".bak >/dev/null
	mv "$BASH_DIR".bak "$BASH_DIR"
	touch ~/.bash_profile.local
	cat <<EOF >>"$BASH_DIR"
. ~/.bash_profile.local
EOF
	if command -v chsh; then sudo chsh -s "$(command -v bash)" "$USER"; fi
}

shared_setup_gnupg() {
	gpg -k
	wget -qO ~/.gnupg/gpg.conf https://raw.githubusercontent.com/drduh/config/master/gpg.conf
	wget -qO ~/.gnupg/gpg-agent.conf https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf
	vi ~/.gnupg/gpg-agent.conf
	shared_setup_ssh
	{
		echo 'export GPG_TTY="$(tty)"'
		echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)'
		echo "gpgconf --launch gpg-agent"
		echo "gpg-connect-agent updatestartuptty /bye >/dev/null"
	} >>~/.bash_profile.local

	GPG_TTY="$(tty)"
	export GPG_TTY
	SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
	export SSH_AUTH_SOCK
	gpgconf --launch gpg-agent
	gpg-connect-agent updatestartuptty /bye >/dev/null

	echo "Disable Internet Connection and Mount Backup Disk"
	read -r
	echo "Read KeyID"
	read -r KEYID
	echo "Read Backup Directory"
	read -r DIR_BAK
	gpg -o - -d "${DIR_BAK}/sub-${KEYID}.gpg" | gpg --import
	echo "Unmount Backup Disk"
	read -r
	gpg --list-secret-keys
	gpg --expert --edit-key "$KEYID" # trust; 5 = I trust ultimately; passwd; quit

	gpg -k --with-keygrip
	echo "Read AuthID"
	read -r AUTHID
	echo "$AUTHID" >"$HOME"/.gnupg/sshcontrol

	gpg --output ~/.ssh/github --export-ssh-key "$KEYID"
	chmod 600 ~/.ssh/github
	ssh-add -L

	echo "Enable Internet Connection and Mount Backup Disk"
	read -r

	#ssh git@github.com -vvv
}

shared_setup_git() {
	wget -qO ~/.gitconfig https://gist.githubusercontent.com/scottnonnenberg/fefa3f65fdb3715d25882f3023b31c29/raw/d7a219e40eb9a3e208f783185eeb01a55604f30f/.gitconfig
	cat <<EOF >>~/.gitconfig

[branch "master"]
  mergeoptions = --no-ff
EOF

	gpg -K
	echo "Read User Email"
	read -r USEREMAIL
	echo "Read User Name"
	read -r USERNAME
	git config --global user.email "$USEREMAIL"
	git config --global user.name "$USERNAME"
	wget -qO ~/.gitignore_global https://www.toptal.com/developers/gitignore/api/intellij+all,emacs,linux,macos
	git config --global core.excludesfile ~/.gitignore_global
}

# source: https://github.com/hlissner/doom-emacs/blob/develop/docs/getting_started.org
shared_setup_doom_emacs() {
	git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
	~/.emacs.d/bin/doom install
	vi ~/.doom.d/init.el
	~/.emacs.d/bin/doom upgrade
	echo 'export PATH="$HOME/.emacs.d/bin:$PATH"' >>~/.bash_profile.local
}
