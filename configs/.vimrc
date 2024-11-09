if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'dense-analysis/ale'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'tpope/vim-vinegar'

Plug 'ekalinin/Dockerfile.vim'

Plug 'honza/vim-snippets'

Plug 'sheerun/vim-polyglot'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'airblade/vim-rooter'

Plug 'tpope/vim-fugitive'

Plug 'vim-test/vim-test'

call plug#end()

silent! colorscheme dracula
syntax on

set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

set number
set relativenumber

set backspace=indent,eol,start

let mapleader = " "

let g:ale_linters = {
    \ 'python': ['ruff', 'mypy'],
    \ 'vue': ['eslint'],
    \ 'go': ['golangci-lint'],
    \ 'yaml': ['yamllint'],
    \ 'json': ['jq'],
    \ 'xml': ['xmllink'],
    \ 'dockerfile': ['hadolint'],
    \ 'html': ['htmlhint'],
    \ 'css': ['stylehiny'],
    \ 'javascript': ['eslint'],
    \ }

let g:ale_fixers = {
    \ 'python': ['black', 'isort'],
    \ 'vue': ['prettier'],
    \ 'go': ['goimports'],
    \ 'yaml': ['prettier'],
    \ 'json': ['prettier'],
    \ 'xml': ['prettier'],
    \ 'html': ['prettier'],
    \ 'css': ['prettier'],
    \ 'javascript': ['prettier'],
    \ }

let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_on_save = 1

let g:coc_global_extensions = [
    \ 'coc-pyright',
    \ '@yaegassy/coc-volar',
    \ 'coc-tsserver',
    \ 'coc-go',
    \ 'coc-json',
    \ 'coc-yaml',
    \ 'coc-xml',
    \ 'coc-snippets',
    \ 'coc-html',
    \ 'coc-css', 
    \ 'coc-tsserver',
    \ ]

nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>ev :e $MYVIMRC<CR>

inoremap <silent><expr> <Tab>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackSpace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<s-tab>'

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

nnoremap <leader>bn :bnext<CR>      " Next buffer
nnoremap <leader>bp :bprevious<CR>  " Previous buffer
nnoremap <leader>bd :bd<CR>         " Close current buffer
nnoremap <leader>b :Buffers<CR>

nnoremap <leader>tn :tabnew<CR>     " New tab
nnoremap <leader>tc :tabclose<CR>   " Close current tab
nnoremap <leader>to :tabonly<CR>    " Close all other tabs

nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>

nnoremap <silent> <leader>n :ALENext<CR>
nnoremap <silent> <leader>p :ALEPrevious<CR>
nnoremap <silent> <leader>q :ALEQuickFix<CR>
nnoremap <leader>af :ALEFix<CR>

nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>
nnoremap <silent> <leader>ca :<C-u>CocActionAsync('codeAction')<CR>
nnoremap <leader>rn :CocRename<CR>
nnoremap <leader>ca :CocAction<CR>

nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git pull<CR>

nnoremap <leader>tn :TestNearest<CR>
nnoremap <leader>tf :TestFile<CR>
nnoremap <leader>ts :TestSuite<CR>
nnoremap <leader>tl :TestLast<CR>
nnoremap <leader>tv :TestVisit<CR>

" Resumes last place in file
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

