if &compatible
  set nocompatible
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  " General
  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Airline
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')

  " Color Schemes
  call dein#add('NLKNguyen/papercolor-theme')

  " Python
  call dein#add('nvie/vim-flake8')

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on

syntax enable

call map(dein#check_clean(), "delete(v:val, 'rf')")

if dein#check_install()
  call dein#install()
endif

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

let g:typescript_indent_disable = 1

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
