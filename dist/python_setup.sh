#!/bin/bash

progress_file="progress_python.json"

function checkStageCompleted() {
  stage=$1
  if jq -e ".$stage" $progress_file > /dev/null 2>&1; then
    echo "✅ Stage: $stage already completed";
    return 0;
  fi;
  return 1;
}

function setStageCompleted() {
  stage=$1
  if [ ! -f $progress_file ]; then
    echo "{}" > $progress_file;
  fi;
  jq ".$stage = true" $progress_file > "$progress_file.tmp";
  mv "$progress_file.tmp" "$progress_file";
}
#!/bin/bash


function install() {
  if checkStageCompleted "install"; then
    return 0;
  fi;
  set -e
  sudo add-apt-repository ppa:deadsnakes/ppa
  sudo apt-get update
  sudo apt install -y python3.11
  setStageCompleted "install"
}

function main() {
  set -e
  install
}

main
