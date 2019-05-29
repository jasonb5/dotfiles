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

" Python
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nvie/vim-flake8'

" Dockerfile
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'stephpy/vim-yaml'

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

let g:flake8_show_in_gutter = 1
let g:flake8_show_in_file = 1

inoremap jk <esc>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <S-n> :bnext<cr>

" Call commands
au BufWritePost *.py call flake8#Flake8()

" Setting file types
au BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml

" Set formatting for filetypes
au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
au FileType python setlocal ts=4 sts=4 sw=4 expandtab
