#!/bin/bash

progress_file="progress_nvidia.json"

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


function installDrivers() {
  if checkStageCompleted "installDrivers"; then
    return 0;
  fi;
  set -e
  if [ -z "`command -v nvidia-smi`" ] || \
    ! nvidia-smi --query-gpu=driver_version --format=csv,noheader | grep -q "555"; then
    echo "nvidia-smi did not succeed, installing NVIDIA drivers..."

    # install NVIDIA drivers (from here)
    # https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_network
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-5

    cuda_path='export PATH=$PATH:/usr/local/cuda-12.5/bin/';
    echo $cuda_path >> ~/.zshrc
    echo $cuda_path >> ~/.bashrc

    grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf

    # this requires a reboot I think
    sudo apt-get update
    sudo apt-get install -y libnvidia-common-555
    sudo apt-get install -y nvidia-driver-555-open
    sudo apt-get install -y cuda-drivers-555

    # reload modules
    sudo modprobe -rf nvidia_uvm nvidia_drm nvidia_modeset nvidia
  fi
  # verify drivers are installed
  if nvidia-smi; then
    echo "🎉 NVIDIA drivers installed successfully"
  else
    echo "❌ NVIDIA not-loaded: `uname -a`"
    if [ "$1" == "reboot" ]; then
      echo "Rebooting..."
      sudo reboot
    fi
    exit 1
  fi
  setStageCompleted "installDrivers"
}

function setUp() {
  if checkStageCompleted "setUp"; then
    return 0;
  fi;
  set -e

  installDrivers $1;

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

  sudo apt-get install -y nvidia-container-toolkit git-lfs
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
  setUp $1
  install
  configure
  verify
}

main $1
