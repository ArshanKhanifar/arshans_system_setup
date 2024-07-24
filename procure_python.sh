#!/bin/bash

source ./procure_utils.sh

if [ "$runtime" = "docker" ]; then
  sudo() { "$@"; }
  echo "sudo command not found, using direct execution."
fi

function install() {
  set -e
  if ! [ "$runtime" = "docker" ]; then
    grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf;
  fi
  sudo apt-get update && sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update
  sudo apt install -y python3.11
}

function main() {
  # installing jq, needed for stage utils
  if [ -z "`command -v jq`" ]; then
    sudo apt-get install -y jq
  fi
  set -e
  xst install
}

main
