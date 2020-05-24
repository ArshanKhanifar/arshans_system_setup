# fail early
set -eax

USER_NAME="arshankhanifar"
REPO_NAME="arshans_system_setup"
NOPLUGINS_VIMRC="no_plugins.vimrc"
VUNDLE_PLUGINS="vundle_plugins.vim"
PLUG_PLUGINS="plug.vim"
SHELL_RC_FILE=".zshrc"

MACHINE_MAC="Mac"
MACHINE_LINUX="Linux"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=$MACHINE_LINUX;;
    Darwin*)    machine=$MACHINE_MAC;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

# install zsh
if [ -z "$(which zsh)" ]; then
  if [ "${machine}" = "${MACHINE_LINUX}" ]; then
    sudo apt install git-core zsh
  else 
    echo "Zsh not installed, please install it before running this script."
    exit 1
  fi
fi

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# less permissions on oh-my-zsh
chmod -R 700 ~/.oh-my-zsh

# clone this repo:
cd ~
git clone https://github.com/$USER_NAME/$REPO_NAME

# Add shortcuts
echo "source ~/${REPO_NAME}/${NOPLUGINS_VIMRC}" >> ~/.vimrc

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

##### password-requiring commands
chsh -s $(which zsh)

if [ "${machine}" = "${MACHINE_MAC}" ]; then
  # install homebrew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  # brew installations
  brew install ctags

  alias ctags="`brew --prefix`/bin/ctags"
  alias ctags >> ~/$SHELL_RC_FILE
fi

