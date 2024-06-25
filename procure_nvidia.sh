#!/bin/bash

source ./procure_utils.sh

function installDrivers() {
  if checkStageCompleted "installDrivers"; then
    return 0;
  fi;
  set -e
  if ! nvidia-smi; then
    echo "nvidia-smi did not succeed, installing NVIDIA drivers..."

#    # from here: https://ubuntu.com/server/docs/nvidia-drivers-installation
#    sudo ubuntu-drivers install --gpgpu

    # this requires a reboot I think
    sudo apt-get update
    sudo apt install -y nvidia-driver-535
    sudo apt install -y nvidia-utils-535

    # reload modules
    sudo modprobe -rf nvidia_uvm nvidia_drm nvidia_modeset nvidia
  fi
  # verify drivers are installed
  if nvidia-smi; then
    echo "🎉 NVIDIA drivers installed successfully"
  else
    echo "❌ NVIDIA drivers not installed successfully"
    exit 1
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

  sudo apt-get install -y nvidia-container-toolkit
  sudo systemctl restart docker
  setStageCompleted "install"
}

function configure() {
  if checkStageCompleted "configure"; then
    return 0;
  fi;
  set -e
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
  setStageCompleted "configure"
}

function verify() {
  if checkStageCompleted "verify"; then
    return 0;
  fi;
  set -e
  # from here: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/sample-workload.html
  # verify docker has GPU access
  sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
  setStageCompleted "verify"
}

function main() {
  set -e
  setUp
  install
  configure
  verify
}

main