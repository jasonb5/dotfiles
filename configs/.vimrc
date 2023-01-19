set history=500

filetype plugin on
filetype indent on

set autoread
au FocusGained,BufEnter * checktime

let mapleader = ' '

command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

set so=7
set wildmenu
set ruler
set cmdheight=1
set hid
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
set ignorecase
set smartcase
set hlsearch
set incsearch
set lazyredraw
set magic
set showmatch
set mat=2
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set foldcolumn=1

syntax enable

set regexpengine=0

if $COLORTERM == 'gnome-terminal'
	set t_Co=256
endif

try
	colorscheme desert
catch
endtry

set background=dark
set encoding=utf8
set ffs=unix,dos,mac

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

map <space><space> /
map <C-space> ?

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <leader>bd :Bclose<cr>:tabclose<cr>gT

map <leader>ba :bufdo bd<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove<cr>
map <leader>t<leader> :tabnext<cr>

let g:lasttab = 1
nmap <leader>tl :exe 'tabn '.g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

map <leader>te :tabedit <C-r>=escape(expand('%:p:h'), '')<cr>/

try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

set laststatus=2
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

map <leader>ss :setlocal spell!<cr>

map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

call plug#begin()
call plug#end()
