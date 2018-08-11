set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" General
Plugin 'VundleVim/Vundle.vim'

" Colorschemes
Plugin 'NLKNguyen/papercolor-theme'

" Syntax
Plugin 'pangloss/vim-javascript'
Plugin 'elzr/vim-json'
Plugin 'fatih/vim-go'
Plugin 'vim-scripts/dtrace-syntax-file'
Plugin 'plasticboy/vim-markdown'
Plugin 'hdima/python-syntax'
Plugin 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
Plugin 'NLKNguyen/c-syntax.vim'
Plugin 'leafgarland/typescript-vim'

" Python
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'

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

colorscheme PaperColor

let highlight_builtins = 1

inoremap jk <esc>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix
