#!/bin/bash

function gitritual() {
    cp ~/.ssh/config.ritual ~/.ssh/config
    ssh-add -D
    ssh-add ~/.ssh/ritual
    git config --global user.email "arshan.khanifar@ritual.co"
    git config --global user.name "Arshan Khanifar"
}

function gitorigin() {
    cp ~/.ssh/config.origin ~/.ssh/config
    ssh-add -D
    ssh-add ~/.ssh/origin
    git config --global user.email "arshan.khanifar@originprotocol.com"
    git config --global user.name "Arshan Khanifar"
}

function gitpersonal() {
    cp ~/.ssh/config.personal ~/.ssh/config
    ssh-add -D
    ssh-add ~/.ssh/personal
    git config --global user.email "arshankhanifar@gmail.com"
    git config --global user.name "Arshan Khanifar"
}

# qcom: "this is a quick commit"
function qcom() {
    git commit -am "$1"
}

# qcomp: "this is a quick commit & push"
function qcomp() {
    git commit -am "$1" && git push
}
