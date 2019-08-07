call plug#begin('~/.vim/plugged')

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Color Schemes
Plug 'NLKNguyen/papercolor-theme'

" Python

" Typescript
Plug 'Quramy/tsuquyomi'

" Syntax

" Autocomplete
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --ts-completer' }

call plug#end()

filetype plugin indent on

silent! syntax enable

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

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_python_flake8_args = '--max-line-length=120'

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

inoremap jk <esc>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <S-n> :bnext<cr>

" Setting file types
au BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml

" Set formatting for filetypes
au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
au FileType python setlocal ts=4 sts=4 sw=4 expandtab
