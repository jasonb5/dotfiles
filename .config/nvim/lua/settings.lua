-- Set leader key to <space>.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Default 4 spaces for identation.
vim.opt.sw = 4
vim.opt.ts = 4
vim.opt.et = true

-- Visualize whitespaces.
vim.opt.list = true

-- Show line numbers.
vim.opt.number = true

-- Enable mouse mode.
vim.opt.mouse = 'a'

-- Disable horizontal scroll and limit vertical to 3 lines.
vim.opt.mousescroll = 'ver:3,hor:0'

-- Wrap long lines at words.
vim.opt.linebreak = true

-- Rounded borders for floating windows.
vim.opt.winborder = 'rounded'

-- Sync clipboard.
vim.opt.clipboard = 'unnamedplus'

-- Save undo history.
vim.opt.undofile = true

-- Case insensitive search unless search contains capitals.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Enables sign column.
vim.opt.signcolumn = 'yes'

-- Update time and timeouts.
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10

-- Completion.
vim.opt.completeopt = 'menuone,noselect,noinsert'
vim.opt.pumheight = 15

-- Status line.
vim.opt.laststatus = 3
vim.opt.cmdheight = 1

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
