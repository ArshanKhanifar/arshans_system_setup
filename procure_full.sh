#!/bin/bash

function main() {
  bash -c "`curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/system_setup.sh`"
  bash -c "`curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/python_setup.sh`"
  bash -c "`curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/docker_setup.sh`"
  bash -c "`curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/nvidia_setup.sh`"
}

main
