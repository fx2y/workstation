#!/usr/bin/env bash

. util.sh

sudo apt update
sudo apt install -y \
	git \
	hub \
	icdiff

cat <<EOF | tee ~/.gitconfig >/dev/null
[alias]
  prune = fetch --prune
  # Because I constantly forget how to do this
  # https://git-scm.com/docs/git-fetch#git-fetch--p

  undo = reset --soft HEAD^
  # Not quite as common as an amend, but still common
  # https://git-scm.com/docs/git-reset#git-reset-emgitresetemltmodegtltcommitgt

  stash-all = stash save --include-untracked
  # We wanna grab those pesky un-added files!
  # https://git-scm.com/docs/git-stash

  glog = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
  # No need for a GUI - a nice, colorful, graphical representation
  # https://git-scm.com/docs/git-log
  # via https://medium.com/@payload.dd/thanks-for-the-git-st-i-will-use-this-4da5839a21a4

[merge]
  ff = only
  # I pretty much never mean to do a real merge, since I use a rebase workflow.
  # Note: this global option applies to all merges, including those done during a git pull
  # https://git-scm.com/docs/git-config#git-config-mergeff

  conflictstyle = diff3
  # Standard diff is two sets of final changes. This introduces the original text before each side's changes.
  # https://git-scm.com/docs/git-config#git-config-mergeconflictStyle

[commit]
  gpgSign = true
  # "other people can trust that the changes you've made really were made by you"
  # https://help.github.com/articles/about-gpg/
  # https://git-scm.com/docs/git-config#git-config-commitgpgSign

[push]
  default = simple
  # "push the current branch back to the branch whose changes are usually integrated into the current branch"
  # "refuse to push if the upstream branch’s name is different from the local one"
  # https://git-scm.com/docs/git-config#git-config-pushdefault

  followTags = true
  # Because I get sick of telling git to do it manually
  # https://git-scm.com/docs/git-config#git-config-pushfollowTags

[status]
  showUntrackedFiles = all
  # Sometimes a newly-added folder, since it's only one line in git status, can slip under the radar.
  # https://git-scm.com/docs/git-config#git-config-statusshowUntrackedFiles

[transfer]
  fsckobjects = true
  # To combat repository corruption!
  # Note: this global option applies during receive and transmit
  # https://git-scm.com/docs/git-config#git-config-transferfsckObjects
  # via https://groups.google.com/forum/#!topic/binary-transparency/f-BI4o8HZW0


# A nice little github-like colorful, split diff right in the console.
# via http://owen.cymru/github-style-diff-in-terminal-with-icdiff/
[diff]
  tool = icdiff
[difftool]
  prompt = false
[difftool "icdiff"]
  cmd = /usr/local/bin/icdiff --line-numbers $LOCAL $REMOTE

[branch "master"]
  mergeoptions = --no-ff

EOF

echo "Git User Email: "
read GitUserEmail
echo "Git User Name: "
read GitUserName

git config --global user.email $GitUserEmail
git config --global user.name $GitUserName

echo "Git Provision is Completed..."
