# fail early
set -eax

USER_NAME="arshankhanifar"
REPO_NAME="arshans_system_setup"
NOPLUGINS_VIMRC="no_plugins.vimrc"
VUNDLE_PLUGINS="vundle_plugins.vim"
PLUG_PLUGINS="plug.vim"
SHELL_RC_FILE=".zshrc"

# install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

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

# install plug plugins:
echo "source ~/${REPO_NAME}/${PLUG_PLUGINS}" >> ~/.vimrc
vim +'PlugInstall --sync' +qa

##### password-requiring commands
chsh -s $(which zsh)

# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# brew installations
brew install ctags

alias ctags="`brew --prefix`/bin/ctags"
alias ctags >> ~/$SHELL_RC_FILE

