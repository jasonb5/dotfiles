set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" General
Plugin 'VundleVim/Vundle.vim'

" Airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Colorschemes
Plugin 'NLKNguyen/papercolor-theme'

" Syntax
Plugin 'pangloss/vim-javascript'
Plugin 'elzr/vim-json'
Plugin 'fatih/vim-go'
Plugin 'vim-scripts/dtrace-syntax-file'
Plugin 'plasticboy/vim-markdown'
Plugin 'hdima/python-syntax'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'NLKNguyen/c-syntax.vim'
Plugin 'leafgarland/typescript-vim'

" Python
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'

call vundle#end()

filetype plugin indent on

syntax enable

set number
set expandtab
set shiftwidth=2
set tabstop=2
set cursorline
set showmatch
set background=dark
set encoding=utf-8
set t_Co=256
set backspace=indent,eol,start

colorscheme PaperColor

let highlight_builtins = 1
let g:airline_theme = 'papercolor'
let g:go_version_warning = 0

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

inoremap jk <esc>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <S-n> :bnext<cr>

au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ softtabstop=4
    \ shiftwidth=4
    \ textwidth=79
    \ expandtab
    \ autoindent
    \ fileformat=unix
