set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Colorschemes
Plugin 'kaicataldo/material.vim'

" Functionality plugins
Plugin 'vim-airline/vim-airline'
Plugin 'jreybert/vimagit'

" Typescript
Plugin 'leafgarland/typescript-vim'

" Python
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'

call vundle#end()

filetype plugin on
filetype indent on

syntax on

set background=dark
set nu

colorscheme material

let g:material_theme_style = 'dark'

let g:airline_theme = 'material'

inoremap jk <esc>

au FileType sh setl sw=2 sts=2 et
au FileType yaml setl sw=2 sts=2 et
au FileType xml setl sw=2 sts=2 et

au BufNewFile,BufRead *.py
    \ setl tabstop=4
    \ softtabstop=4
    \ shiftwidth=4
    \ textwidth=79
    \ expandtab
    \ autoindent
    \ fileformat=unix

if (has("termguicolors"))
  set termguicolors
endif

if &term =~ "xterm"
  " 256 colors
  let &t_Co = 256
  " restore screen after quitting
  let &t_ti = "\<Esc>7\<Esc>[r\<Esc>[?47h"
  let &t_te = "\<Esc>[?47l\<Esc>8"
  if has("terminfo")
    let &t_Sf = "\<Esc>[3%p1%dm"
    let &t_Sb = "\<Esc>[4%p1%dm"
  else
    let &t_Sf = "\<Esc>[3%dm"
    let &t_Sb = "\<Esc>[4%dm"
  endif
endif
