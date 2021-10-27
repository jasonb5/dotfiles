set nocompatible

filetype on
filetype plugin on
filetype indent on

syntax on

set history=500

set so=7
set wildmenu
set ignorecase
set smartcase
set hlsearch
set lazyredraw
set magic
set showmatch

set noerrorbells
set novisualbell
set t_vb=
set tm=500

set encoding=utf-8

set nobackup
set nowb
set noswapfile

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=500
set ai
set si
set wrap
set nu

set laststatus=2

let mapleader = " "

let g:go_diagnostics_enabled = 0
let g:go_metalinter_enabled = []
let g:go_jump_to_error = 0
let g:go_fmt_command = "goimports"
let g:go_auto_sameids = 0

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

let g:coc_global_extensions = [
            \'coc-go',
            \'@yaegassy/coc-pylsp',
            \]

au FileType xml setl sw=2 ts=2 sts=2 et
au FileType yaml setl sw=2 ts=2 sts=2 et

" Go
au BufEnter *.go nmap <leader>t <Plug>(go-test)
au BufEnter *.go nmap <leader>tt <Plug>(go-test-func)
au BufEnter *.go nmap <leader>i <Plug>(go-info)
au BufEnter *.go nmap <leader>ii <Plug>(go-implements)
au BufEnter *.go nmap <leader>ci <Plug>(go-describe)
au BufEnter *.go nmap <leader>cc <Plug>(go-callers)

" General
nmap <leader>cr <Plug>(coc-references)
nmap <C-a> <C-o>
nmap <C-d> <Plug>(coc-definition)
nmap <leader>r <Plug>(coc-rename)

inoremap jj <esc>

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

map <leader>sv :vsp<cr>
map <leader>sh :sp<cr>

call plug#begin('~/.vim/plugged')

" Colorscheme
Plug 'joshdick/onedark.vim'

" Syntax highlighting
Plug 'sheerun/vim-polyglot'

" General
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'

" Completion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Go
Plug 'fatih/vim-go'

call plug#end()

colorscheme onedark
