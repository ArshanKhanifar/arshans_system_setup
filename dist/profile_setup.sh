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

function ensure_line() {
  local file="$1"
  local line="$2"
  touch "$file"
  grep -Fq "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

function ensure_git_clone() {
  local url="$1"
  local dir="$2"
  if [ -d "$dir/.git" ]; then
    return 0
  fi
  if [ -d "$dir" ]; then
    rm -rf "$dir"
  fi
  git clone "$url" "$dir"
}

function ensure_homebrew() {
  if [ "$(uname -s)" != "Darwin" ]; then
    return 0
  fi
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

function ensure_brew_package() {
  ensure_homebrew
  if ! brew list "$1" >/dev/null 2>&1; then
    brew install "$1"
  fi
}

function ensure_linux_package() {
  local package="$1"
  if command -v "$package" >/dev/null 2>&1; then
    return 0
  fi
  eval "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 ${LINUX_INSTALLER} install -y ${package}"
}

if ! which sudo 2>&1 > /dev/null; then
  sudo() { "$@"; }
  echo "sudo command not found, using direct execution."
fi
#!/bin/bash


progress_file="${progress_file:-profile_setup.json}"

set -e

USER_NAME="arshankhanifar"
REPO_NAME="arshans_system_setup"
RCFILE=".arshrc"
BASH_PROMPT="bash_prompt.sh"
NOPLUGINS_VIMRC="no_plugins.vim"
JETBRAINS_VIMRC="arshan_jetbrains.ideavimrc"
VUNDLE_PLUGINS="vundle_plugins.vim"
CUSTOM_VIM="custom.vim"
PLUG_PLUGINS="plug.vim"
BYOBU_KEYBINDINGS="keybindings.tmux"
ZELLIJ_CONFIG="zellij_config.kdl"
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
      DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt-get update -y
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

function parseArgs() {
  STAGE="all"
  USER_LABEL="$(whoami)"

  while [ $# -gt 0 ]; do
    case "$1" in
      --stage=*)
        STAGE="${1#*=}"
        ;;
      --stage)
        STAGE="$2"
        shift
        ;;
      --username=*)
        USER_LABEL="${1#*=}"
        ;;
      --username)
        USER_LABEL="$2"
        shift
        ;;
      *)
        USER_LABEL="$1"
        ;;
    esac
    shift
  done
}

function shouldRunStage() {
  local stage_name="$1"
  [ "$STAGE" = "all" ] || [ "$STAGE" = "$stage_name" ]
}

function runStage() {
  local stage_name="$1"
  shift
  if shouldRunStage "$stage_name"; then
    xst "$@"
  fi
}

function installPackages() {
  export DEBIAN_FRONTEND=noninteractive
  export NEEDRESTART_MODE=a
  export NEEDRESTART_SUSPEND=1

  if [ "${machine}" = "${MACHINE_LINUX}" ]; then
    echo "Using installer: $LINUX_INSTALLER"
    if [ "${ENVIRONMENT}" = "docker" ]; then
      eval "DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 ${LINUX_INSTALLER} install -y git zsh vim byobu make jq"
    else
      if [ -f "/etc/needrestart/needrestart.conf" ]; then
        grep -qxF "\$nrconf{restart} = 'a'" /etc/needrestart/needrestart.conf || echo "\$nrconf{restart} = 'a'" | sudo tee -a /etc/needrestart/needrestart.conf
      fi
      eval "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 ${LINUX_INSTALLER} install -y git zsh vim byobu make jq silversearcher-ag"
    fi
  else
    ensure_homebrew
    ensure_brew_package git
    ensure_brew_package zsh
    ensure_brew_package vim
    ensure_brew_package byobu
    ensure_brew_package make
    ensure_brew_package jq
    ensure_brew_package the_silver_searcher
  fi

  unset DEBIAN_FRONTEND
  unset NEEDRESTART_MODE
  unset NEEDRESTART_SUSPEND
}

function installUV() {
  if command -v uv >/dev/null 2>&1; then
    echo "uv already installed"
    return 0
  fi
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

function installFoundry() {
  if [ -x "$HOME/.foundry/bin/forge" ]; then
    echo "Foundry already installed"
    return 0
  fi
  curl -L https://foundry.paradigm.xyz | bash
  "$HOME/.foundry/bin/foundryup"
}

function installBat() {
  if command -v bat >/dev/null 2>&1; then
    echo "bat already installed"
    return 0
  fi
  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    ensure_brew_package bat
  else
    source /etc/os-release
    if [ "$ID" = "amzn" ]; then
      echo "skipping bat installation for Amazon Linux"
      return 0
    fi
    eval "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 ${LINUX_INSTALLER} install -y bat"
  fi
}

function installZoxide() {
  if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
  ensure_line "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
  ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
  ensure_line "$HOME/.bashrc" 'eval "$(zoxide init bash)"'
  ensure_line "$HOME/.zshrc" 'eval "$(zoxide init zsh)"'
}

function installOhMyZsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh already installed"
    return 0
  fi
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  chmod -R 700 ~/.oh-my-zsh
}

