call plug#begin()

Plug 'joshdick/onedark.vim'

Plug 'sheerun/vim-polyglot'

call plug#end()

filetype plugin indent on
syntax on

" Indent
set autoindent
set expandtab
set smarttab
set softtabstop=4
set shiftwidth=4
set shiftround

" Backup
set nobackup
set nowritebackup

" Navigation
set autoread
set backspace=indent,eol,start
set hidden
set history=1000
set lazyredraw
set noautowrite
set noautowriteall
set noerrorbells
set splitbelow
set splitright
set synmaxcol=200

" Wildmenu
set wildmenu

" Display
set display+=lastline
set laststatus=2
set list
set modeline
set modelines=1
set nostartofline
set numberwidth=1
set ruler
set showcmd
set showmatch
set showmode

" Breaking
set wrap
set nolinebreak
set breakindent
set breakindentopt=min:40

if has('multi_byte') && &encoding ==# 'utf-8'
  let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±,trail:⣿'
  let &fillchars = 'vert: ,diff: '  " ▚
  let &showbreak = '↪ '
  highlight VertSplit ctermfg=242
  " augroup vimrc
  "   autocmd InsertEnter * set listchars-=trail:⣿
  "   autocmd InsertLeave * set listchars+=trail:⣿
  " augroup END
else
  let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
  let &fillchars = 'vert: ,stlnc:#'
  let &showbreak = '-> '
  augroup vimrc
    autocmd InsertEnter * set listchars-=trail:.
    autocmd InsertLeave * set listchars+=trail:.
  augroup END
endif

let mapleader=" "

inoremap jf <esc>

nnoremap <leader>ev :edit $MYVIMRC<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

set termguicolors
set background=dark

colorscheme onedark

" vim: sw=2 sts=2 tw=0
