#!/bin/bash

function gitritual() {
  cp ~/.ssh/config.ritual ~/.ssh/config;
  ssh-add -D;
  email="arshan@ritual.net"
  git config --global user.name 'arshan-ritual';
  git config --global user.email $email;
  signing_key=`gpg --list-keys | grep -B 1 $email | head -n 1 | xargs`
  git config --global --replace-all user.signingkey $signing_key;
}

function gitorigin() {
  cp ~/.ssh/config.origin ~/.ssh/config;
  ssh-add -D;
  email="arshan+origin@ritual.net"
  git config --global user.name 'arshan-origin';
  git config --global user.email $email;
  signing_key=`gpg --list-keys | grep -B 1 $email | head -n 1 | xargs`
  git config --global --replace-all user.signingkey $signing_key;
}

function gitpersonal() {
  cp ~/.ssh/config.personal ~/.ssh/config;
  ssh-add -D;
  email="arshankhanifar@gmail.com"
  git config --global user.name 'arshankhanifar';
  git config --global user.email $email;
  signing_key=`gpg --list-keys | grep -B 1 $email | head -n 1 | xargs`
  git config --global --replace-all user.signingkey $signing_key;
}

# qcom: "this is a quick commit"
function qcom() {
    git commit -am "$1"
}

# qcomp: "this is a quick commit & push"
function qcomp() {
    git commit -am "$1" && git push
}

# gb: pretty list of branches sorted by most recent
function gb() {
    git for-each-ref --sort=-committerdate refs/heads/ \
        --format='%(color:yellow)%(refname:short)%(color:reset)|%(color:green)%(committerdate:relative)%(color:reset)|%(color:cyan)%(authorname)%(color:reset)|%(contents:subject)' \
        | column -t -s '|' \
        | head -20
}

# gbv: visual graph of all branches showing relationships
function gbv() {
    git log --graph --all --oneline --decorate \
        --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr)%C(reset) %C(cyan)<%an>%C(reset)' \
        -30
}

# gbs: interactively select and checkout a branch using fzf
function gbs() {
    local branch=$(git for-each-ref --sort=-committerdate refs/heads/ \
        --format='%(refname:short)|%(committerdate:relative)|%(authorname)|%(contents:subject)' \
        | column -t -s '|' \
        | fzf --ansi --preview 'git log --color=always --oneline --graph -10 $(echo {} | awk "{print \$1}")' \
        | awk '{print $1}')
    
    if [ -n "$branch" ]; then
        git checkout "$branch"
    fi
}
