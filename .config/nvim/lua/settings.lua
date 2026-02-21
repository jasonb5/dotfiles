-- Backup and Swap files
vim.o.backup = false
vim.o.swapfile = false
vim.o.undodir = vim.env.HOME .. '/.undodir'
vim.o.undofile = true

-- System clipboard
vim.o.clipboard = 'unnamedplus'

-- Better split window behavior
vim.o.splitright = true
vim.o.splitbelow = true

-- UI/Display settings
vim.o.termguicolors = true
vim.opt.termguicolors = true
vim.o.statuscolumn = '%l %s'
vim.o.signcolumn = 'yes:1'
vim.o.laststatus = 3
vim.cmd 'filetype plugin indent on';
vim.o.ls = 0 -- legacy statusline
vim.o.ch = 0 -- command height
vim.o.colorcolumn = '80'
vim.o.cursorline = true

-- Number/Line handling
vim.o.relativenumber = true
vim.o.number = true
vim.o.scrolloff = 4

-- Tabs and indentation
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.shiftround = false
vim.o.backspace = 'indent,eol,start'

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true

-- Completion
vim.o.completeopt = 'menuone,noinsert'

-- List & whitespace
vim.o.wrap = false

-- Editing behavior
vim.o.updatetime = 250
vim.o.hidden = true
vim.o.virtualedit = 'all'
vim.o.wildmode = 'list:longest,full'

