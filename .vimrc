set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'kaicataldo/material.vim'

call vundle#end()

filetype plugin on
filetype indent on

syntax on

set background=dark

colorscheme material

let g:material_theme_style = 'dark'

inoremap jk <esc>

au FileType sh setl sw=2 sts=2 et
au FileType yaml setl sw=2 sts=2 et
au FileType xml setl sw=2 sts=2 et
