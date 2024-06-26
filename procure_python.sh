#!/bin/bash

source ./procure_utils.sh

function install() {
  if checkStageCompleted "install"; then
    return 0;
  fi;
  set -e
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update
  sudo apt install -y python3.11
  setStageCompleted "install"
}

function main() {
  set -e
  install
}

main
