local g = vim.g
local opt = vim.opt
local key = vim.keymap.set

g.mapleader = ' '
g.maplocalleader = ' '

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

opt.undofile = true
opt.swapfile = false

opt.encoding = 'utf-8'

key('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear highlighting' })

key('n', '<leader>\\', '<cmd>vsplit<cr>', { desc = 'Vertical split' })
key('n', '<leader>-', '<cmd>split<cr>', { desc = 'Horizontal split' })

key('n', '<leader>sq', '<cmd>q<cr>', { desc = 'Close split' })

key('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
key('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom split' })
key('n', '<C-k>', '<C-w>k', { desc = 'Move to top split' })
key('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })

key('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase split height' })
key('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease split height' })
key('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease split width' })
key('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase split width' })

key('n', '<leader>bn', '<cmd>bnext<cr>', { desc = 'Move to next buffer' })
key('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = 'Move to previous buffer' })
key('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })

key('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New file' })

key('n', '<leader>w', '<cmd>w<cr>', { desc = 'Write buffer' })
key('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit ' })
