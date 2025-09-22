#!/bin/bash

source ./procure_utils.sh

# fail early
set -e

if ! which sudo 2>&1 > /dev/null; then
  sudo() { "$@"; }
  echo "sudo command not found, using direct execution."
fi


USER_NAME="arshankhanifar"
REPO_NAME="arshans_system_setup"
RCFILE=".arshrc"
NOPLUGINS_VIMRC="no_plugins.vim"
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

if [ "${machine}" = "${MACHINE_LINUX}" ]; then
  source /etc/os-release
  case "${ID}" in
    ubuntu)
      LINUX_INSTALLER="apt-get"
      ;;
    debian)
      apt-get update
      LINUX_INSTALLER="apt-get"
      ;;
    alpine)
      apk update
      LINUX_INSTALLER="apk"
      ;;
    amzn)
      LINUX_INSTALLER="yum"
      ;;
    *)
      echo "Unsupported Linux distribution: ${ID}"
      exit 1
      ;;
  esac
fi

function installPackages() {
  # for some packages that require user input
  DEBIAN_FRONTEND=noninteractive
  echo "Using installer: $LINUX_INSTALLER"

  # install packages
  if [ "${machine}" = "${MACHINE_LINUX}" ]; then
    # all linux machines
    if [ "${ENVIRONMENT}" = "docker" ]; then
      # docker machines
      eval "${LINUX_INSTALLER} install -y git zsh vim byobu make jq"
    else
      # skip restart prompt
      if [ -f "/etc/needrestart/needrestart.conf" ]; then
        grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf
      fi
      eval "sudo ${LINUX_INSTALLER} install -y git zsh vim byobu make jq silversearcher-ag"
    fi
  else
    # install homebrew
    if ! which brew 2>&1 > /dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Mac environment
    brew install git zsh vim byobu make jq the_silver_searcher
  fi

  unset DEBIAN_FRONTEND
}

function installUV() {
  # install uv
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

function installFoundry() {
  curl -L https://foundry.paradigm.xyz | bash
  ~/.foundry/bin/foundryup
  # cast completions
#  TODO: figure out why this doesn't work
#  mkdir -p $HOME/.oh-my-zsh/completions
#  cast completions zsh > $HOME/.oh-my-zsh/completions/_cast
}

function installBat() {
  if [ "`uname -s`" == "Darwin" ]; then
    brew install bat
  else
    source /etc/os-release
    if [ "$ID" = "amzn" ]; then
        echo "skipping installation for Amazon Linux"
        return 0
    fi
    eval "sudo ${LINUX_INSTALLER} install -y bat"
  fi
}

function installZoxide() {
  # install zoxide
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
  echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
  echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
}

function installOhMyZsh() {
  # install oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # less permissions on oh-my-zsh
  chmod -R 700 ~/.oh-my-zsh
}

function cloneRepo() {
  # clone this repo:
  cd ~
  git clone https://github.com/$USER_NAME/$REPO_NAME
}

function setupVim() {
  # Add shortcuts
  echo "source ~/${REPO_NAME}/${NOPLUGINS_VIMRC}" >> ~/.vimrc
  echo "source ~/${REPO_NAME}/${JETBRAINS_VIMRC}" >> ~/.ideavimrc

  # install vundle:
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  # install vundle plugins:
  echo "source ~/${REPO_NAME}/${VUNDLE_PLUGINS}" >> ~/.vimrc
  # I had issues w this: https://github.com/VundleVim/Vundle.vim/issues/511
  echo | vim +PluginInstall +qall


  # install plug
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  # install plug plugins:
  echo "source ~/${REPO_NAME}/${PLUG_PLUGINS}" >> ~/.vimrc
  #vim +'PlugInstall --sync' +qa
  echo | vim +'PlugInstall --sync' +qa

  # install custom scripts
  echo "source ~/${REPO_NAME}/${CUSTOM_VIM}" >> ~/.vimrc
}

function setupByobu() {
  # to install byobu on amzn: https://blog.programster.org/amazon-linux-install-byobu

  # set up byobu
  export BYOBU_BACKEND=tmux

  # create & kill a session (to create the ~/.byobu directory)
  byobu new-session -d -s temp
  byobu kill-session -t temp
  # create it anyways (in case the above doesn't work - it does not in docker ubuntu)
  mkdir -p ~/.byobu

  # install tmux plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # select the backend & switch to screen
  byobu-select-backend tmux
  byobu-ctrl-a screen

  # byobu keybinding config
  echo "source ~/${REPO_NAME}/${BYOBU_KEYBINDINGS}" >> ~/.byobu/keybindings.tmux
}

function configurePromptAndRcfiles() {
  # general.arshrc commands
  echo "source ~/${REPO_NAME}/${RCFILE}" >> ~/.zshrc
  echo "source ~/${REPO_NAME}/${RCFILE}" >> ~/.bashrc

  emojis=(🐳 🐸 🙈 🐶 🐥 🐝 🐞 🪲)
  emoji="${emojis[RANDOM % ${#emojis[@]}]}"
  machine_title="$emoji-$1"

  # For unix-like systems, configure zsh prompt (without changing default shell)
  if [ "${machine}" = "${MACHINE_LINUX}" ]; then
    # NOTE: aws linux doesn't have this
    # https://stackoverflow.com/questions/17126051/how-to-change-shell-on-amazon-ec2-linux-instance
    # Removed: sudo chsh -s /bin/zsh `whoami`; # User doesn't want ZSH as default shell
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="zhann"/' ~/.zshrc;
    preprompt='PROMPT="%(?:%{$fg_bold[green]%}%1{'
    postprompt='%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%} "'
    prompt="$preprompt$machine_title$postprompt"
    echo $prompt >> ~/.zshrc;
  fi
}

function interactiveCommands() {
  ##### password-requiring commands
  # check if INTERACTIVE is set
  if [ -z "${INTERACTIVE}" ]; then
    echo "INTERACTIVE is not set, skipping password-requiring commands."
    exit 0
  fi

  # Removed: chsh -s $(which zsh) # User doesn't want ZSH as default shell

  if [ "${machine}" = "${MACHINE_MAC}" ] &&
     [ "${architecture}" != "${ARCHITECTURE_ARM64}" ]; then

    # install homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # brew installations
    brew install ctags the_silver_searcher

    alias ctags="`brew --prefix`/bin/ctags"
    alias ctags >> ~/$SHELL_RC_FILE
  fi
}

function installAwsCli() {
  sudo apt install awscli -y
}

function updatePackageManager() {
  case "${LINUX_INSTALLER}" in
    apt-get)
      sudo apt-get update
      ;;
    yum)
      sudo yum update
      ;;
    apk)
      sudo apk update
      ;;
    *)
      echo "Unsupported package manager: ${LINUX_INSTALLER}"
      exit 1
      ;;
  esac
}

function ensureJq() {
  if [ -z "`command -v jq`" ]; then
    # use the LINUX_INSTALLER to install
    eval "sudo ${LINUX_INSTALLER} install -y jq"
  fi
}



function main() {
  # installing jq, needed for stage utils
  updatePackageManager
  ensureJq
  xst installPackages
  xst installUV
  xst installZoxide
  xst installBat
  xst installOhMyZsh
  xst installFoundry
  xst cloneRepo
  xst setupVim
  xst setupByobu
  xst configurePromptAndRcfiles $1
  xst interactiveCommands
}

main $1
