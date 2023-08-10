" disable compatibility mode
set nocompatible

" turn on filetype plugins
filetype plugin on
" turn on filetype indent
filetype indent on

" enable syntax highlighting
syntax enable

" set background to dark, needed for molokai colorscheme
set background=dark

set t_Co=256
" turn on line numbers
set number
" shows where you are in statusline
set ruler

set smartindent
set autoindent
" auto reload files when changed on disk
set autoread

set encoding=utf-8

" ignore case for search
set ignorecase
" enable incremental search
set incsearch
" highlight search matches
set hlsearch

" always show statusline
set laststatus=2

" show trailing whitespaces
set list

" show context above and below
set scrolloff=3

" no backup files
set nobackup
" no swap files
set noswapfile

" default split below
set splitbelow
" default split right
set splitright

set hidden

let mapleader = ','

let g:polyglot_disabled = []

let g:coc_global_extensions = [
			\'coc-sh',
			\]

call plug#begin()

"General
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', {'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'

"Syntax
Plug 'sheerun/vim-polyglot'
Plug 'sainnhe/sonokai'

"Colorscheme
Plug 'tomasr/molokai'

call plug#end()

silent! colorscheme sonokai

imap jk <esc>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <leader>sv :source $MYVIMRC<CR>:echom "Reloaded!"<CR>

inoremap <silent><expr> <TAB>
			\ coc#pum#visible() ? coc#pum#next(1) :
			\ CheckBackspace() ? "\<Tab>" :
			\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
			\: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

if has('nvim')
	inoremap <silent><expr> <c-space> coc#refresh()
else
	inoremap <silent><expr> <c-@> coc#refresh()
endif

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
	if CocAction('hasProvider', 'hover')
		call CocActionAsync('doHove')
	else
		call feedkeys('K', 'in')
	endif
endfunction

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

nmap <leader>ac <Plug>(coc-codeaction-cursor)
nmap <leader>as <Plug>(coc-codeaction-source)

nmap <leader>qf <Plug>(coc-fix-current)

nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r <Plug>(coc-codeaction-refactor-selected)

nmap <leader>cl <Plug>(coc-codelens-action)

nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<CR>
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<CR>
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<CR>
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<CR>
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<CR>
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

nnoremap <leader>b :buffers<CR>:buffers<Space>
nnoremap <silent> <C-b> :Buffers<CR>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

autocmd CursorHold * silent call CocActionAsync('highlight')

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
