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


set -ea

function uninstall() {
  if checkStageCompleted "uninstall"; then
    return 0;
  fi;
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove $pkg || true;
  done
  setStageCompleted "uninstall"
}

function setUp() {
  if checkStageCompleted "setUp"; then
    return 0;
  fi;
  set -ea

  grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf

  sudo apt-get update || true;
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update || true;

  setStageCompleted "setUp"
}

function install() {
  if checkStageCompleted "install"; then
    return 0;
  fi;
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  setStageCompleted "install"
}

function verify() {
  if checkStageCompleted "verify"; then
    return 0;
  fi;
   sudo docker run hello-world
  setStageCompleted "verify"
}

function main() {
  uninstall
  setUp
  install
  verify
}

main
