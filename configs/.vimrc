filetype plugin on
filetype indent on

syntax enable

call plug#begin()

"General
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"Syntax
Plug 'sheerun/vim-polyglot'
Plug 'sainnhe/sonokai'

"Colorscheme
Plug 'tomasr/molokai'

call plug#end()

set background=dark
set t_Co=256

colorscheme sonokai

let mapleader = ','

nnoremap <leader>sv :source $MYVIMRC<CR>
