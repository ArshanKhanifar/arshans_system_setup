set number
set hlsearch

syntax on

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

" Escape mapping
imap jk <Esc>

let mapleader = ","

nmap ; :Buffers<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>a :Ack<CR>
nmap <Leader>v :vsplit<CR>
nmap <Leader>s :split<CR>

" make all search case insensitive
set ignorecase
set smartcase
