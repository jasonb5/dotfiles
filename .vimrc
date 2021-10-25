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

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:go_diagnositics_enabled = 0
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
            \]

au FileType xml setl sw=2 ts=2 sts=2 et
au FileType yaml setl sw=2 ts=2 sts=2 et

inoremap jj <esc>

nnoremap <leader>w :w!<cr>
nnoremap <leader>c :noh<cr>
nnoremap <leader>rl :source ~/.vimrc<cr>

nnoremap <leader>n :NERDTreeFocus<cr>
nnoremap <C-n> :NERDTree<cr>
nnoremap <C-t> :NERDTreeToggle<cr>
nnoremap <C-f> :NERDTreeFind<cr>

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gv :vsp<CR><PLUG>(coc-definition)<C-W>L
nmap <leader> rn <Plug>(coc-rename)

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

" Dockerfile
Plug 'ekalinin/Dockerfile.vim', { 'for': 'dockerfile' }

" GO
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }

call plug#end()

colorscheme onedark
