#!/bin/bash

progress_file=chaindev_setup.json

function checkStageCompleted() {
  stage=$1;
  if jq -e ".$stage" $progress_file > /dev/null 2>&1; then
    echo "✅ Stage: $stage already completed";
    return 0;
  fi;
  return 1;
};

function setStageCompleted() {
  stage=$1;
  if [ ! -f "$progress_file" ]; then
    echo "{}" > $progress_file;
  fi;
  jq ".$stage = true" $progress_file > "$progress_file.tmp";
  mv "$progress_file.tmp" "$progress_file";
};

function xst() {
  if [ -z "$progress_file" ]; then
    echo "❌ progress_file not set";
    return 1;
  fi;
  set -e;
  stage=`echo "$*" | sed "s/[^a-zA-Z0-9]/_/g"`;
  if checkStageCompleted $stage; then
    return 0;
  fi;
  echo "🚀 Executing stage: $stage";
  eval "$*";
  if [ $? -ne 0 ]; then
    echo "❌ Stage: $stage failed";
    return 1;
  fi;
  setStageCompleted $stage;
};
#!/bin/bash


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
