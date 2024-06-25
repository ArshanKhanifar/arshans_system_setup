#!/bin/bash

progress_file="progress.json"

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

source ./procure_utils.sh


function installDrivers() {
  if checkStageCompleted "installDrivers"; then
    return 0;
  fi;
  set -e
  if ! nvidia-smi; then
    echo "nvidia-smi did not succeed, installing NVIDIA drivers..."
    sudo apt-get -y install nvidia-driver-470
  fi
  setStageCompleted "installDrivers"
}

function setUp() {
  if checkStageCompleted "setUp"; then
    return 0;
  fi;
  set -e

  installDrivers;

  # Install container toolkit
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt-get update

  setStageCompleted "setUp"
}

function install() {
  if checkStageCompleted "install"; then
    return 0;
  fi;
  set -e
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit
  sudo systemctl restart docker
  setStageCompleted "install"
}

function verify() {
  if checkStageCompleted "verify"; then
    return 0;
  fi;
  set -e

  setStageCompleted "verify"
}

function main() {
  set -e
  uninstall
  setUp
  install
  verify
}

main
