set encoding=utf-8

let mapleader = " "

set backspace=2
set nobackup
set nowritebackup
set noswapfile
set history=50
set ruler
set showcmd
set incsearch
set laststatus=2
set autowrite
set modelines=0
set nomodeline

if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
	syntax on
endif

filetype plugin indent on

set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

set textwidth=80
set colorcolumn=+1

set number
set numberwidth=5

set splitbelow
set splitright

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:airline#extensions#tabline#enabled = 1

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:tmux_navigator_no_mappings = 1

nnoremap <leader>n :NERDTreeFocus<CR>

nnoremap <C-r> :source ~/.vimrc<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

nnoremap <silent> <C-j> :TmuxNavigateLeft<CR>
nnoremap <silent> <C-k> :TmuxNavigateDown<CR>
nnoremap <silent> <C-i> :TmuxNavigateUp<CR>
nnoremap <silent> <C-l> :TmuxNavigateRight<CR>
nnoremap <silent> <C-p> :TmuxNavigatePrevious<CR>

function! BuildYCM(info)
	if a:info.status == 'installed' || a.info.force
		!./install.py
	endif
endfunction

call plug#begin('~/.vim/plugged')

" General
Plug 'editorconfig/editorconfig-vim'
Plug 'jreybert/vimagit'
Plug 'airblade/vim-gitgutter'

" Theme
Plug 'jcherven/jummidark.vim'

" Visual
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'edkolev/tmuxline.vim'
Plug 'christoomey/vim-tmux-navigator'

" Syntax
Plug 'sheerun/vim-polyglot'
Plug 'ekalinin/Dockerfile.vim' " Not included with vim-polygot
Plug 'dense-analysis/ale'

" Autocomplete
Plug 'ycm-core/YouCompleteMe', { 'do': function('BuildYCM') }

call plug#end()

colorscheme jummidark
