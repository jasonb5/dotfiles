let mapleader=" "

nnoremap <leader>ev :edit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

call plug#begin()

Plug 'dracula/vim', { 'as': 'dracula' }

call plug#end()

colorscheme dracula
