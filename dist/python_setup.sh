#!/bin/bash

progress_file=python_setup.json

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

if ! which sudo 2>&1 > /dev/null; then
  sudo() { "$@"; }
  echo "sudo command not found, using direct execution."
fi
#!/bin/bash


if [ "$runtime" = "docker" ]; then
  sudo() { "$@"; }
  echo "sudo command not found, using direct execution."
fi

function install() {
  set -e
  if ! [ "$runtime" = "docker" ] && [ -f "/etc/needrestart/needrestart.conf" ]; then
    grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf;
  fi
  sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt-get update -y && sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt-get install -y software-properties-common
  sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 add-apt-repository -y ppa:deadsnakes/ppa
  sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt install -y python3.11
}

function main() {
  # installing jq, needed for stage utils
  if [ -z "`command -v jq`" ]; then
    sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt-get install -y jq
  fi
  set -e
  xst install
}

main
