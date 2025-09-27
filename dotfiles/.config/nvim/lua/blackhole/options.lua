vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.syntax = 'on'

vim.opt.mouse = 'a'

vim.opt.showmode = true

vim.opt.termguicolors = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.signcolumn = 'yes'
vim.opt.ruler = true
vim.opt.colorcolumn = '80'
vim.opt.cursorline = true
vim.opt.scrolloff = 8

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv('HOME') .. '/.local/share/nvim/undo'

vim.opt.updatetime = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.clipboard = 'unnamedplus'
