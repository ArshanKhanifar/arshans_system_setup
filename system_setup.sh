#!/bin/bash

# fail early
set -eax

if ! which sudo 2>&1 > /dev/null; then
  sudo() { "$@"; }
  echo "sudo command not found, using direct execution."
fi

# when debugging this in docker ubuntu
sudo apt update && sudo apt install -y curl git

# for some packages that require user input
export DEBIAN_FRONTEND=noninteractive

USER_NAME="arshankhanifar"
REPO_NAME="arshans_system_setup"
RCFILE=".arshrc"
NOPLUGINS_VIMRC="no_plugins.vimrc"
JETBRAINS_VIMRC="arshan_jetbrains.ideavimrc"
VUNDLE_PLUGINS="vundle_plugins.vim"
CUSTOM_VIM="custom.vim"
PLUG_PLUGINS="plug.vim"
BYOBU_KEYBINDINGS="keybindings.tmux"
SHELL_RC_FILE=".zshrc"

MACHINE_MAC="Mac"
MACHINE_LINUX="Linux"

ARCHITECTURE_ARM64="arm64"

architecture="$(uname -m)"
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=$MACHINE_LINUX;;
    Darwin*)    machine=$MACHINE_MAC;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

# install packages
if [ "${machine}" = "${MACHINE_LINUX}" ]; then
  if [ "${ENVIRONMENT}" = "docker" ]; then
    if [ -f "/etc/os-release" ]; then
      # Detect the Linux distribution
      source /etc/os-release
      if [ "${ID}" = "alpine" ]; then
        apk update
        apk add --no-cache git zsh vim byobu make jq
      else
        # non-alpine, so debian-based
        apt-get update
        apt-get install -y git-core zsh vim byobu make jq silversearcher-ag
      fi
    else
      echo "Unable to determine the Linux distribution. Zsh not installed."
      exit 1
    fi
  else
    # non-docker linux environment (right now I only support debian)
    sudo apt update
    sudo apt install -y git zsh vim byobu make jq silversearcher-ag
  fi
else
  echo "Zsh not installed, please install it before running this script."
  exit 1
fi

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# less permissions on oh-my-zsh
chmod -R 700 ~/.oh-my-zsh

# clone this repo:
cd ~
git clone https://github.com/$USER_NAME/$REPO_NAME

# Add shortcuts
echo "source ~/${REPO_NAME}/${NOPLUGINS_VIMRC}" >> ~/.vimrc
echo "source ~/${REPO_NAME}/${JETBRAINS_VIMRC}" >> ~/.ideavimrc

# install custom scripts
echo "source ~/${REPO_NAME}/${CUSTOM_VIM}" >> ~/.vimrc

# install vundle:
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# install vundle plugins:
echo "source ~/${REPO_NAME}/${VUNDLE_PLUGINS}" >> ~/.vimrc
vim +PluginInstall +qall

# install plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install plug plugins:
echo "source ~/${REPO_NAME}/${PLUG_PLUGINS}" >> ~/.vimrc
vim +'PlugInstall --sync' +qa

# set up byobu 
export BYOBU_BACKEND=tmux

# create & kill a session (to create the ~/.byobu directory)
byobu new-session -d -s temp
byobu kill-session -t temp
# create it anyways (in case the above doesn't work - it does not in docker ubuntu)
mkdir -p ~/.byobu

# select the backend & switch to screen
byobu-select-backend tmux
byobu-ctrl-a screen

# byobu keybinding config
echo "source ~/${REPO_NAME}/${BYOBU_KEYBINDINGS}" >> ~/.byobu/keybindings.tmux

# general.arshrc commands
echo "source ~/${REPO_NAME}/${RCFILE}" >> ~/.zshrc
echo "source ~/${REPO_NAME}/${RCFILE}" >> ~/.bashrc

emojis=(🐳 🐸 🙈 🐶 🐥 🐝 🐞 🪲)
emoji="${emojis[RANDOM % ${#emojis[@]}]}"
machine_title="$emoji-$1"

# For unix-like systems, change the shell to zsh
if [ "${machine}" = "${MACHINE_LINUX}" ]; then
  sudo chsh -s /bin/zsh `whoami`;
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="zhann"/' ~/.zshrc;
  echo 'export MACHINE_TITLE=pp1' >> ~/.zshrc;
  preprompt='PROMPT="%(?:%{$fg_bold[green]%}%1{'
  postprompt='%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%} "'
  prompt="$preprompt$machine_title$postprompt"
  echo $prompt >> ~/.zshrc;
  echo 'alias docker="sudo docker"' >> ~/.zshrc
fi

##### password-requiring commands
# check if INTERACTIVE is set
if [ -z "${INTERACTIVE}" ]; then
  echo "INTERACTIVE is not set, skipping password-requiring commands."
  exit 0
fi

chsh -s $(which zsh)

if [ "${machine}" = "${MACHINE_MAC}" ] &&
   [ "${architecture}" != "${ARCHITECTURE_ARM64}" ]; then

  # install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  # brew installations
  brew install ctags the_silver_searcher

  alias ctags="`brew --prefix`/bin/ctags"
  alias ctags >> ~/$SHELL_RC_FILE
fi

