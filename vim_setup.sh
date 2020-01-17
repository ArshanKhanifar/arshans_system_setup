# fail early
set -eax

USER_NAME="arshankhanifar"
REPO_NAME="arshans_system_setup"
NOPLUGINS_VIMRC="no_plugins.vimrc"
VUNDLE_PLUGINS="vundle_plugins.vim"

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


