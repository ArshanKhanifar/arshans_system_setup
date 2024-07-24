#!/bin/bash

source ./procure_utils.sh

function installHelm() {
    # install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod 700 get_helm.sh && ./get_helm.sh
}

function installNvidiaHelmRepo() {
    if helm repo list | grep -q nvidia; then
      echo "nvidia repo already exists. skipping..."
    else
        helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
    fi

    helm repo update
}

function installToolkit() {
    # install NVIDIA drivers (from here)
    # https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_network
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-5

    cuda_path='export PATH=$PATH:/usr/local/cuda-12.5/bin/';
    echo $cuda_path >> ~/.zshrc
    echo $cuda_path >> ~/.bashrc
}

function installNvidiaDrivers() {
    # this requires a reboot I think
    sudo apt-get update
    sudo apt-get install -y libnvidia-common-555
    sudo apt-get install -y nvidia-driver-555-open
    sudo apt-get install -y cuda-drivers-555
}

function installDrivers() {
  set -e
  if [ -z "`command -v nvidia-smi`" ] || \
    ! nvidia-smi --query-gpu=driver_version --format=csv,noheader | grep -q "555"; then
    echo "nvidia-smi did not succeed, installing NVIDIA drivers..."

    xst installToolkit

    # skip restart prompt
    if [ -f "/etc/needrestart/needrestart.conf" ]; then
      grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf
    fi

    xst installNvidiaDrivers

    xst installHelm

    xst installNvidiaHelmRepo

    # reload modules
    sudo modprobe -rf nvidia_uvm nvidia_drm nvidia_modeset nvidia
  fi
  # verify drivers are installed
  if nvidia-smi --query-gpu=driver_version --format=csv,noheader | grep -q "555"; then
    echo "🎉 NVIDIA drivers installed successfully"
  else
    echo "❌ NVIDIA not loaded: `uname -a`"
    if [ "$1" == "reboot" ]; then
      echo "Rebooting..."
      sudo reboot
    fi
    exit 1
  fi
}

function setUp() {
  set -e
  xst installDrivers $1;

  # Install container toolkit
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt-get update
}

function install() {
  set -e
  sudo apt-get install -y nvidia-container-toolkit git-lfs jq
  sudo systemctl restart docker
}

function configure() {
  set -e
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo nvidia-ctk runtime configure --runtime=containerd
  sudo systemctl restart docker
  sudo systemctl restart containerd
}

function verify() {
  set -e
  # from here: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/sample-workload.html
  # verify docker & containerd have GPU access
  # docker
  sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
  # containerd
  sudo ctr image pull docker.io/library/ubuntu:latest
  sudo ctr run --rm --gpus 0 -t docker.io/library/ubuntu:latest wagwan nvidia-smi
}

function main() {
  set -e
  # installing jq, needed for stage utils
  if [ -z "`command -v jq`" ]; then
    sudo apt-get install -y jq
  fi
  xst setUp $1
  xst install
  xst configure
  xst verify
}

main $1
