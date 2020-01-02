set number
set hlsearch

" For indenting after newline
" setlocal indexexpr=

" color highlighting
set term=xterm-256color
set t_Co=256
syntax on
colorscheme heman

" column width checking
set colorcolumn=100

" Spell checking
set spell spelllang=en_ca

" for some reason backspace wasn't working on my vim :/ 
set backspace=indent,eol,start

set clipboard=unnamed
set tabstop=2
set expandtab
set tags=tags;/

set nocompatible              " be iMproved, required
filetype off                  " required

" Vundle plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
	Plugin 'VundleVim/Vundle.vim'
	Bundle 'christoomey/vim-tmux-navigator'
  Plugin 'mileszs/ack.vim'	
  Plugin 'mattn/emmet-vim'
  
call vundle#end()            " required
filetype plugin indent on    " required

" Emmet settings:
let g:user_emmet_leader_key='<C-M>'
let g:user_emmet_mode='n'

call plug#begin('~/.vim/plugged')

	Plug '/usr/local/opt/fzf'
	Plug 'junegunn/fzf.vim'

call plug#end()

" Pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" Escape mapping
imap jk <Esc>

let mapleader = ","

nmap ; :Buffers<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>a :Ack<CR>
nmap <Leader>v :vsplit<CR>
nmap <Leader>s :split<CR>

let g:ackprg = 'ag --nogroup --nocolor --column'

" vim javascript
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1

autocmd BufWritePost *.tex silent !{pdflatex *.tex 2>&1 >/dev/null &}
