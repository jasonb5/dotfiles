set nocompatible

filetype plugin indent on
syntax on

" Indent
set autoindent
set expandtab
set smarttab
set softtabstop=2
set shiftwidth=2
set shiftround

" Backup
set nobackup
set nowritebackup

" Navigation
set cursorline
set hlsearch
set incsearch
set scrolloff=4
set sidescroll=5
set ignorecase
set smartcase
set tagcase=match

" Misc
set autoread
set backspace=indent,eol,start
set hidden
set history=1000
set lazyredraw
set noautowrite
set noautowriteall
set noerrorbells
set nofsync
set nojoinspaces
set wrapscan
set splitbelow
set splitright
set synmaxcol=200
set ttyfast
set updatetime=300

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
set signcolumn=yes

" Spelling
set spellfile=~/.vim/spell/en.utf-8.add
set spelllang=en

" Breaking
set wrap
set nolinebreak
set breakindent
set breakindentopt=min:40

set termguicolors
set background=dark

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
nnoremap <leader>ec :edit ~/.vim/coc-settings.json<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

nmap <leader>- :split<cr>
nmap <leader>\ :vsplit<cr>

nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

nnoremap <leader>b :Buffers<CR>

let g:coc_global_extensions = [
      \ '@yaegassy/coc-ansible',
      \ 'coc-cmake',
      \ 'coc-docker',
      \ 'coc-git',
      \ 'coc-go',
      \ 'coc-json',
      \ 'coc-xml',
      \ 'coc-yaml',
      \ '@yaegassy/coc-pylsp',
      \ ]

" Coc configuration
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-reference)

nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
      call CocActionAsync('doHover')
    else
      call feedkeys('K', 'in')
    endif
endfunction

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)

nmap <leader>ac <Plug>(coc-codeaction-cursor)
nmap <leader>as <Plug>(coc-codeaction-source)
nmap <leader>qf <Plug>(coc-fix-current)

nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r <Plug>(coc-codeaction-refactor-selected)

nmap <leader>cl <Plug>(coc-codelens-action)

call plug#begin()

Plug 'joshdick/onedark.vim'

Plug 'sheerun/vim-polyglot'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'

Plug 'tpope/vim-fugitive'

call plug#end()

colorscheme onedark

" vim: sw=2 sts=2 tw=0
