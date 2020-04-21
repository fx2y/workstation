#!/usr/bin/env bash

set -euo pipefail

shared_setup_tools() {
  wget -qO ~/.curlrc https://raw.githubusercontent.com/drduh/config/master/curlrc
  wget -qO ~/.tmux.conf https://raw.githubusercontent.com/drduh/config/master/tmux.conf
  wget -qO ~/.vimrc https://raw.githubusercontent.com/drduh/config/master/vimrc
}

shared_setup_ssh() {
  mkdir -p ~/.ssh
  wget -qO ~/.ssh/config https://raw.githubusercontent.com/drduh/config/master/ssh_config
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

# source: https://docs.conda.io/en/latest/miniconda.html
shared_setup_conda() {
  CONDA_OS=${1:-"Linux"}
  wget -qO /tmp/conda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-"$CONDA_OS"-x86_64.sh
  (cd /tmp && bash conda.sh -b && ~/miniconda3/bin/conda init)
  echo "export PATH=\"\$HOME/miniconda3/bin:\$PATH\"" >>~/.bash_profile.local
}

# source: https://github.com/Bash-it/bash-it
shared_setup_bashit() {
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  ~/.bash_it/install.sh --silent
  BASH_LOCAL="$HOME/.bash_profile.local"
  if [ -f ~/.bashrc ]; then
    BASH_LOCAL="$HOME/.bashrc.local"
  fi
  touch "$BASH_LOCAL"
  cat <<EOF >>"$BASH_LOCAL"
. ~/.bash_profile.local
EOF
  sudo chsh -s "$(command -v bash)" "$USER"
}

shared_setup_gnupg() {
  gpg -k
  wget -qO ~/.gnupg/gpg.conf https://raw.githubusercontent.com/drduh/config/master/gpg.conf
  wget -qO ~/.gnupg/gpg-agent.conf https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf
  shared_setup_ssh
  {
    echo "export GPG_TTY=\"\$(tty)\""
    echo "export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)"
    echo "gpgconf --launch gpg-agent"
  } >>~/.bash_profile.local

  GPG_TTY="$(tty)"
  export GPG_TTY
  SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  export SSH_AUTH_SOCK
  gpgconf --launch gpg-agent

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
  gpg --expert --edit-key "$KEYID" # trust; 5 = I trust ultimately; quit
  gpg -k --with-keygrip
  echo "Read AuthID"
  read -r AUTHID
  echo "$AUTHID" >"$HOME"/.gnupg/sshcontrol
  gpg --output ~/.ssh/github --export-ssh-key "$KEYID"
  echo "Enable Internet Connection and Mount Backup Disk"
  read -r
  ssh git@github.com -vvv
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
}

# source: https://github.com/hlissner/doom-emacs/blob/develop/docs/getting_started.org
shared_setup_doom_emacs() {
  git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
  ~/.emacs.d/bin/doom install
  vi ~/.doom.d/init.el
  ~/.emacs.d/bin/doom upgrade
  echo -e "export PATH=\"\$HOME/.emacs.d/bin:\$PATH\"" >>~/.bash_profile.local
}

# source: https://asdf-vm.com/#/core-manage-asdf-vm
shared_setup_asdf() {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
  echo -e ". $HOME/.asdf/asdf.sh" >>~/.bash_profile.local
  echo -e ". $HOME/.asdf/completions/asdf.bash" >>~/.bash_profile.local
  # shellcheck source=$HOME/.asdf/asdf.sh
  . "$HOME/.asdf/asdf.sh"

  asdf plugin add nodejs
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  asdf list all nodejs
  echo "Read NodeJS Version"
  read -r ASDF_NODEJS
  asdf install nodejs "$ASDF_NODEJS"
  asdf global nodejs "$ASDF_NODEJS"

  asdf plugin add golang
  asdf list all golang
  echo "Read Golang Version"
  read -r ASDF_GOLANG
  asdf install golang "$ASDF_GOLANG"
  asdf global golang "$ASDF_GOLANG"
}

# source: https://rustup.rs
shared_setup_rustup() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path --default-toolchain beta --quiet -y
  echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >>~/.bash_profile.local
}
