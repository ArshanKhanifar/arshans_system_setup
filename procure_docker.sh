#!/bin/bash

source ./procure_utils.sh

set -ea

function uninstall() {
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove $pkg || true;
  done
}

function setUp() {
  set -e

  # skip restart prompt
  if [ -f "/etc/needrestart/needrestart.conf" ]; then
    grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf
  fi

  sudo apt-get update || true;
  sudo apt-get install -y ca-certificates curl jq
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update || true;
}

function install() {
  set -e;
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;
}

function verify() {
  set -e;
  # user's already added to docker group, but it won't take effect until next login
  # at this stage we'll just verify that docker is working
  sudo docker run hello-world
}

function main() {
  # installing jq, needed for stage utils
  if [ -z "`command -v jq`" ]; then
    sudo apt-get install -y jq
  fi
  xst uninstall
  xst setUp
  xst install
  sudo usermod -aG docker $USER
  xst verify
}

main
