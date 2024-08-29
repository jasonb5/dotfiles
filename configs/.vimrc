" https://medium.com/@devsjc/from-jetbrains-to-vim-a-modern-vim-configuration-and-plugin-set-d58472a7d53d
" https://codeinthehole.com/tips/writing-markdown-in-vim/
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

autocmd User LspSetup call LspOptionsSet(lspOptions)

let lspServers = [
			\ #{ name: 'gopls', filetype: ['go', 'gomod'], path: 'gopls', args: ['serve'] },
			\ #{ name: 'pylsp', filetype: ['py', 'python'], path: 'pylsp', args: [] },
			\]

autocmd User LspSetup call LspAddServer(lspServers)

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

let g:polyglot_disabled = ['markdown']

let g:vim_markdown_folding_disabled = 0
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_no_default_key_mapping = 1
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_fenced_languages = ['php', 'py=python', 'js=javascript', 'bash=sh', 'viml=vim']
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1

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
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'

call plug#end()

colorscheme dracula