function installZellijBinaryFallback() {
  local version="v0.44.3"
  local arch target asset url tmpdir
  arch="$(uname -m)"
  case "${arch}" in
    arm64|aarch64) target="aarch64" ;;
    x86_64|amd64) target="x86_64" ;;
    *) echo "Unsupported architecture for zellij: ${arch}"; return 1 ;;
  esac

  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    asset="zellij-${target}-apple-darwin.tar.gz"
  else
    asset="zellij-${target}-unknown-linux-musl.tar.gz"
  fi

  url="https://github.com/zellij-org/zellij/releases/download/${version}/${asset}"
  tmpdir="$(mktemp -d)"
  curl -fsSL "$url" -o "${tmpdir}/zellij.tar.gz"
  tar -xzf "${tmpdir}/zellij.tar.gz" -C "${tmpdir}"
  mkdir -p "$HOME/.local/bin"
  install -m 755 "${tmpdir}/zellij" "$HOME/.local/bin/zellij"
  rm -rf "$tmpdir"
}

function installZellij() {
  if ! command -v zellij >/dev/null 2>&1; then
    if [ "${machine}" = "${MACHINE_MAC}" ]; then
      ensure_homebrew
      if brew list zellij >/dev/null 2>&1; then
        :
      elif ! brew install zellij; then
        installZellijBinaryFallback
      fi
    else
      installZellijBinaryFallback
    fi
  fi
  setupZellij
}

function setupZellij() {
  local repo_config="$HOME/${REPO_NAME}/${ZELLIJ_CONFIG}"
  local target_config="$HOME/.config/zellij/config.kdl"

  if [ ! -f "$repo_config" ]; then
    echo "Missing zellij config at $repo_config"
    return 1
  fi

  mkdir -p "$HOME/.config/zellij"
  cp -f "$repo_config" "$target_config"

  if [ "${machine}" = "${MACHINE_LINUX}" ]; then
    grep -v '^copy_command "pbcopy"$' "$target_config" > "${target_config}.tmp"
    mv "${target_config}.tmp" "$target_config"
  fi

  ensure_line "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
}

function cloneRepo() {
  cd ~
  if [ -d "$HOME/${REPO_NAME}/.git" ]; then
    echo "Repository already cloned at ~/${REPO_NAME}"
    return 0
  fi
  git clone "https://github.com/${USER_NAME}/${REPO_NAME}"
}

function setupVim() {
  touch "$HOME/.vimrc" "$HOME/.ideavimrc"

  ensure_line "$HOME/.vimrc" "source ~/${REPO_NAME}/${NOPLUGINS_VIMRC}"
  ensure_line "$HOME/.ideavimrc" "source ~/${REPO_NAME}/${JETBRAINS_VIMRC}"

  ensure_git_clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"

  ensure_line "$HOME/.vimrc" "source ~/${REPO_NAME}/${VUNDLE_PLUGINS}"
  echo | vim +PluginInstall +qall >/dev/null 2>&1 || true

  mkdir -p "$HOME/.vim/autoload"
  if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  ensure_line "$HOME/.vimrc" "source ~/${REPO_NAME}/${PLUG_PLUGINS}"
  echo | vim +PlugInstall --sync +qa >/dev/null 2>&1 || true

  ensure_line "$HOME/.vimrc" "source ~/${REPO_NAME}/${CUSTOM_VIM}"
}

function setupByobu() {
  export BYOBU_BACKEND=tmux
  mkdir -p "$HOME/.byobu"

  if command -v byobu >/dev/null 2>&1; then
    byobu new-session -d -s temp 2>/dev/null || true
    byobu kill-session -t temp 2>/dev/null || true
    byobu-select-backend tmux 2>/dev/null || true
    byobu-ctrl-a screen 2>/dev/null || true
  fi

  ensure_git_clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  ensure_line "$HOME/.byobu/keybindings.tmux" "source ~/${REPO_NAME}/${BYOBU_KEYBINDINGS}"
}

