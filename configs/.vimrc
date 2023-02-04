filetype plugin on
filetype indent on

syntax enable

" Set 500 line history
set history=500
" Set autoread when file is changed externally
set autoread
" Set 7 lines to the cursor
set so=7
set wildmenu
set ruler
set cmdheight=1
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
set signcolumn=yes
set regexpengine=0
set nu

if $COLORTERM == 'gnome-terminal'
	set t_Co=256
endif

set background=dark
set encoding=utf8
set ffs=unix,dos,mac

set nobackup
set nowritebackup
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

try
    set switchbuf=useopen,usetab,newtab
catch
endtry

set updatetime=300
set laststatus=2

" Set statusline
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ \ Line:\ %l\ \ Column:\ %c\ %{coc#status()}%{get(b:,'coc_current_function','')}

let mapleader = " "

let g:lasttab = 1
let g:ale_disable_lsp = 1
let g:coc_global_extensions = [ 
            \'coc-json',
			\'coc-pyright',
            \]

" Autoread file when changed externally
au FocusGained,BufEnter * checktime

" Update g:lasttab
au TabLeave * let g:lasttab = tabpagenr()

" Return to last edit position
au BufreadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

map <leader>bd :Bclose<CR>:tabclose<CR>gT

map <leader>l :bnext<CR>
map <leader>h :bprevious<CR>

map <leader>tn :tabnew<CR>
map <leader>tc :tabclose<CR>
map <leader>t<leader> :tabnext<CR>

map <leader>tl :exe "tabn ".g:lasttab<CR>

map <leader>sv :source $MYVIMRC<CR>
nmap <leader>w :w!<CR>

map <leader>ss :setlocal spell!<CR>

map <leader>pp :setlocal paste!<CR>

" Use tab to trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
			\ coc#pum#visible() ? coc#pum#next(1) :
			\ CheckBackspace() ? "\<Tab>" :
			\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selection completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
			\ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-reference)

nnoremap <silent><nowait> <leader>oi :<C-u>CocCommand pyright.organizeimports<CR>
nnoremap <silent><nowait> <leader>tt :<C-u>CocCommand pyright.singleTest<CR>
nnoremap <silent><nowait> <leader>tf :<C-u>CocCommand pyright.fileTest<CR>

nnoremap <silent> K :call ShowDocumentation()<CR>

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)

nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

nnoremap <leader>n :NERDTreeToggle<CR>

function! CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction

function! ShowDocumentation()
	if CocAction('hasProvider', 'hover')
		call CocActionAsync('doHover')
	else
		call feedkeys('K', 'in')
	endif 
endfunction

function! HasPaste()
    if &paste
        return 'PASTE MODE '
    endif
    return ''
endfunction

call plug#begin()
" General
Plug 'preservim/nerdtree'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Linting
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Visual
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sainnhe/sonokai'

" Code highlighting
Plug 'sheerun/vim-polyglot'
call plug#end()

colorscheme sonokai
