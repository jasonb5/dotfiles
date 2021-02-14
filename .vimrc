set encoding=utf-8

let mapleader = " "

set backspace=2
set nobackup
set nowritebackup
set noswapfile
set history=50
set ruler
set showcmd
set incsearch
set laststatus=2
set autowrite
set modelines=0
set nomodeline

if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
	syntax on
endif

filetype plugin indent on

set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

set textwidth=80
set colorcolumn=+1

set number
set numberwidth=5

nnoremap <Leader><Leader> <C-^>

set splitbelow
set splitright

if exists('$TMUX')
  function! TmuxOrSplitSwitch(wincmd, tmuxdir)
    let previous_winnr = winnr()
    silent! execute "wincmd " . a:wincmd
    if previous_winnr == winnr()
      call system("tmux select-pane -" . a:tmuxdir)
      redraw!
    endif
  endfunction

  let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
  let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
  let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te

  nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<cr>
  nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<cr>
  nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<cr>
  nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<cr>
else
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l
endif

nnoremap <silent> vv <c-w>v</c-w><silent>

call plug#begin('~/.vim/plugged')
Plug 'jcherven/jummidark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

colorscheme jummidark
