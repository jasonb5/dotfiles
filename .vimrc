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
set t_Co=256

colorscheme PaperColor

let highlight_builtins = 1

inoremap jk <esc>
