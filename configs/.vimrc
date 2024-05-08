set nocompatible
" use space for leader key
let mapleader=" "
filetype off

:autocmd InsertEnter,InsertLeave * set cul!

set number
set ruler
set noerrorbells
set visualbell
set laststatus=2
set showmode
set splitbelow splitright
set incsearch
set ignorecase
set smartcase
set showmatch
syntax on
set encoding=utf-8
set formatoptions=tcqrnl
set hidden
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround
set expandtab
set noshiftround
set scrolloff=3
set showcmd
set wildmenu
set background=dark

let g:solarized_termcolors=256
let g:solarized_termtrans=1

imap JJ <esc>

inoremap ( ()<esc>hli
inoremap { {}<esc>hli
inoremap [ []<esc>hli
inoremap ' ''<esc>hli
inoremap " ""<esc>hli
inoremap ` ``<esc>hli

vnoremap > >gv
vnoremap < <gv

call plug#begin()

Plug 'sainnhe/everforest'

Plug 'sheerun/vim-polyglot'

call plug#end()

filetype plugin indent on

colorscheme everforest
