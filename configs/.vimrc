call plug#begin()

Plug 'sheerun/vim-polyglot'

Plug 'tpope/vim-fugitive'

Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'

Plug 'preservim/nerdtree'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'liuchengxu/vim-which-key'

Plug 'dense-analysis/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'

Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'habamax/vim-rst'

call plug#end()

let mapleader = " "

set number
set relativenumber
set clipboard=unnamedplus

set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

set updatetime=300

set spell
set spelllang=en_us

set showtabline=2
set laststatus=2

colorscheme dracula

syntax on

filetype plugin indent on

let g:ale_completion_enabled = 1
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_completion_delay = 500
let g:ale_hover_to_floating_preview = 1
let g:ale_linters = {
            \ 'python': ['pylsp', 'prospector', ],
            \ 'rst': ['rstcheck', ],
            \ }
let g:ale_fixers = {
            \ 'python': ['black'],
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ }

let g:which_key_map = {}

let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#ale#enabled = 1

let g:lightline = {
            \ 'colorscheme': 'dracula',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ], [ 'filename' ] ],
            \   'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
            \              [ 'lineinfo' ], [ 'percent' ], [ 'filetype', 'branch', 'readonly', 'lsp' ] ]
            \ },
            \ 'component_function': {
            \   'branch': 'FugitiveHead',
            \   'lsp': 'lightline#lsp#status',
            \ },
            \ 'component_expand': {
            \   'linter_checking': 'lightline#ale#checking',
            \   'linter_infos': 'lightline#ale#infos',
            \   'linter_warnings': 'lightline#ale#warnings',
            \   'linter_errors': 'lightline#ale#errors',
            \   'linter_ok': 'lightline#ale#ok',
            \ },
            \ 'component_type': {
            \   'linter_checking': 'right',
            \   'linter_infos': 'right',
            \   'linter_warnings': 'warning',
            \   'linter_errors': 'error',
            \   'linter_ok': 'right',
            \ },
            \ }

autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal! g'\"" |
            \ endif

autocmd  FileType rst setlocal smartindent
autocmd  FileType rst setlocal indentexpr=

nnoremap <leader>f :ALEFix<CR>
nnoremap <leader>s :ALEFixSuggest<CR>
nnoremap <leader>d :ALEGoToDefinition<CR>
nnoremap <leader>r :ALEFindReferences<CR>
nnoremap <leader>h :ALEHover<CR>
inoremap <leader>h <Esc>:ALEHover<CR>a
nnoremap <leader>rn :ALERename<CR>
nnoremap <leader>a :ALECodeAction<CR>
nnoremap <leader>i :ALEInfo<CR>

nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>

nnoremap <leader>n :NERDTreeToggle<CR>

nnoremap <leader>F :Files<CR>

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>ev :e $MYVIMRC<CR>

nnoremap <leader>b :Buffers<CR>

nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>

nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
