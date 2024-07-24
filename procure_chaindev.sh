#!/bin/bash

source ./procure_utils.sh

progress_file=chaindev.json

function installKurtosis() {
  echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
  sudo apt update
  sudo apt install -y kurtosis-cli
}

function installRust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

function installFoundry() {
  curl -L https://foundry.paradigm.xyz | bash
  source ~/.zshenv && foundryup
}

function installToolchain() {
  sudo apt update
  sudo apt install -y libclang-dev pkg-config # yabadava
}

function main() {
  set -e
  xst installKurtosis
  xst installRust
  xst installFoundry
  xst installToolchain
}

main $1
