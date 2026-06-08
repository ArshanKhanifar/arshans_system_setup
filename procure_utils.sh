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
