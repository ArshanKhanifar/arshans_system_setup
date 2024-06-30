#!/bin/bash

function main() {
  curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh | bash -s -- "$1"
  curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/python_setup.sh | bash
  curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/docker_setup.sh | bash
  curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/nvidia_setup.sh | bash
}

main
