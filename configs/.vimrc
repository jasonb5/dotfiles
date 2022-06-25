filetype on
filetype plugin on
filetype indent on

syntax on

set shiftwidth=4
set tabstop=4
set expandtab

set nocompatible
set nobackup
set nowrap
set noswapfile
set scrolloff=10
set incsearch
set ignorecase
set smartcase
set number
set cursorline
set showcmd
set showmode
set showmatch
set hlsearch
set history=1000

set wildmenu
set wildmode=list:longest

set laststatus=2

let mapleader = " "

let NERDTreeShowHidden = 1

let g:airline_theme = "minimalist"

let g:coc_global_extensions = [
    \ 'coc-git',
    \ 'coc-json',
    \ 'coc-yaml',
    \ '@yaegassy/coc-pylsp',
    \ ]

nnoremap <leader>rl :source ~/.vimrc<cr>
nnoremap <leader>t :NERDTree<cr>
nnoremap <leader>up :PlugInstall<cr>

nnoremap <leader>l :bnext<cr>
nnoremap <leader>h :bprev<cr>
nnoremap <leader>b :buffers<cr>:buffer<space>

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

autocmd bufwritepost .vimrc source ~/.vimrc

call plug#begin()
" General
Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Nerdtree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Colorscheme
Plug 'mangeshrex/everblush.vim'

" LSP
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

call plug#end()

colorscheme everblush
