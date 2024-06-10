" https://medium.com/@devsjc/from-jetbrains-to-vim-a-modern-vim-configuration-and-plugin-set-d58472a7d53d
unlet! skip_default_vims
source $VIMRUNTIME/defaults.vim

syntax on
filetype plugin indent on

set hlsearch incsearch ignorecase
set number relativenumber
set encoding=UTF-8

set noshowmode laststatus=2

let mapleader=" "

let lspOptions = #{
			\ aleSupport: v:true,
			\ autoHightlight: v:true,
			\ completionTextEdit: v:true,
			\ noNewlineInCompletion: v:true,
			\ outlineOnRight: v:true,
			\ outlineWinSize: 70,
			\ showDiagWithSign: v:false,
			\ useQuickfixForLocations: v:true,
			\ }

autocmd VimEnter * call LspOptionsSet(lspOptions)

let lspServers = [
			\ #{ name: 'gopls', filetype: ['go', 'gomod'], path: 'gopls', args: ['serve'] },
			\ #{ name: 'pylsp', filetype: ['py', 'python'], path: 'pylsp', args: [] },
			\]

autocmd VimEnter * call LspAddServer(lspServers)

let g:ale_disable_lsp = 1
let g:ale_set_signs = 1
let g:ale_set_highlights = 1
let g:ale_virtualtext_cursor = 1
highlight ALEError ctermbg=none cterm=underline

let g:ale_lint_on_save = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_change = 'never'

let g:ale_linters_explicit = 1
let g:ale_linters = {
			\ 'go': ['gofmt', 'gopls', 'govet', 'gobuild'],
			\ 'python': ['ruff', 'mypy', 'pylsp'],
			\ }

let g:ale_fixers = {
			\ '*': ['trim_whitespace'],
			\ 'python': ['ruff',],
			\ 'go': ['gopls', 'goimports', 'gofmt'],
			\ }

let g:ale_warn_about_trailing_whitespaces = 0
let g:ale_lsp_show_message_severity = 'information'
let g:ale_echo_msg_format = '[%linter%] [%severity%:%code%] %s'
let g:ale_linter_aliases = {"Containerfile": "dockerfile"}

let test#strategy = 'dispatch'

augroup LspSetup
	au!
	au User LspAttached set completeopt-=noselect
augroup END

inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

nnoremap <silent> <leader>f :Lines<CR>
nnoremap <silent> <leader>F :Ag<CR>
nnoremap <silent> <leader>b :Buffers <CR>
nnoremap <silent> <leader>g :GFiles <CR>

nnoremap <leader>i :LspHover<CR>
nnoremap <leader>d :LspGotoDefinition<CR>
nnoremap <leader>p :LspPeekDefinition<CR>
nnoremap <leader>R :LspRename<CR>
nnoremap <leader>r :LspPeekReference<CR>
nnoremap <leader>o :LspDocumentSymbol<CR>

nnoremap <leader>L :ALEFix<CR>

nnoremap <leader>tn :TestNearest<CR>
nnoremap <leader>tf :TestFile<CR>
nnoremap <leader>ts :TestSuite<CR>
nnoremap <leader>tl :testLast<CR>

call plug#begin()

" Colourschemes
Plug 'dracula/vim', { 'as': 'dracula' }

" Search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" LSP
Plug 'yegappan/lsp'

" Linting and Fixing
Plug 'dense-analysis/ale'

" Misc
Plug 'bluz71/vim-mistfly-statusline'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'janko-m/vim-test'
Plug 'tpope/vim-dispatch'
Plug 'sheerun/vim-polyglot'

call plug#end()

colorscheme dracula