function setupITerm() {
  if [ "${machine}" != "${MACHINE_MAC}" ]; then
    echo "Skipping iTerm setup (not macOS)"
    return 0
  fi

  local repo_root="$HOME/${REPO_NAME}"
  local profile_src="${repo_root}/iterm/arshan_iterm_profile.json"
  local keymap_src="${repo_root}/iterm/arshan_key_bindings.itermkeymap"
  local dynamic_dir="${HOME}/Library/Application Support/iTerm2/DynamicProfiles"
  local keymap_dir="${HOME}/Library/Application Support/iTerm2/Custom Key Bindings"

  mkdir -p "$dynamic_dir" "$keymap_dir"

  python3 - <<PY
import json
from pathlib import Path

profile = json.loads(Path("${profile_src}").read_text())
dynamic_path = Path("${dynamic_dir}") / "Arshan.json"
dynamic_path.write_text(json.dumps({"Profiles": [profile]}, indent=2))
PY

  cp -f "$keymap_src" "${keymap_dir}/Arshan.itermkeymap"

  cat <<EOF

iTerm2 profile installed to:
  ${dynamic_dir}/Arshan.json

Key bindings copied to:
  ${keymap_dir}/Arshan.itermkeymap

Finish setup in iTerm2:
  1. Quit and reopen iTerm2 (or reload Dynamic Profiles).
  2. Preferences > Profiles > Arshan > Other Actions > Set as Default
  3. Preferences > Keys > Presets > Import... > select Arshan.itermkeymap

EOF
}

function configurePromptAndRcfiles() {
  ensure_line "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
  ensure_line "$HOME/.bashrc" "source ~/${REPO_NAME}/${RCFILE}"
  ensure_line "$HOME/.bashrc" "source ~/${REPO_NAME}/${BASH_PROMPT}"
  ensure_line "$HOME/.zshrc" "source ~/${REPO_NAME}/${RCFILE}"

  emojis=(🐳 🐸 🙈 🐶 🐥 🐝 🐞 🪲)
  emoji="${emojis[RANDOM % ${#emojis[@]}]}"
  machine_title="$emoji-${USER_LABEL}"

  if [ "${machine}" = "${MACHINE_LINUX}" ] && [ -f "$HOME/.zshrc" ]; then
    if grep -q 'ZSH_THEME="robbyrussell"' "$HOME/.zshrc"; then
      sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="zhann"/' "$HOME/.zshrc"
    fi
    preprompt='PROMPT="%(?:%{$fg_bold[green]%}%1{'
    postprompt='%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%} "'
    prompt="$preprompt$machine_title$postprompt"
    ensure_line "$HOME/.zshrc" "$prompt"
  fi
}

function interactiveCommands() {
  if [ -z "${INTERACTIVE}" ]; then
    echo "INTERACTIVE is not set, skipping password-requiring commands."
    return 0
  fi

  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    ensure_homebrew
    ensure_brew_package ctags
    ensure_brew_package the_silver_searcher
    ensure_line "$HOME/${SHELL_RC_FILE}" 'alias ctags="$(brew --prefix)/bin/ctags"'
  fi
}

function installAwsCli() {
  sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt install awscli -y
}

function updatePackageManager() {
  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    ensure_homebrew
    return 0
  fi

  export DEBIAN_FRONTEND=noninteractive
  export NEEDRESTART_MODE=a
  export NEEDRESTART_SUSPEND=1

  case "${LINUX_INSTALLER}" in
    apt-get)
      sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 apt-get update -y
      ;;
    yum)
      sudo yum update -y
      ;;
    apk)
      sudo apk update
      ;;
    *)
      echo "Unsupported package manager: ${LINUX_INSTALLER}"
      exit 1
      ;;
  esac

  unset DEBIAN_FRONTEND
  unset NEEDRESTART_MODE
  unset NEEDRESTART_SUSPEND
}

function ensureJq() {
  if command -v jq >/dev/null 2>&1; then
    return 0
  fi
  if [ "${machine}" = "${MACHINE_MAC}" ]; then
    ensure_brew_package jq
  else
    eval "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 ${LINUX_INSTALLER} install -y jq"
  fi
}

function main() {
  parseArgs "$@"

  updatePackageManager
  ensureJq

  runStage installPackages installPackages
  runStage installUV installUV
  runStage installZoxide installZoxide
  runStage installBat installBat
  runStage installOhMyZsh installOhMyZsh
  runStage installFoundry installFoundry
  runStage cloneRepo cloneRepo
  runStage setupVim setupVim
  runStage setupByobu setupByobu
  runStage installZellij installZellij
  runStage setupITerm setupITerm
  runStage configurePromptAndRcfiles configurePromptAndRcfiles
  runStage interactiveCommands interactiveCommands
}

main "$@"
