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
