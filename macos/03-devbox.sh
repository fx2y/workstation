#!/usr/bin/env bash

set -euxo pipefail

# dracula
mkdir -p ~/.dracula
git clone https://github.com/dracula/terminal-app.git ~/.dracula/terminal-app
mkdir -p ~/home
ln -s ~/.dracula ~/home/dracula

# spacemacs
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
cp ~/.emacs.d/core/templates/.spacemacs.template ~/.spacemacs
vi ~/.spacemacs
emacs --daemon

# curl
curl -o ~/.curlrc https://raw.githubusercontent.com/drduh/config/master/curlrc

# vim
curl -o ~/.vimrc https://raw.githubusercontent.com/drduh/config/master/vimrc

# gnupg
gpg -k
curl -o ~/.gnupg/gpg.conf https://raw.githubusercontent.com/drduh/config/master/gpg.conf
curl -o ~/.gnupg/gpg-agent.conf https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf
vi ~/.gnupg/gpg-agent.conf
mkdir -p ~/.ssh
curl -o ~/.ssh/config https://raw.githubusercontent.com/drduh/config/master/ssh_config

{
	# shellcheck disable=SC2016
	echo 'export GPG_TTY="$(tty)"'
	# shellcheck disable=SC2016
	echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)'
	echo 'gpgconf --launch gpg-agent'
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
gpg -o - -d "$DIR_BAK"/sub-"$KEYID".gpg | gpg --import
echo "Unmount Backup Disk"
read -r
gpg --list-secret-keys
gpg --expert --edit-key "$KEYID" # trust; 5 = I trust ultimately; quit
gpg -k --with-keygrip
echo "Read AuthID"
read -r AUTHID
echo "$AUTHID" >"$HOME"/.gnupg/sshcontrol
ssh-add -L >~/.ssh/github
echo "Enable Internet Connection and Mount Backup Disk"
read -r
ssh git@github.com -vvv

# git
curl -o ~/.gitconfig https://gist.githubusercontent.com/scottnonnenberg/fefa3f65fdb3715d25882f3023b31c29/raw/d7a219e40eb9a3e208f783185eeb01a55604f30f/.gitconfig
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

# asdf
ASDF_GOLANG=1.13.7
asdf plugin-add golang
asdf install golang $ASDF_GOLANG
asdf global golang $ASDF_GOLANG

ASDF_PYTHON=3.8.1
asdf plugin-add python
asdf install python $ASDF_PYTHON
asdf global python $ASDF_PYTHON

ASDF_NODEJS=13.7.0
asdf plugin-add nodejs
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs $ASDF_NODEJS
asdf global nodejs $ASDF_NODEJS

# rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path --profile complete --default-toolchain nightly --quiet -y
# shellcheck disable=SC2016
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>~/.bash_profile.local

# aliases
cat <<EOF >~/.aliases
#!/usr/bin/env bash

alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cask upgrade; brew cleanup; git -C ~/.emacs.d pull --rebase; asdf plugin-update --all; rustup self update; rustup self upgrade-data; rustup update; bash-it update'
EOF
echo '. ~/.aliases' >>~/.bash_profile.local

# spacemacs
## git
brew install git-flow-avh

## shell-scripts
brew install shellcheck
pip install bashate && asdf python reshim
npm i -g bash-language-server && asdf nodejs reshim
