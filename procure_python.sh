#!/bin/bash

source ./procure_utils.sh

function install() {
  set -e
  grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update
  sudo apt install -y python3.11
}

function main() {
  set -e
  xst install
}

main
