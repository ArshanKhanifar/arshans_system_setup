#!/bin/bash

progress_file=profile_setup.json

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

function installZellij() {
  echo "Installing Zellij terminal multiplexer..."
  
  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    # Mac installation
    if [ "${architecture}" = "${ARCHITECTURE_ARM64}" ]; then
      # For Apple Silicon (M1/M2/etc)
      brew install zellij
    else
      # For Intel Macs
      brew install zellij
    fi
  elif [ "${machine}" = "${MACHINE_LINUX}" ]; then
    # Linux installation
    case "${ID}" in
      ubuntu|debian)
        # For Ubuntu/Debian
        curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv zellij /usr/local/bin/
        ;;
      alpine)
        # For Alpine
        apk add zellij
        ;;
      amzn)
        # For Amazon Linux
        curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv zellij /usr/local/bin/
        ;;
      *)
        echo "Unsupported Linux distribution for Zellij installation: ${ID}"
        ;;
    esac
  else
    echo "Unsupported OS for Zellij installation: ${machine}"
  fi
  
  # Create symlink for Zellij configuration
  symlinkConfig "$HOME/${REPO_NAME}/zellij_config.kdl" "$HOME/.config/zellij/config.kdl"
  
  # Add Zellij to shell configuration
  echo "# Zellij terminal multiplexer" >> ~/$SHELL_RC_FILE
  echo "alias zj='zellij'" >> ~/$SHELL_RC_FILE
  echo "alias zja='zellij attach'" >> ~/$SHELL_RC_FILE
  echo "alias zjls='zellij list-sessions'" >> ~/$SHELL_RC_FILE
  
  echo "Zellij installation completed!"
}

function configurePromptAndRcfiles() {
  # general.arshrc commands
  echo "source ~/${REPO_NAME}/${RCFILE}" >> ~/.zshrc
  echo "source ~/${REPO_NAME}/${RCFILE}" >> ~/.bashrc

  emojis=(🐳 🐸 🙈 🐶 🐥 🐝 🐞 🪲)
  emoji="${emojis[RANDOM % ${#emojis[@]}]}"
  machine_title="$emoji-$1"

  # For unix-like systems, change the shell to zsh
  if [ "${machine}" = "${MACHINE_LINUX}" ]; then
    # NOTE: aws linux doesn't have this
    # https://stackoverflow.com/questions/17126051/how-to-change-shell-on-amazon-ec2-linux-instance
    sudo chsh -s /bin/zsh `whoami`;
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
}

function installAwsCli() {
  sudo apt install awscli -y
}

function updatePackageManager() {
  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    # No need to update package manager on Mac, brew handles it
    echo "Mac detected, skipping package manager update"
  else
    # Linux package manager update
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
        return 1
        ;;
    esac
  fi
}

function ensureJq() {
  if [ -z "`command -v jq`" ]; then
    if [ "${machine}" = "${MACHINE_MAC}" ]; then
      # Install jq using brew on Mac
      brew install jq
    else
      # Use the LINUX_INSTALLER on Linux
      eval "sudo ${LINUX_INSTALLER} install -y jq"
    fi
  fi
}

# Function to create symlinks for configuration files
function symlinkConfig() {
  local source_file="$1"
  local target_file="$2"
  local target_dir=$(dirname "$target_file")
  
  # Create target directory if it doesn't exist
  mkdir -p "$target_dir"
  
  # Check if the target file already exists
  if [ -f "$target_file" ]; then
    # Backup existing file if it's not a symlink
    if [ ! -L "$target_file" ]; then
      echo "Backing up existing config: $target_file to ${target_file}.bak"
      mv "$target_file" "${target_file}.bak"
    else
      # Remove existing symlink
      rm "$target_file"
    fi
  fi
  
  # Create a symbolic link
  echo "Creating symlink: $source_file -> $target_file"
  ln -s "$source_file" "$target_file"
}



function parse_args() {
  # Default values
  export STAGE="all"
  export USERNAME=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --stage=*)
        export STAGE="${1#*=}"
        shift
        ;;
      --stage)
        export STAGE="$2"
        shift 2
        ;;
      --username=*)
        export USERNAME="${1#*=}"
        shift
        ;;
      --username)
        export USERNAME="$2"
        shift 2
        ;;
      *)
        # For backward compatibility, assume first unnamed parameter is username
        if [ -z "$USERNAME" ]; then
          export USERNAME="$1"
        fi
        shift
        ;;
    esac
  done

  # Print parsed arguments
  echo "Parsed arguments:"
  echo "  Stage: $STAGE"
  echo "  Username: $USERNAME"
}

function list_available_stages() {
  echo "Available stages:"
  echo "  all - Run all stages (default)"
  echo "  installPackages - Install basic packages"
  echo "  installUV - Install uv package manager"
  echo "  installZoxide - Install zoxide directory jumper"
  echo "  installBat - Install bat (improved cat)"
  echo "  installOhMyZsh - Install Oh My Zsh"
  echo "  installFoundry - Install Foundry"
  echo "  cloneRepo - Clone the repository"
  echo "  setupVim - Set up Vim configuration"
  echo "  setupByobu - Set up Byobu terminal multiplexer"
  echo "  installZellij - Install Zellij terminal multiplexer"
  echo "  configurePromptAndRcfiles - Configure shell prompt and rc files"
  echo "  interactiveCommands - Run interactive commands"
}

function main() {
  # Parse arguments
  parse_args "$@"

  # installing jq, needed for stage utils
  updatePackageManager
  ensureJq

  # If a specific stage is provided, only run that stage
  if [ -n "$STAGE" ] && [ "$STAGE" != "all" ]; then
    echo "Running only the '$STAGE' stage..."
    # Check if the function exists
    if declare -f "$STAGE" > /dev/null; then
      $STAGE
      echo "Stage '$STAGE' completed."
    else
      echo "Error: Stage '$STAGE' not found!"
      list_available_stages
      return 1
    fi
  else
    # Run all stages in the default order
    echo "Running all stages..."
    xst installPackages
    xst installUV
    xst installZoxide
    xst installBat
    xst installOhMyZsh
    xst installFoundry
    xst cloneRepo
    xst setupVim
    xst setupByobu
    xst installZellij
    xst configurePromptAndRcfiles $USERNAME
    xst interactiveCommands
  fi
}

# Pass all arguments to main
main "$@"
