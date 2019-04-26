#!/bin/zsh

function () {
  local keys=(
    "$HOME/.ssh/github_rsa" 
    "$HOME/.ssh/gitlab_rsa" 
    "$HOME/.ssh/duke_git_rsa" 
    "$HOME/.ssh/gcp-jp_rsa" 
    "$HOME/.ssh/nas_rsa"
    "$HOME/.ssh/nas-vm_rsa"
  )
  for key in $keys
  do
    if [ -f $key ]; then
      eval $(keychain --eval --quiet $key)
    fi
  done
}
